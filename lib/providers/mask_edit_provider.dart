import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mask_tool.dart';

/// マスク編集設定Provider
final maskEditSettingsProvider =
    StateNotifierProvider<MaskEditSettingsNotifier, MaskEditSettings>((ref) {
  return MaskEditSettingsNotifier();
});

/// マスク編集設定Notifier
class MaskEditSettingsNotifier extends StateNotifier<MaskEditSettings> {
  MaskEditSettingsNotifier() : super(const MaskEditSettings());

  void setBrushSize(double size) {
    state = state.copyWith(brushSize: size.clamp(1.0, 500.0));
  }

  void setHardness(double hardness) {
    state = state.copyWith(hardness: hardness.clamp(0.0, 1.0));
  }

  void setOpacity(double opacity) {
    state = state.copyWith(opacity: opacity.clamp(0.0, 1.0));
  }

  void setTool(MaskTool tool) {
    state = state.copyWith(tool: tool);
  }
}

/// マスク編集サービス
///
/// ブラシ、消しゴム、グラデーションなどのマスク編集機能を提供
class MaskEditService {
  /// ブラシで描画
  ///
  /// [maskImage] - 既存のマスク画像
  /// [points] - 描画するポイントのリスト
  /// [settings] - ブラシ設定
  /// Returns: 新しいマスク画像
  Future<ui.Image> drawBrush({
    required ui.Image maskImage,
    required List<Offset> points,
    required MaskEditSettings settings,
  }) async {
    if (points.isEmpty) return maskImage;

    // 既存のマスク画像をバイトデータに変換
    final byteData = await maskImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to convert mask to bytes');

    final pixels = byteData.buffer.asUint8List();
    final width = maskImage.width;
    final height = maskImage.height;

    // ブラシで描画
    final isEraser = settings.tool == MaskTool.eraser;
    final brushValue = isEraser ? 0 : 255; // 白（追加）または黒（削除）
    final brushRadius = settings.brushSize / 2;

    for (final point in points) {
      final px = point.dx.round();
      final py = point.dy.round();

      // ブラシの範囲内のピクセルを更新
      for (int dy = -brushRadius.ceil(); dy <= brushRadius.ceil(); dy++) {
        for (int dx = -brushRadius.ceil(); dx <= brushRadius.ceil(); dx++) {
          final x = px + dx;
          final y = py + dy;

          if (x < 0 || x >= width || y < 0 || y >= height) continue;

          // 距離を計算
          final distance = (dx * dx + dy * dy).toDouble();
          final maxDistance = brushRadius * brushRadius;

          if (distance > maxDistance) continue;

          // ブラシの硬さに基づいて減衰を計算
          double falloff = 1.0;
          if (settings.hardness < 1.0) {
            final softRadius = brushRadius * settings.hardness;
            if (distance > softRadius * softRadius) {
              falloff = 1.0 - ((distance.sqrt() - softRadius) / (brushRadius - softRadius));
              falloff = falloff.clamp(0.0, 1.0);
            }
          }

          // 不透明度を適用
          final alpha = (falloff * settings.opacity * 255).round();

          // ピクセルのインデックスを計算
          final index = (y * width + x) * 4;

          // 現在の値と新しい値をブレンド
          final currentValue = pixels[index];
          final blendedValue = isEraser
              ? (currentValue * (1.0 - alpha / 255.0)).round()
              : ((currentValue + (brushValue - currentValue) * alpha / 255.0)).round();

          // RGB全てに同じ値を設定（グレースケール）
          pixels[index] = blendedValue; // R
          pixels[index + 1] = blendedValue; // G
          pixels[index + 2] = blendedValue; // B
          // Alpha は 255 のまま
        }
      }
    }

    // 新しいui.Imageを作成
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }

  /// グラデーションマスクを作成
  ///
  /// [width] - マスク幅
  /// [height] - マスク高さ
  /// [startPoint] - グラデーション開始点（0.0-1.0の正規化座標）
  /// [endPoint] - グラデーション終了点（0.0-1.0の正規化座標）
  /// [inverted] - グラデーションを反転するか
  /// Returns: グラデーションマスク画像
  Future<ui.Image> createGradientMask({
    required int width,
    required int height,
    required Offset startPoint,
    required Offset endPoint,
    bool inverted = false,
  }) async {
    final pixels = Uint8List(width * height * 4);

    // グラデーションベクトルを計算
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    final length = (dx * dx + dy * dy).sqrt();

    if (length == 0) {
      // 長さが0の場合は全て白
      pixels.fillRange(0, pixels.length, 255);
    } else {
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          // 正規化座標
          final nx = x / width;
          final ny = y / height;

          // グラデーション上の位置を計算（0.0-1.0）
          final t = ((nx - startPoint.dx) * dx + (ny - startPoint.dy) * dy) / (length * length);
          final clamped = t.clamp(0.0, 1.0);

          // グラデーション値を計算
          final value = inverted ? (1.0 - clamped) : clamped;
          final grayValue = (value * 255).round();

          final index = (y * width + x) * 4;
          pixels[index] = grayValue; // R
          pixels[index + 1] = grayValue; // G
          pixels[index + 2] = grayValue; // B
          pixels[index + 3] = 255; // A
        }
      }
    }

    // ui.Imageを作成
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }

  /// 空のマスク（全て白）を作成
  Future<ui.Image> createEmptyMask(int width, int height) async {
    final pixels = Uint8List(width * height * 4);
    pixels.fillRange(0, pixels.length, 255); // 全て白

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }

  /// マスクを反転
  Future<ui.Image> invertMask(ui.Image maskImage) async {
    final byteData = await maskImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) throw Exception('Failed to convert mask to bytes');

    final pixels = byteData.buffer.asUint8List();
    final width = maskImage.width;
    final height = maskImage.height;

    // 各ピクセルを反転
    for (int i = 0; i < width * height; i++) {
      final index = i * 4;
      final value = pixels[index];
      final inverted = 255 - value;
      pixels[index] = inverted; // R
      pixels[index + 1] = inverted; // G
      pixels[index + 2] = inverted; // B
      // Alpha は変更しない
    }

    // 新しいui.Imageを作成
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }
}

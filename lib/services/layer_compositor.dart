import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../models/blend_mode.dart';
import '../models/layer.dart';

/// レイヤー合成サービス
///
/// 複数のレイヤーを合成して1枚の画像を生成
class LayerCompositor {
  /// レイヤーリストを合成
  ///
  /// [layers] - 合成するレイヤーのリスト（order順）
  /// [width] - 出力画像の幅
  /// [height] - 出力画像の高さ
  /// [backgroundColor] - 背景色
  /// Returns: 合成された画像
  Future<ui.Image> composeLayers({
    required List<Layer> layers,
    required int width,
    required int height,
    int backgroundColor = 0xFFFFFFFF,
  }) async {
    if (layers.isEmpty) {
      // レイヤーがない場合は空の画像を返す
      return _createEmptyImage(width, height, backgroundColor);
    }

    // 表示されているレイヤーのみをフィルター
    final visibleLayers = layers
        .where((layer) => layer.isVisible && layer.image != null)
        .toList();

    if (visibleLayers.isEmpty) {
      return _createEmptyImage(width, height, backgroundColor);
    }

    // Canvasに描画
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // 背景を描画
    final bgColor = Color(backgroundColor);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // レイヤーを下から上へ順番に合成
    for (final layer in visibleLayers) {
      await _drawLayer(
        canvas: canvas,
        layer: layer,
        size: size,
      );
    }

    // Pictureを画像に変換
    final picture = recorder.endRecording();
    final composedImage = await picture.toImage(width, height);

    return composedImage;
  }

  /// 個別のレイヤーを描画
  Future<void> _drawLayer({
    required Canvas canvas,
    required Layer layer,
    required Size size,
  }) async {
    if (layer.image == null) return;

    // レイヤーの不透明度を適用
    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, layer.opacity);

    // ブレンドモードを適用（簡易版）
    // TODO: 完全なブレンドモード実装
    switch (layer.blendMode) {
      case BlendMode.normal:
        paint.blendMode = ui.BlendMode.srcOver;
        break;
      case BlendMode.multiply:
        paint.blendMode = ui.BlendMode.multiply;
        break;
      case BlendMode.screen:
        paint.blendMode = ui.BlendMode.screen;
        break;
      case BlendMode.overlay:
        paint.blendMode = ui.BlendMode.overlay;
        break;
      case BlendMode.darken:
        paint.blendMode = ui.BlendMode.darken;
        break;
      case BlendMode.lighten:
        paint.blendMode = ui.BlendMode.lighten;
        break;
      case BlendMode.add:
        paint.blendMode = ui.BlendMode.plus;
        break;
      case BlendMode.difference:
        paint.blendMode = ui.BlendMode.difference;
        break;
      default:
        paint.blendMode = ui.BlendMode.srcOver;
    }

    // 画像を描画
    canvas.drawImageRect(
      layer.image!,
      Rect.fromLTWH(0, 0, layer.image!.width.toDouble(), layer.image!.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // マスクが有効な場合、マスクを適用
    if (layer.hasMask && layer.mask.maskImage != null) {
      await _applyMask(
        canvas: canvas,
        layer: layer,
        size: size,
      );
    }
  }

  /// レイヤーにマスクを適用
  Future<void> _applyMask({
    required Canvas canvas,
    required Layer layer,
    required Size size,
  }) async {
    // マスク適用の簡易実装
    // TODO: より高度なマスク合成
    final maskPaint = Paint()
      ..blendMode = ui.BlendMode.dstIn
      ..color = Color.fromRGBO(255, 255, 255, layer.mask.opacity);

    if (layer.mask.isInverted) {
      // マスクを反転
      maskPaint.colorFilter = const ColorFilter.matrix([
        -1, 0, 0, 0, 255,
        0, -1, 0, 0, 255,
        0, 0, -1, 0, 255,
        0, 0, 0, 1, 0,
      ]);
    }

    canvas.drawImageRect(
      layer.mask.maskImage!,
      Rect.fromLTWH(
        0,
        0,
        layer.mask.maskImage!.width.toDouble(),
        layer.mask.maskImage!.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, size.width, size.height),
      maskPaint,
    );
  }

  /// 空の画像を作成
  Future<ui.Image> _createEmptyImage(int width, int height, int bgColor) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Color(bgColor),
    );

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  /// レイヤーのサムネイルを生成
  ///
  /// [layer] - サムネイルを生成するレイヤー
  /// [size] - サムネイルサイズ
  /// Returns: サムネイル画像
  Future<ui.Image> generateThumbnail({
    required Layer layer,
    int size = 100,
  }) async {
    if (layer.image == null) {
      return _createEmptyImage(size, size, 0xFFCCCCCC);
    }

    // アスペクト比を維持したまま縮小
    final aspect = layer.image!.width / layer.image!.height;
    int thumbWidth, thumbHeight;

    if (aspect > 1) {
      thumbWidth = size;
      thumbHeight = (size / aspect).round();
    } else {
      thumbHeight = size;
      thumbWidth = (size * aspect).round();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      layer.image!,
      Rect.fromLTWH(0, 0, layer.image!.width.toDouble(), layer.image!.height.toDouble()),
      Rect.fromLTWH(0, 0, thumbWidth.toDouble(), thumbHeight.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    return picture.toImage(thumbWidth, thumbHeight);
  }
}

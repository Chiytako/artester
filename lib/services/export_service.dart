import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../models/edit_state.dart';

/// 高解像度画像エクスポートサービス
///
/// ui.PictureRecorderを使用したオフスクリーンレンダリングで
/// 元画像の解像度を維持したまま書き出しを行う。
/// RepaintBoundaryによるスクリーンショットは使用しない（画質劣化防止）。
class ExportService {
  /// 画像をエクスポートしてギャラリーに保存
  ///
  /// [program] - シェーダープログラム
  /// [originalImage] - 元画像（この解像度を維持）
  /// [lutImage] - LUT画像
  /// [hasLut] - LUTが適用されているか
  /// [lutIntensity] - LUT適用強度
  /// [parameters] - 編集パラメータ
  /// 画像をエクスポートしてギャラリーに保存
  Future<void> exportImage({
    required ui.FragmentProgram program,
    required ui.Image originalImage,
    required ui.Image lutImage,
    required bool hasLut,
    required double lutIntensity,
    required Map<String, double> parameters,
    int rotation = 0,
    bool flipX = false,
    bool flipY = false,
  }) async {
    final byteData = await _renderImage(
      program: program,
      originalImage: originalImage,
      lutImage: lutImage,
      hasLut: hasLut,
      lutIntensity: lutIntensity,
      parameters: parameters,
      rotation: rotation,
      flipX: flipX,
      flipY: flipY,
    );

    // 6. ギャラリーに保存
    await Gal.putImageBytes(byteData.buffer.asUint8List(), album: 'Artester');
  }

  /// 一時ファイルに画像を書き出す（切り抜き用）
  Future<String> exportToTempFile({
    required ui.FragmentProgram program,
    required ui.Image originalImage,
    required ui.Image lutImage, // usually neutral
    int rotation = 0,
    bool flipX = false,
    bool flipY = false,
  }) async {
    final byteData = await _renderImage(
      program: program,
      originalImage: originalImage,
      lutImage: lutImage,
      hasLut: false, // 切り抜き時はLUT無効
      lutIntensity: 0.0,
      parameters: {}, // 切り抜き時はパラメータ無効
      rotation: rotation,
      flipX: flipX,
      flipY: flipY,
    );

    final tempDir = Directory.systemTemp;
    final tempFile = File(
      '${tempDir.path}/crop_temp_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile.path;
  }

  Future<ByteData> _renderImage({
    required ui.FragmentProgram program,
    required ui.Image originalImage,
    required ui.Image lutImage,
    required bool hasLut,
    required double lutIntensity,
    required Map<String, double> parameters,
    required int rotation,
    required bool flipX,
    required bool flipY,
  }) async {
    // 1. オリジナル解像度でCanvas作成
    // 回転を考慮したサイズ計算
    final isRotated = rotation % 2 != 0;
    final width =
        isRotated
            ? originalImage.height.toDouble()
            : originalImage.width.toDouble();
    final height =
        isRotated
            ? originalImage.width.toDouble()
            : originalImage.height.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, height);

    // 2. シェーダー設定
    final shader = program.fragmentShader();

    shader.setImageSampler(0, originalImage);
    shader.setImageSampler(1, lutImage);

    int idx = 0;

    // uSize
    shader.setFloat(idx++, size.width);
    shader.setFloat(idx++, size.height);

    // LUT Parameters
    shader.setFloat(idx++, lutIntensity);
    shader.setFloat(idx++, hasLut ? 1.0 : 0.0);

    // Light Parameters
    shader.setFloat(idx++, _get(parameters, 'exposure'));
    shader.setFloat(idx++, _get(parameters, 'brightness'));
    shader.setFloat(idx++, _get(parameters, 'contrast'));
    shader.setFloat(idx++, _get(parameters, 'highlight'));
    shader.setFloat(idx++, _get(parameters, 'shadow'));

    // Color Parameters
    shader.setFloat(idx++, _get(parameters, 'saturation'));
    shader.setFloat(idx++, _get(parameters, 'temperature'));
    shader.setFloat(idx++, _get(parameters, 'tint'));

    // Effect Parameters
    shader.setFloat(idx++, _get(parameters, 'vignette'));
    shader.setFloat(idx++, _get(parameters, 'grain'));

    // Geometry Parameters
    shader.setFloat(idx++, rotation.toDouble());
    shader.setFloat(idx++, flipX ? 1.0 : 0.0);
    shader.setFloat(idx++, flipY ? 1.0 : 0.0);

    // 3. 描画
    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 4. Picture -> Image変換
    final picture = recorder.endRecording();
    final exportedImage = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    // 5. PNG形式でバイト配列に変換
    final byteData = await exportedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw Exception('Failed to convert image to bytes');
    }
    return byteData;
  }

  /// パラメータ取得ヘルパー
  double _get(Map<String, double> parameters, String key) =>
      parameters[key] ?? EditState.defaultParameters[key] ?? 0.0;
}

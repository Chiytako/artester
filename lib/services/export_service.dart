import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import '../models/edit_state.dart';
import '../utils/geometry_utils.dart';
import '../utils/shader_utils.dart';

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
    ui.Image? maskImage,
    bool hasMask = false,
    double bgSaturation = 0.0,
    double bgExposure = 0.0,
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
      maskImage: maskImage,
      hasMask: hasMask,
      bgSaturation: bgSaturation,
      bgExposure: bgExposure,
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
    ui.Image? maskImage,
    bool hasMask = false,
    double bgSaturation = 0.0,
    double bgExposure = 0.0,
  }) async {
    // 1. オリジナル解像度でCanvas作成
    // 回転を考慮したサイズ計算
    final size = GeometryUtils.getRotatedImageSize(originalImage, rotation);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 2. シェーダー設定
    final shader = program.fragmentShader();

    // サンプラー設定
    ShaderUtils.setShaderSamplers(
      shader: shader,
      image: originalImage,
      lutImage: lutImage,
      maskImage: maskImage,
      hasMask: hasMask,
    );

    // パラメータ設定
    // 背景処理用のパラメータをマップに追加
    final allParameters = Map<String, double>.from(parameters);
    if (hasMask) {
      allParameters['bgSaturation'] = bgSaturation;
      allParameters['bgExposure'] = bgExposure;
    }

    ShaderUtils.setShaderParameters(
      shader: shader,
      width: size.width,
      height: size.height,
      lutIntensity: lutIntensity,
      hasLut: hasLut,
      parameters: allParameters,
      rotation: rotation,
      flipX: flipX,
      flipY: flipY,
      hasMask: hasMask,
    );

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
}

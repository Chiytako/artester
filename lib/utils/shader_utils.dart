import 'dart:ui' as ui;

import '../models/edit_state.dart';

/// シェーダーに関するユーティリティ関数
class ShaderUtils {
  /// シェーダーにパラメータを設定
  ///
  /// [shader] - Fragment Shader
  /// [size] - 描画サイズ
  /// [lutImage] - LUT画像
  /// [lutIntensity] - LUT適用強度
  /// [hasLut] - LUTが適用されているか
  /// [parameters] - 編集パラメータ
  /// [rotation] - 回転状態
  /// [flipX] - 水平反転
  /// [flipY] - 垂直反転
  /// [hasMask] - AIマスクが利用可能か
  /// [isComparing] - 比較モード（オプショナル、デフォルト: false）
  ///
  /// シェーダーのuniform定義順序に厳密に合わせて設定する必要がある
  static void setShaderParameters({
    required ui.FragmentShader shader,
    required double width,
    required double height,
    required double lutIntensity,
    required bool hasLut,
    required Map<String, double> parameters,
    required int rotation,
    required bool flipX,
    required bool flipY,
    required bool hasMask,
    bool isComparing = false,
  }) {
    int idx = 0;

    // uSize (vec2) - 描画サイズ
    shader.setFloat(idx++, width);
    shader.setFloat(idx++, height);

    // LUT Parameters
    shader.setFloat(idx++, lutIntensity); // uLutIntensity
    shader.setFloat(idx++, hasLut ? 1.0 : 0.0); // uHasLut

    // Light Parameters
    shader.setFloat(idx++, _getParameter(parameters, 'exposure')); // uExposure
    shader.setFloat(idx++, _getParameter(parameters, 'brightness')); // uBrightness
    shader.setFloat(idx++, _getParameter(parameters, 'contrast')); // uContrast
    shader.setFloat(idx++, _getParameter(parameters, 'highlight')); // uHighlight
    shader.setFloat(idx++, _getParameter(parameters, 'shadow')); // uShadow

    // Color Parameters
    shader.setFloat(idx++, _getParameter(parameters, 'saturation')); // uSaturation
    shader.setFloat(idx++, _getParameter(parameters, 'temperature')); // uTemperature
    shader.setFloat(idx++, _getParameter(parameters, 'tint')); // uTint

    // Effect Parameters
    shader.setFloat(idx++, _getParameter(parameters, 'vignette')); // uVignette
    shader.setFloat(idx++, _getParameter(parameters, 'grain')); // uGrain

    // Geometry Parameters
    shader.setFloat(idx++, rotation.toDouble()); // uRotation
    shader.setFloat(idx++, flipX ? 1.0 : 0.0); // uFlipX
    shader.setFloat(idx++, flipY ? 1.0 : 0.0); // uFlipY

    // AI Segmentation Parameters
    shader.setFloat(idx++, hasMask ? 1.0 : 0.0); // uHasMask
    shader.setFloat(idx++, _getParameter(parameters, 'bgSaturation')); // uBgSaturation
    shader.setFloat(idx++, _getParameter(parameters, 'bgExposure')); // uBgExposure

    // Compare Mode Parameter (if applicable)
    if (isComparing) {
      shader.setFloat(idx++, 1.0); // uShowOriginal
    }
  }

  /// シェーダーにサンプラーを設定
  ///
  /// [shader] - Fragment Shader
  /// [image] - オリジナル画像
  /// [lutImage] - LUT画像
  /// [maskImage] - マスク画像（オプショナル）
  /// [hasMask] - マスクが利用可能か
  ///
  /// サンプラーはFlutterの要件により最初に設定する必要がある
  static void setShaderSamplers({
    required ui.FragmentShader shader,
    required ui.Image image,
    required ui.Image lutImage,
    ui.Image? maskImage,
    required bool hasMask,
  }) {
    // 重要: シェーダーで定義されているすべてのサンプラーを設定する必要がある
    shader.setImageSampler(0, image); // uTexture
    shader.setImageSampler(1, lutImage); // uLut
    // マスクがない場合はダミーとしてLUT画像を使用（uHasMaskフラグで無効化）
    shader.setImageSampler(
      2,
      hasMask && maskImage != null ? maskImage : lutImage,
    ); // uMask
  }

  /// パラメータ値を取得（存在しない場合はデフォルト値）
  static double _getParameter(Map<String, double> parameters, String key) =>
      parameters[key] ?? EditState.defaultParameters[key] ?? 0.0;

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  ShaderUtils._();
}

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/blend_mode.dart';
import '../models/layer.dart';
import '../models/layer_effect.dart';
import '../models/adjustment_layer.dart';

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

    canvas.save();

    // 調整レイヤーの場合は直下のレイヤーに調整を適用
    if (layer.isAdjustmentLayer && layer.adjustmentData != null) {
      await _applyAdjustmentLayer(
        canvas: canvas,
        layer: layer,
        size: size,
      );
      canvas.restore();
      return;
    }

    // エフェクトを適用（ドロップシャドウなど）
    if (layer.hasEffects && layer.effects != null) {
      await _applyLayerEffects(
        canvas: canvas,
        layer: layer,
        size: size,
      );
    }

    // レイヤーの不透明度を適用
    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, layer.opacity);

    // ブレンドモードを適用
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

    canvas.restore();
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

  /// レイヤーエフェクトを適用
  Future<void> _applyLayerEffects({
    required Canvas canvas,
    required Layer layer,
    required Size size,
  }) async {
    final effects = layer.effects!;

    // ドロップシャドウ
    if (effects.dropShadow != null && effects.dropShadow!.enabled) {
      await _applyDropShadow(
        canvas: canvas,
        layer: layer,
        effect: effects.dropShadow!,
        size: size,
      );
    }

    // 外側の光彩
    if (effects.outerGlow != null && effects.outerGlow!.enabled) {
      await _applyOuterGlow(
        canvas: canvas,
        layer: layer,
        effect: effects.outerGlow!,
        size: size,
      );
    }

    // 境界線（後で画像の上に描画するため、ここでは何もしない）
  }

  /// ドロップシャドウを適用
  Future<void> _applyDropShadow({
    required Canvas canvas,
    required Layer layer,
    required DropShadowEffect effect,
    required Size size,
  }) async {
    final angleRad = effect.angle * math.pi / 180.0;
    final offsetX = math.cos(angleRad) * effect.distance;
    final offsetY = math.sin(angleRad) * effect.distance;

    final shadowPaint = Paint()
      ..color = Color(effect.color).withValues(alpha: effect.opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, effect.size);

    canvas.drawImageRect(
      layer.image!,
      Rect.fromLTWH(0, 0, layer.image!.width.toDouble(), layer.image!.height.toDouble()),
      Rect.fromLTWH(offsetX, offsetY, size.width, size.height),
      shadowPaint,
    );
  }

  /// 外側の光彩を適用
  Future<void> _applyOuterGlow({
    required Canvas canvas,
    required Layer layer,
    required GlowEffect effect,
    required Size size,
  }) async {
    final glowPaint = Paint()
      ..color = Color(effect.color).withValues(alpha: effect.opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, effect.size);

    canvas.drawImageRect(
      layer.image!,
      Rect.fromLTWH(0, 0, layer.image!.width.toDouble(), layer.image!.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaint,
    );
  }

  /// 調整レイヤーを適用
  Future<void> _applyAdjustmentLayer({
    required Canvas canvas,
    required Layer layer,
    required Size size,
  }) async {
    final adjustment = layer.adjustmentData!;
    ColorFilter? colorFilter;

    switch (adjustment.type) {
      case AdjustmentType.hueSaturation:
        colorFilter = _createHueSaturationFilter(adjustment.hueSaturation!);
        break;
      case AdjustmentType.brightnessContrast:
        colorFilter = _createBrightnessContrastFilter(adjustment.brightnessContrast!);
        break;
      case AdjustmentType.exposure:
        colorFilter = _createExposureFilter(adjustment.exposure!);
        break;
      case AdjustmentType.colorBalance:
        colorFilter = _createColorBalanceFilter(adjustment.colorBalance!);
        break;
      case AdjustmentType.colorFilter:
        colorFilter = _createColorFilterEffect(adjustment.colorFilter!);
        break;
      case AdjustmentType.invert:
        colorFilter = _createInvertFilter();
        break;
      case AdjustmentType.posterize:
        colorFilter = _createPosterizeFilter(adjustment.posterize!);
        break;
      default:
        break;
    }

    if (colorFilter != null) {
      final paint = Paint()..colorFilter = colorFilter;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  /// 色相・彩度フィルター
  ColorFilter _createHueSaturationFilter(HueSaturationAdjustment adjustment) {
    // 簡易実装: 彩度調整のみ
    final sat = 1.0 + (adjustment.saturation / 100.0);
    final lum = adjustment.lightness / 100.0;

    return ColorFilter.matrix([
      sat, 0, 0, 0, lum * 255,
      0, sat, 0, 0, lum * 255,
      0, 0, sat, 0, lum * 255,
      0, 0, 0, 1, 0,
    ]);
  }

  /// 明度・コントラストフィルター
  ColorFilter _createBrightnessContrastFilter(BrightnessContrastAdjustment adjustment) {
    final brightness = adjustment.brightness / 100.0;
    final contrast = 1.0 + (adjustment.contrast / 100.0);
    final intercept = 128 * (1 - contrast) + brightness * 255;

    return ColorFilter.matrix([
      contrast, 0, 0, 0, intercept,
      0, contrast, 0, 0, intercept,
      0, 0, contrast, 0, intercept,
      0, 0, 0, 1, 0,
    ]);
  }

  /// 露光量フィルター
  ColorFilter _createExposureFilter(ExposureAdjustment adjustment) {
    final exposure = math.pow(2, adjustment.exposure).toDouble();
    final offset = adjustment.offset * 255;

    return ColorFilter.matrix([
      exposure, 0, 0, 0, offset,
      0, exposure, 0, 0, offset,
      0, 0, exposure, 0, offset,
      0, 0, 0, 1, 0,
    ]);
  }

  /// カラーバランスフィルター
  ColorFilter _createColorBalanceFilter(ColorBalanceAdjustment adjustment) {
    // 簡易実装: ミッドトーンのみ適用
    final r = 1.0 + (adjustment.midtonesCyanRed / 100.0);
    final g = 1.0 + (adjustment.midtonesMagentaGreen / 100.0);
    final b = 1.0 + (adjustment.midtonesYellowBlue / 100.0);

    return ColorFilter.matrix([
      r, 0, 0, 0, 0,
      0, g, 0, 0, 0,
      0, 0, b, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  /// カラーフィルターエフェクト
  ColorFilter _createColorFilterEffect(ColorFilterAdjustment adjustment) {
    final color = Color(adjustment.color);
    final density = adjustment.density;

    return ColorFilter.mode(
      color.withValues(alpha: density),
      ui.BlendMode.srcOver,
    );
  }

  /// 階調反転フィルター
  ColorFilter _createInvertFilter() {
    return const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]);
  }

  /// ポスタリゼーションフィルター
  ColorFilter _createPosterizeFilter(PosterizeAdjustment adjustment) {
    final levels = adjustment.levels.toDouble();
    final scale = 255.0 / (levels - 1);

    // 簡易実装: 階調数を減らす
    return ColorFilter.matrix([
      scale, 0, 0, 0, 0,
      0, scale, 0, 0, 0,
      0, 0, scale, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }
}

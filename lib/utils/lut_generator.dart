import 'dart:typed_data';
import 'dart:ui' as ui;

/// デバッグ用のLUT画像を生成するユーティリティクラス
///
/// 512x512のHald CLUT Level 8 形式で生成。
class LutGenerator {
  /// Neutral LUT（入力色をそのまま出力）を生成
  static Future<ui.Image> generateNeutralLut() async {
    return _generateLut((r, g, b) => [r, g, b]);
  }

  /// Warm LUT（暖色系）を生成
  static Future<ui.Image> generateWarmLut() async {
    return _generateLut((r, g, b) {
      // 赤みを増やし、青みを減らす
      return [
        (r * 1.1).clamp(0, 255).toInt(),
        g,
        (b * 0.9).clamp(0, 255).toInt(),
      ];
    });
  }

  /// Cool LUT（寒色系）を生成
  static Future<ui.Image> generateCoolLut() async {
    return _generateLut((r, g, b) {
      // 青みを増やし、赤みを減らす
      return [
        (r * 0.9).clamp(0, 255).toInt(),
        g,
        (b * 1.1).clamp(0, 255).toInt(),
      ];
    });
  }

  /// Vintage LUT（レトロ調）を生成
  static Future<ui.Image> generateVintageLut() async {
    return _generateLut((r, g, b) {
      // 彩度を下げ、黄色みを追加
      final avg = (r + g + b) ~/ 3;
      return [
        ((r * 0.7 + avg * 0.3) * 1.05).clamp(0, 255).toInt(),
        ((g * 0.7 + avg * 0.3) * 1.02).clamp(0, 255).toInt(),
        ((b * 0.7 + avg * 0.3) * 0.85).clamp(0, 255).toInt(),
      ];
    });
  }

  /// Cinematic LUT（映画調）を生成
  static Future<ui.Image> generateCinematicLut() async {
    return _generateLut((r, g, b) {
      // ティールオレンジ風: ハイライトをオレンジ、シャドウをティール
      final luminance = (r * 0.299 + g * 0.587 + b * 0.114).toInt();
      final t = luminance / 255.0;

      // シャドウ: ティール (0, 128, 128)
      // ハイライト: オレンジ (255, 165, 0)
      final newR = (r * 0.8 + t * 50).clamp(0, 255).toInt();
      final newG = (g * 0.95).clamp(0, 255).toInt();
      final newB = (b * 0.7 + (1 - t) * 30).clamp(0, 255).toInt();

      return [newR, newG, newB];
    });
  }

  /// 汎用のLUT生成関数
  static Future<ui.Image> _generateLut(
    List<int> Function(int r, int g, int b) transform,
  ) async {
    const int size = 512;
    const int tileSize = 64;
    const int tilesPerRow = 8;

    final pixels = Uint8List(size * size * 4);

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final tileX = x ~/ tileSize;
        final tileY = y ~/ tileSize;
        final localX = x % tileSize;
        final localY = y % tileSize;
        final blueIndex = tileY * tilesPerRow + tileX;

        // 入力RGB（0-255）
        final inR = (localX * 255 / 63).round().clamp(0, 255);
        final inG = (localY * 255 / 63).round().clamp(0, 255);
        final inB = (blueIndex * 255 / 63).round().clamp(0, 255);

        // 変換適用
        final out = transform(inR, inG, inB);

        final index = (y * size + x) * 4;
        pixels[index] = out[0];
        pixels[index + 1] = out[1];
        pixels[index + 2] = out[2];
        pixels[index + 3] = 255;
      }
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: size,
      height: size,
      pixelFormat: ui.PixelFormat.rgba8888,
    );

    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

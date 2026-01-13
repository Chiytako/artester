import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 幾何学的変換に関するユーティリティ関数
class GeometryUtils {
  /// 回転を考慮したサイズを取得
  ///
  /// [originalSize] - オリジナルのサイズ
  /// [rotation] - 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  ///
  /// 90度または270度の回転時は、幅と高さが入れ替わる
  static Size getRotatedSize(Size originalSize, int rotation) {
    final isRotated = rotation % 2 != 0;
    return isRotated
        ? Size(originalSize.height, originalSize.width)
        : originalSize;
  }

  /// 回転を考慮した画像サイズを取得
  ///
  /// [image] - オリジナルの画像
  /// [rotation] - 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  ///
  /// 90度または270度の回転時は、幅と高さが入れ替わる
  static Size getRotatedImageSize(ui.Image image, int rotation) {
    final isRotated = rotation % 2 != 0;
    return isRotated
        ? Size(image.height.toDouble(), image.width.toDouble())
        : Size(image.width.toDouble(), image.height.toDouble());
  }

  /// 回転を考慮した整数サイズを取得
  ///
  /// [width] - オリジナルの幅
  /// [height] - オリジナルの高さ
  /// [rotation] - 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
  ///
  /// Returns: {width, height} のMap
  static Map<String, int> getRotatedIntSize(int width, int height, int rotation) {
    final isRotated = rotation % 2 != 0;
    return {
      'width': isRotated ? height : width,
      'height': isRotated ? width : height,
    };
  }

  /// アスペクト比を維持しながらキャンバスにフィットする描画サイズを計算
  ///
  /// [imageSize] - 画像のサイズ
  /// [canvasSize] - キャンバスのサイズ
  ///
  /// Returns: 描画サイズとオフセット {width, height, offsetX, offsetY}
  static Map<String, double> calculateFitSize(Size imageSize, Size canvasSize) {
    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double drawWidth, drawHeight;
    double offsetX = 0, offsetY = 0;

    if (imageAspect > canvasAspect) {
      drawWidth = canvasSize.width;
      drawHeight = canvasSize.width / imageAspect;
      offsetY = (canvasSize.height - drawHeight) / 2;
    } else {
      drawHeight = canvasSize.height;
      drawWidth = canvasSize.height * imageAspect;
      offsetX = (canvasSize.width - drawWidth) / 2;
    }

    return {
      'width': drawWidth,
      'height': drawHeight,
      'offsetX': offsetX,
      'offsetY': offsetY,
    };
  }

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  GeometryUtils._();
}

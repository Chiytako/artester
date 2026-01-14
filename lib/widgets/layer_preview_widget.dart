import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer_stack.dart';
import '../providers/layer_stack_provider.dart';
import '../services/layer_compositor.dart';

/// レイヤープレビューウィジェット
///
/// 複数のレイヤーを合成してプレビュー表示
class LayerPreviewWidget extends ConsumerStatefulWidget {
  const LayerPreviewWidget({super.key});

  @override
  ConsumerState<LayerPreviewWidget> createState() =>
      _LayerPreviewWidgetState();
}

class _LayerPreviewWidgetState extends ConsumerState<LayerPreviewWidget> {
  final LayerCompositor _compositor = LayerCompositor();
  ui.Image? _composedImage;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _composeLayersDebounced();
  }

  @override
  void didUpdateWidget(LayerPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _composeLayersDebounced();
  }

  /// レイヤーを合成（デバウンス付き）
  void _composeLayersDebounced() {
    if (_isComposing) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _composeLayers();
      }
    });
  }

  /// レイヤーを合成
  Future<void> _composeLayers() async {
    final layerStack = ref.read(layerStackProvider);

    if (!layerStack.hasLayers) {
      setState(() {
        _composedImage = null;
      });
      return;
    }

    setState(() {
      _isComposing = true;
    });

    try {
      final composedImage = await _compositor.composeLayers(
        layers: layerStack.layers,
        width: layerStack.canvasWidth,
        height: layerStack.canvasHeight,
        backgroundColor: layerStack.backgroundColor,
      );

      if (mounted) {
        setState(() {
          _composedImage = composedImage;
          _isComposing = false;
        });
      }
    } catch (e) {
      debugPrint('[LayerPreview] Error composing layers: $e');
      if (mounted) {
        setState(() {
          _isComposing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // レイヤースタックの変更を監視
    ref.listen<LayerStack>(layerStackProvider, (previous, next) {
      if (previous?.version != next.version) {
        _composeLayersDebounced();
      }
    });

    if (_composedImage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('画像を合成中...'),
          ],
        ),
      );
    }

    return CustomPaint(
      painter: _LayerPreviewPainter(image: _composedImage!),
      size: Size.infinite,
    );
  }

  @override
  void dispose() {
    _composedImage?.dispose();
    super.dispose();
  }
}

/// レイヤープレビューペインター
class _LayerPreviewPainter extends CustomPainter {
  final ui.Image image;

  _LayerPreviewPainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // 画像のアスペクト比を維持しながらフィット
    final imageAspect = image.width / image.height;
    final canvasAspect = size.width / size.height;

    double drawWidth, drawHeight;
    double offsetX = 0, offsetY = 0;

    if (imageAspect > canvasAspect) {
      drawWidth = size.width;
      drawHeight = size.width / imageAspect;
      offsetY = (size.height - drawHeight) / 2;
    } else {
      drawHeight = size.height;
      drawWidth = size.height * imageAspect;
      offsetX = (size.width - drawWidth) / 2;
    }

    // 背景（チェッカーボード）を描画
    _drawCheckerboard(canvas, size);

    // 画像を描画
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  /// チェッカーボード背景を描画
  void _drawCheckerboard(Canvas canvas, Size size) {
    const squareSize = 20.0;
    final paint1 = Paint()..color = Colors.white;
    final paint2 = Paint()..color = Colors.grey[300]!;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEvenRow = (y / squareSize).floor() % 2 == 0;
        final isEvenCol = (x / squareSize).floor() % 2 == 0;
        final paint = (isEvenRow == isEvenCol) ? paint1 : paint2;

        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LayerPreviewPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

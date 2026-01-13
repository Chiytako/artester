import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mask_tool.dart';
import '../../providers/layer_stack_provider.dart';
import '../../providers/mask_edit_provider.dart';

/// マスク描画キャンバス
///
/// タッチ入力を受け取ってマスクを編集
class MaskCanvas extends ConsumerStatefulWidget {
  final String layerId;

  const MaskCanvas({
    super.key,
    required this.layerId,
  });

  @override
  ConsumerState<MaskCanvas> createState() => _MaskCanvasState();
}

class _MaskCanvasState extends ConsumerState<MaskCanvas> {
  final List<Offset> _currentStroke = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    final layerStack = ref.watch(layerStackProvider);
    final layer = layerStack.getLayerById(widget.layerId);
    final settings = ref.watch(maskEditSettingsProvider);

    if (layer == null || layer.image == null) {
      return const Center(
        child: Text('レイヤーが見つかりません'),
      );
    }

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDrawing = true;
          _currentStroke.clear();
          _currentStroke.add(details.localPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _currentStroke.add(details.localPosition);
        });
      },
      onPanEnd: (details) async {
        if (_currentStroke.isNotEmpty && layer.mask.maskImage != null) {
          // マスクを更新
          await _applyStroke(layer.mask.maskImage!, settings);
        }
        setState(() {
          _isDrawing = false;
          _currentStroke.clear();
        });
      },
      child: CustomPaint(
        painter: _MaskCanvasPainter(
          image: layer.image!,
          maskImage: layer.mask.maskImage,
          currentStroke: _currentStroke,
          brushSize: settings.brushSize,
          tool: settings.tool,
        ),
        size: Size.infinite,
      ),
    );
  }

  Future<void> _applyStroke(ui.Image maskImage, MaskEditSettings settings) async {
    final service = MaskEditService();

    try {
      // 画面座標をマスク画像座標に変換
      final imagePoints = _currentStroke.map((point) {
        // TODO: 正確な座標変換（アスペクト比を考慮）
        return point;
      }).toList();

      // ブラシ描画
      final updatedMask = await service.drawBrush(
        maskImage: maskImage,
        points: imagePoints,
        settings: settings,
      );

      // レイヤーのマスクを更新
      ref.read(layerStackProvider.notifier).updateLayerMask(
            widget.layerId,
            updatedMask,
          );
    } catch (e) {
      debugPrint('[MaskCanvas] Error applying stroke: $e');
    }
  }
}

/// マスクキャンバスペインター
class _MaskCanvasPainter extends CustomPainter {
  final ui.Image image;
  final ui.Image? maskImage;
  final List<Offset> currentStroke;
  final double brushSize;
  final MaskTool tool;

  _MaskCanvasPainter({
    required this.image,
    required this.maskImage,
    required this.currentStroke,
    required this.brushSize,
    required this.tool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 画像を描画
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

    // 画像を描画
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight),
      Paint(),
    );

    // マスクがあれば半透明で重ねて描画
    if (maskImage != null) {
      final maskPaint = Paint()
        ..colorFilter = const ColorFilter.mode(
          Colors.red,
          BlendMode.srcATop,
        )
        ..color = Colors.red.withValues(alpha: 0.3);

      canvas.drawImageRect(
        maskImage!,
        Rect.fromLTWH(0, 0, maskImage!.width.toDouble(), maskImage!.height.toDouble()),
        Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight),
        maskPaint,
      );
    }

    // 現在のストロークを描画
    if (currentStroke.isNotEmpty) {
      final strokePaint = Paint()
        ..color = tool == MaskTool.eraser ? Colors.black : Colors.white
        ..strokeWidth = brushSize
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }

      canvas.drawPath(path, strokePaint);

      // ブラシカーソルを描画
      final cursorPaint = Paint()
        ..color = tool.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        currentStroke.last,
        brushSize / 2,
        cursorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MaskCanvasPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.maskImage != maskImage ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.brushSize != brushSize ||
        oldDelegate.tool != tool;
  }
}

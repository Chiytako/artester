import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/mask_edit_provider.dart';

/// グラデーションマスク作成ダイアログ
class GradientMaskDialog extends ConsumerStatefulWidget {
  final int imageWidth;
  final int imageHeight;

  const GradientMaskDialog({
    super.key,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  ConsumerState<GradientMaskDialog> createState() =>
      _GradientMaskDialogState();
}

class _GradientMaskDialogState extends ConsumerState<GradientMaskDialog> {
  Offset _startPoint = const Offset(0.2, 0.5);
  Offset _endPoint = const Offset(0.8, 0.5);
  bool _inverted = false;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Row(
              children: [
                const Icon(Icons.gradient, color: AppColors.primary),
                const SizedBox(width: AppConstants.spacingSmall),
                const Text(
                  'グラデーションマスク',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // プレビューエリア
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusSmall),
                child: GestureDetector(
                  onPanStart: (details) => _updatePoints(details.localPosition),
                  onPanUpdate: (details) =>
                      _updatePoints(details.localPosition),
                  child: CustomPaint(
                    painter: _GradientPreviewPainter(
                      startPoint: _startPoint,
                      endPoint: _endPoint,
                      inverted: _inverted,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spacingMedium),

            // 説明
            const Text(
              'ドラッグしてグラデーションの向きを調整',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // 反転スイッチ
            SwitchListTile(
              title: const Text(
                'グラデーションを反転',
                style: TextStyle(color: AppColors.onSurface),
              ),
              value: _inverted,
              onChanged: (value) {
                setState(() {
                  _inverted = value;
                });
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: AppConstants.spacingLarge),

            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isGenerating
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generateMask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('作成'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updatePoints(Offset localPosition) {
    final size = context.size;
    if (size == null) return;

    final normalizedX = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final normalizedY = (localPosition.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      // 開始点と終了点を交互に更新
      final distToStart = (Offset(normalizedX, normalizedY) - _startPoint).distance;
      final distToEnd = (Offset(normalizedX, normalizedY) - _endPoint).distance;

      if (distToStart < distToEnd) {
        _startPoint = Offset(normalizedX, normalizedY);
      } else {
        _endPoint = Offset(normalizedX, normalizedY);
      }
    });
  }

  Future<void> _generateMask() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final service = MaskEditService();
      final maskImage = await service.createGradientMask(
        width: widget.imageWidth,
        height: widget.imageHeight,
        startPoint: _startPoint,
        endPoint: _endPoint,
        inverted: _inverted,
      );

      if (mounted) {
        Navigator.pop(context, maskImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('グラデーションマスクの作成に失敗しました: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}

/// グラデーションプレビューペインター
class _GradientPreviewPainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final bool inverted;

  _GradientPreviewPainter({
    required this.startPoint,
    required this.endPoint,
    required this.inverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // グラデーション描画
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment(startPoint.dx * 2 - 1, startPoint.dy * 2 - 1),
      end: Alignment(endPoint.dx * 2 - 1, endPoint.dy * 2 - 1),
      colors: inverted
          ? [Colors.white, Colors.black]
          : [Colors.black, Colors.white],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // 開始点を描画
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(startPoint.dx * size.width, startPoint.dy * size.height),
      8,
      startPaint,
    );

    // 終了点を描画
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(endPoint.dx * size.width, endPoint.dy * size.height),
      8,
      endPaint,
    );

    // ラインを描画
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(startPoint.dx * size.width, startPoint.dy * size.height),
      Offset(endPoint.dx * size.width, endPoint.dy * size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientPreviewPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.inverted != inverted;
  }
}

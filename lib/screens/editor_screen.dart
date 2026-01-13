import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/edit_provider.dart';
import '../widgets/control_panel.dart';
import '../widgets/shader_preview_widget.dart';

/// メイン編集画面
///
/// Stack構造:
/// - Bottom: 背景色
/// - Middle: ShaderPreviewWidget（GPU画像処理結果）
/// - Top: OverlayLayer（将来のテキスト・ステッカー用）
/// - UI Overlay: ControlPanel（スライダー・ボタン）
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  // Export機能用のシェーダーリソース
  ui.FragmentProgram? _program;
  ui.Image? _neutralLut;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProvider);
    final hasImage = editState.imagePath != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, hasImage, editState.isLoading),
      body: Stack(
        children: [
          // Layer 0: Background
          Container(color: AppColors.surface),

          // Layer 1: Shader Preview (GPU処理結果)
          Positioned.fill(
            child: ShaderPreviewWidget(
              onReady: (program, neutralLut) {
                _program = program;
                _neutralLut = neutralLut;
                // Update specific provider for Geometry operations
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(shaderResourcesProvider.notifier)
                      .state = ShaderResources(program, neutralLut);
                });
              },
            ),
          ),

          // Layer 2: Overlay Layer (将来のテキスト・ステッカー用)
          // 現在は空のContainer
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                // 将来的にテキストやステッカーを描画
                color: Colors.transparent,
              ),
            ),
          ),

          // 比較モードのヒント表示
          if (hasImage && !editState.isComparing)
            Positioned(
              top: AppConstants.spacingLarge,
              left: AppConstants.spacingLarge,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.overlayDark,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: AppColors.textSecondary, size: AppConstants.iconSizeSmall),
                    SizedBox(width: AppConstants.spacingSmall),
                    Text(
                      'Long press to compare',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

          // 比較モード中の表示
          if (editState.isComparing)
            Positioned(
              top: AppConstants.spacingLarge,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingXLarge,
                    vertical: AppConstants.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: AppConstants.opacityHigh),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusCircular),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: AppConstants.opacityLow),
                        blurRadius: AppConstants.blurRadiusMedium,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility, color: Colors.black87, size: AppConstants.iconSizeSmall + 4),
                      SizedBox(width: AppConstants.spacingSmall),
                      Text(
                        'ORIGINAL',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Layer 3: Control Panel (UI)
          if (hasImage)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ControlPanel(),
            ),

          // 画像未選択時のピッカーボタン
          if (!hasImage) Center(child: _buildImagePickerButton()),

          // エクスポート中のオーバーレイ
          if (_isExporting)
            Container(
              color: AppColors.overlayDark,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: AppConstants.spacingLarge),
                    Text(
                      'エクスポート中...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    bool hasImage,
    bool isLoading,
  ) {
    final notifier = ref.read(editProvider.notifier);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        AppConstants.appName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      leading:
          hasImage
              ? IconButton(
                icon: const Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                ),
                onPressed: () => notifier.pickImage(),
                tooltip: '別の画像を選択',
              )
              : null,
      actions: [
        if (hasImage) ...[
          // Undo ボタン
          IconButton(
            icon: Icon(
              Icons.undo,
              color: notifier.canUndo ? Colors.white : Colors.white30,
            ),
            onPressed: notifier.canUndo ? () => notifier.undo() : null,
            tooltip: '元に戻す',
          ),
          // Redo ボタン
          IconButton(
            icon: Icon(
              Icons.redo,
              color: notifier.canRedo ? Colors.white : Colors.white30,
            ),
            onPressed: notifier.canRedo ? () => notifier.redo() : null,
            tooltip: 'やり直す',
          ),
          // リセットボタン
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _showResetConfirmDialog(context, notifier),
            tooltip: 'リセット',
          ),
          // エクスポートボタン（新規追加）
          IconButton(
            icon: Icon(
              Icons.download,
              color:
                  (_program != null && !isLoading)
                      ? AppColors.primary
                      : AppColors.textTertiary,
            ),
            onPressed:
                (_program != null && !isLoading) ? () => _exportImage() : null,
            tooltip: '画像を保存',
          ),
        ],
      ],
    );
  }

  Widget _buildImagePickerButton() {
    return GestureDetector(
      onTap: () => ref.read(editProvider.notifier).pickImage(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingXXLarge,
          vertical: AppConstants.paddingXLarge,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade700, Colors.orange.shade800],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: AppConstants.blurRadiusLarge,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate, color: Colors.white, size: AppConstants.iconSizeLarge),
            SizedBox(width: AppConstants.spacingMedium),
            Text(
              '画像を選択',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, EditNotifier notifier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.dialogBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
            title: const Text('編集をリセット', style: TextStyle(color: Colors.white)),
            content: const Text(
              'すべての調整をデフォルト値に戻しますか？',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  notifier.resetAllParameters();
                  Navigator.pop(context);
                },
                child: const Text('リセット', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  /// 画像をエクスポート
  Future<void> _exportImage() async {
    if (_program == null || _neutralLut == null) return;

    setState(() => _isExporting = true);

    try {
      await ref
          .read(editProvider.notifier)
          .exportResult(_program!, _neutralLut!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppConstants.spacingSmall),
                Text('ギャラリーに保存しました'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: AppConstants.spacingSmall),
                Expanded(child: Text('エクスポートに失敗しました: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

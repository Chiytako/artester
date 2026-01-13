import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/layer_stack_provider.dart';
import '../../providers/edit_provider.dart';
import '../../services/ai_segmentation_service.dart';
import 'layer_tile.dart';

/// レイヤーパネル
///
/// レイヤーリストと操作ボタンを表示するパネル
class LayerPanel extends ConsumerWidget {
  const LayerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layerStack = ref.watch(layerStackProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ヘッダー
          _buildHeader(context, ref, layerStack),

          // レイヤーリスト
          Expanded(
            child: layerStack.hasLayers
                ? ReorderableListView.builder(
                    itemCount: layerStack.layers.length,
                    reverse: true, // 最上位レイヤーが上に表示される
                    onReorder: (oldIndex, newIndex) {
                      // reverse=trueのため、インデックスを反転
                      final actualOldIndex = layerStack.layers.length - 1 - oldIndex;
                      final actualNewIndex = layerStack.layers.length - 1 - newIndex;

                      if (actualOldIndex == actualNewIndex) return;

                      final layer = layerStack.layers[actualOldIndex];
                      ref.read(layerStackProvider.notifier).reorderLayer(
                            layer.id,
                            actualNewIndex,
                          );
                    },
                    itemBuilder: (context, index) {
                      // reverse=trueのため、インデックスを反転
                      final actualIndex = layerStack.layers.length - 1 - index;
                      final layer = layerStack.layers[actualIndex];
                      final isActive = layer.id == layerStack.activeLayerId;

                      return Container(
                        key: ValueKey(layer.id),
                        child: LayerTile(
                          layer: layer,
                          isActive: isActive,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers,
                          size: 64,
                          color: AppColors.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        Text(
                          'レイヤーがありません',
                          style: TextStyle(
                            color: AppColors.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        ElevatedButton.icon(
                          onPressed: () => _showAddLayerOptions(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('レイヤーを追加'),
                        ),
                      ],
                    ),
                  ),
          ),

          // フッター（アクションボタン）
          _buildFooter(context, ref, layerStack),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    layerStack,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppConstants.spacingSmall),
          Text(
            'レイヤー',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${layerStack.layerCount}',
            style: TextStyle(
              color: AppColors.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    WidgetRef ref,
    layerStack,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // レイヤー追加
          _buildActionButton(
            icon: Icons.add,
            label: '追加',
            onPressed: layerStack.isMaxLayers
                ? null
                : () => _showAddLayerOptions(context, ref),
          ),

          // レイヤー削除
          _buildActionButton(
            icon: Icons.delete_outline,
            label: '削除',
            onPressed: layerStack.activeLayer != null
                ? () {
                    final activeId = layerStack.activeLayerId!;
                    ref.read(layerStackProvider.notifier).removeLayer(activeId);
                  }
                : null,
          ),

          // レイヤー複製
          _buildActionButton(
            icon: Icons.copy,
            label: '複製',
            onPressed: layerStack.activeLayer != null && !layerStack.isMaxLayers
                ? () {
                    final activeId = layerStack.activeLayerId!;
                    ref.read(layerStackProvider.notifier).duplicateLayer(activeId);
                  }
                : null,
          ),

          // マスク追加
          _buildActionButton(
            icon: Icons.add_photo_alternate,
            label: 'マスク',
            onPressed: layerStack.activeLayer != null
                ? () => _showMaskOptions(context, ref, layerStack)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: onPressed != null ? AppColors.primary : AppColors.onSurface.withValues(alpha: 0.3),
          iconSize: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: onPressed != null
                ? AppColors.onSurface
                : AppColors.onSurface.withValues(alpha: 0.3),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showAddLayerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('画像から追加'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 画像ピッカーを開く
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('画像選択機能は実装中です')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('現在のレイヤーを複製'),
              onTap: () {
                Navigator.pop(context);
                final layerStack = ref.read(layerStackProvider);
                if (layerStack.activeLayerId != null) {
                  ref.read(layerStackProvider.notifier).duplicateLayer(
                        layerStack.activeLayerId!,
                      );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop_square),
              title: const Text('空のレイヤーを追加'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 空のレイヤーを作成
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('空のレイヤー機能は実装中です')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMaskOptions(BuildContext context, WidgetRef ref, layerStack) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_photo_alternate),
              title: const Text('空のマスクを追加'),
              subtitle: const Text('ブラシで自由に描画'),
              onTap: () {
                Navigator.pop(context);
                final activeId = layerStack.activeLayerId!;
                ref.read(layerStackProvider.notifier).addMaskToLayer(activeId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('マスクを追加しました'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('AI被写体抽出からマスクを作成'),
              subtitle: const Text('自動的に被写体を検出'),
              onTap: () async {
                Navigator.pop(context);
                await _createMaskFromAI(context, ref, layerStack);
              },
            ),
            ListTile(
              leading: const Icon(Icons.gradient),
              title: const Text('グラデーションマスクを作成'),
              subtitle: const Text('段階的な透明度'),
              onTap: () async {
                Navigator.pop(context);
                await _createGradientMask(context, ref, layerStack);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createMaskFromAI(
    BuildContext context,
    WidgetRef ref,
    layerStack,
  ) async {
    final activeLayer = layerStack.activeLayer;
    if (activeLayer == null || activeLayer.image == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レイヤーに画像がありません')),
        );
      }
      return;
    }

    // AI被写体抽出を実行
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('AI被写体抽出を実行中...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      // シェーダーリソースを取得
      final resources = ref.read(shaderResourcesProvider);
      if (resources == null) {
        throw Exception('シェーダーリソースが準備できていません');
      }

      // AI被写体抽出を実行
      final aiService = AiSegmentationService();
      final maskImage = await aiService.generateMask(
        originalImage: activeLayer.image!,
        rotation: activeLayer.rotation,
        flipX: activeLayer.flipX,
        flipY: activeLayer.flipY,
        program: resources.program,
        neutralLut: resources.neutralLut,
      );

      // レイヤーにマスクを追加
      ref.read(layerStackProvider.notifier).addMaskToLayer(
            activeLayer.id,
            maskImage: maskImage,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI被写体抽出からマスクを作成しました'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI被写体抽出に失敗しました: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createGradientMask(
    BuildContext context,
    WidgetRef ref,
    layerStack,
  ) async {
    final activeLayer = layerStack.activeLayer;
    if (activeLayer == null || activeLayer.image == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レイヤーに画像がありません')),
        );
      }
      return;
    }

    // グラデーションマスクダイアログを表示
    final maskImage = await showDialog<ui.Image>(
      context: context,
      builder: (context) => GradientMaskDialog(
        imageWidth: activeLayer.image!.width,
        imageHeight: activeLayer.image!.height,
      ),
    );

    if (maskImage != null) {
      // レイヤーにマスクを追加
      ref.read(layerStackProvider.notifier).addMaskToLayer(
            activeLayer.id,
            maskImage: maskImage,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('グラデーションマスクを作成しました'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

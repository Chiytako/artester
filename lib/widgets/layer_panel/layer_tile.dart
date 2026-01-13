import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/layer.dart' as model;
import '../../providers/layer_stack_provider.dart';

/// レイヤータイル
///
/// レイヤーリスト内の各レイヤーを表示するタイル
class LayerTile extends ConsumerWidget {
  final model.Layer layer;
  final bool isActive;

  const LayerTile({
    super.key,
    required this.layer,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(layerStackProvider.notifier).setActiveLayer(layer.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSmall,
          vertical: AppConstants.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingSmall),
          child: Row(
            children: [
              // サムネイル
              _buildThumbnail(),
              const SizedBox(width: AppConstants.spacingSmall),

              // レイヤー情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      layer.name,
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(layer.opacity * 100).toInt()}% • ${layer.blendMode.displayName}',
                      style: TextStyle(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // アクションボタン
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // マスクアイコン
                  if (layer.hasMask)
                    Icon(
                      Icons.visibility_off,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  const SizedBox(width: AppConstants.spacingXSmall),

                  // 表示/非表示トグル
                  IconButton(
                    icon: Icon(
                      layer.isVisible ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    color: layer.isVisible ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.3),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref.read(layerStackProvider.notifier).toggleLayerVisibility(layer.id);
                    },
                  ),

                  const SizedBox(width: AppConstants.spacingXSmall),

                  // メニュー
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.onSurface,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) => _handleMenuAction(context, ref, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: AppConstants.spacingSmall),
                            Text('複製'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: AppConstants.spacingSmall),
                            Text('名前変更'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_mask',
                        child: Row(
                          children: [
                            Icon(Icons.add_photo_alternate, size: 18),
                            SizedBox(width: AppConstants.spacingSmall),
                            Text('マスク追加'),
                          ],
                        ),
                      ),
                      if (layer.hasMask)
                        const PopupMenuItem(
                          value: 'remove_mask',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: AppConstants.spacingSmall),
                              Text('マスク削除'),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppColors.error),
                            SizedBox(width: AppConstants.spacingSmall),
                            Text('削除', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: layer.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              child: RawImage(
                image: layer.image,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.image_not_supported,
              color: AppColors.onSurface.withValues(alpha: 0.3),
            ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    final notifier = ref.read(layerStackProvider.notifier);

    switch (action) {
      case 'duplicate':
        notifier.duplicateLayer(layer.id);
        break;
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'add_mask':
        notifier.addMaskToLayer(layer.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('マスクを追加しました')),
        );
        break;
      case 'remove_mask':
        notifier.removeMaskFromLayer(layer.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('マスクを削除しました')),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: layer.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レイヤー名を変更'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'レイヤー名を入力',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(layerStackProvider.notifier).renameLayer(
                      layer.id,
                      controller.text,
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('変更'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レイヤーを削除'),
        content: Text('「${layer.name}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(layerStackProvider.notifier).removeLayer(layer.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

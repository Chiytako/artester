import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../models/mask_tool.dart';
import '../../providers/mask_edit_provider.dart';

/// マスク編集ツールバー
///
/// ブラシサイズ、硬さ、不透明度、ツール選択などを表示
class MaskToolbar extends ConsumerWidget {
  const MaskToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(maskEditSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ツール選択
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MaskTool.values.take(3).map((tool) {
              // ブラシ、消しゴム、グラデーションのみ表示
              final isSelected = settings.tool == tool;
              return _buildToolButton(
                tool: tool,
                isSelected: isSelected,
                onTap: () {
                  ref.read(maskEditSettingsProvider.notifier).setTool(tool);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppConstants.spacingMedium),

          // ブラシサイズ
          _buildSlider(
            label: 'サイズ',
            value: settings.brushSize,
            min: 1,
            max: 500,
            divisions: 499,
            onChanged: (value) {
              ref.read(maskEditSettingsProvider.notifier).setBrushSize(value);
            },
          ),

          const SizedBox(height: AppConstants.spacingSmall),

          // ブラシの硬さ
          _buildSlider(
            label: '硬さ',
            value: settings.hardness,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (value) {
              ref.read(maskEditSettingsProvider.notifier).setHardness(value);
            },
          ),

          const SizedBox(height: AppConstants.spacingSmall),

          // 不透明度
          _buildSlider(
            label: '不透明度',
            value: settings.opacity,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (value) {
              ref.read(maskEditSettingsProvider.notifier).setOpacity(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required MaskTool tool,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? tool.color.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? tool.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              color: isSelected ? tool.color : AppColors.onSurface,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              tool.displayName,
              style: TextStyle(
                color: isSelected ? tool.color : AppColors.onSurface,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 45,
          child: Text(
            label == 'サイズ'
                ? value.toInt().toString()
                : (value * 100).toInt().toString() + '%',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

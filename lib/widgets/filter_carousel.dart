import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/filter_preset.dart';
import '../providers/edit_provider.dart';

/// LUTフィルターのプリセット定義
class LutFilterPreset {
  final String id;
  final String name;
  final String? assetPath;
  final String? generatedType;
  final IconData? icon;

  const LutFilterPreset({
    required this.id,
    required this.name,
    this.assetPath,
    this.generatedType,
    this.icon,
  });

  bool get isGenerated => generatedType != null;
  bool get isOriginal => id == 'none';
}

/// 利用可能なフィルタープリセット
const List<LutFilterPreset> availableFilters = [
  LutFilterPreset(id: 'none', name: 'Original', icon: Icons.filter_none),
  LutFilterPreset(
    id: 'generated_warm',
    name: 'Warm',
    generatedType: 'warm',
    icon: Icons.wb_sunny,
  ),
  LutFilterPreset(
    id: 'generated_cool',
    name: 'Cool',
    generatedType: 'cool',
    icon: Icons.ac_unit,
  ),
  LutFilterPreset(
    id: 'generated_vintage',
    name: 'Vintage',
    generatedType: 'vintage',
    icon: Icons.photo_album,
  ),
  LutFilterPreset(
    id: 'generated_cinematic',
    name: 'Cinematic',
    generatedType: 'cinematic',
    icon: Icons.movie,
  ),
  // ここにカスタムLUTを追加
  // LutFilterPreset(id: 'custom_1', name: 'Custom', assetPath: 'assets/luts/custom.png'),
];

/// 横スクロールのLUTフィルターカルーセル
class FilterCarousel extends ConsumerWidget {
  const FilterCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(editProvider);
    final currentLutPath = editState.activeLutPath;
    final userPresets = ref.watch(userPresetsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.filter, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (currentLutPath != null)
                TextButton(
                  onPressed: () => ref.read(editProvider.notifier).clearLut(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            // +1 for "Add Preset" button at the beginning
            // + userPresets.length for user presets
            itemCount: 1 + availableFilters.length + userPresets.length,
            itemBuilder: (context, index) {
              // First item: Add Preset button
              if (index == 0) {
                return _AddPresetTile(
                  onTap: () => _showSavePresetDialog(context, ref),
                );
              }

              // User presets
              final userPresetIndex = index - 1;
              if (userPresetIndex < userPresets.length) {
                final preset = userPresets[userPresetIndex];
                final isSelected = _isUserPresetSelected(preset, editState);
                return _UserPresetTile(
                  preset: preset,
                  isSelected: isSelected,
                  onTap: () => _applyUserPreset(ref, preset),
                  onLongPress:
                      () => _showDeletePresetDialog(context, ref, preset),
                );
              }

              // Built-in filters
              final filterIndex = index - 1 - userPresets.length;
              final filter = availableFilters[filterIndex];
              final isSelected = _isFilterSelected(filter, currentLutPath);

              return _FilterTile(
                filter: filter,
                isSelected: isSelected,
                onTap: () => _applyFilter(ref, filter),
              );
            },
          ),
        ),
        // LUT強度スライダー（LUTが選択されている場合のみ表示）
        if (currentLutPath != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              children: [
                const Text(
                  'Intensity',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.amber,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.amber,
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: editState.lutIntensity,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        ref
                            .read(editProvider.notifier)
                            .updateLutIntensity(value);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(editState.lutIntensity * 100).round()}%',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isFilterSelected(LutFilterPreset filter, String? currentPath) {
    if (filter.isOriginal && currentPath == null) {
      return true;
    }
    if (filter.isGenerated &&
        currentPath == 'generated:${filter.generatedType}') {
      return true;
    }
    if (filter.assetPath != null && currentPath == filter.assetPath) {
      return true;
    }
    return false;
  }

  bool _isUserPresetSelected(FilterPreset preset, dynamic editState) {
    return editState.currentPresetId == preset.id;
  }

  void _applyFilter(WidgetRef ref, LutFilterPreset filter) {
    final notifier = ref.read(editProvider.notifier);

    if (filter.isOriginal) {
      notifier.clearLut();
    } else if (filter.isGenerated) {
      notifier.useGeneratedLut(filter.generatedType!);
    } else if (filter.assetPath != null) {
      notifier.setLut(filter.assetPath);
    }
  }

  void _applyUserPreset(WidgetRef ref, FilterPreset preset) {
    final notifier = ref.read(editProvider.notifier);
    notifier.applyPreset(preset);

    // LUTパスがあればLUTも適用
    if (preset.lutPath != null) {
      if (preset.lutPath!.startsWith('generated:')) {
        final lutType = preset.lutPath!.replaceFirst('generated:', '');
        notifier.useGeneratedLut(lutType);
      } else {
        notifier.setLut(preset.lutPath);
      }
    }
  }

  void _showSavePresetDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'プリセットを保存',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'プリセット名',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  Navigator.pop(context);

                  try {
                    final preset = await ref
                        .read(editProvider.notifier)
                        .saveCurrentAsPreset(name);
                    ref.read(userPresetsProvider.notifier).addPreset(preset);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('「$name」を保存しました'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('保存に失敗しました: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: const Text('保存', style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
    );
  }

  void _showDeletePresetDialog(
    BuildContext context,
    WidgetRef ref,
    FilterPreset preset,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'プリセットを削除',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '「${preset.name}」を削除しますか？',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(userPresetsProvider.notifier)
                      .deletePreset(preset.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('「${preset.name}」を削除しました'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

/// プリセット追加タイル
class _AddPresetTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPresetTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 193, 7, 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.5),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.amber, size: 28),
              SizedBox(height: 6),
              Text(
                'Save',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ユーザープリセットタイル
class _UserPresetTile extends StatelessWidget {
  final FilterPreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _UserPresetTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromRGBO(139, 195, 74, 0.2)
                    : const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.lightGreen : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromRGBO(139, 195, 74, 0.2)
                          : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: isSelected ? Colors.lightGreen : Colors.white54,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                preset.name,
                style: TextStyle(
                  color: isSelected ? Colors.lightGreen : Colors.white70,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 個別のフィルタータイル
class _FilterTile extends StatelessWidget {
  final LutFilterPreset filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color.fromRGBO(255, 193, 7, 0.2)
                    : const Color.fromRGBO(255, 255, 255, 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.amber : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アイコン
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromRGBO(255, 193, 7, 0.2)
                          : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  filter.icon ?? Icons.photo_filter,
                  color: isSelected ? Colors.amber : Colors.white54,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              // フィルター名
              Text(
                filter.name,
                style: TextStyle(
                  color: isSelected ? Colors.amber : Colors.white70,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

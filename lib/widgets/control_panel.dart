import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_carousel.dart';
import 'parameter_slider.dart';
import '../providers/edit_provider.dart';

/// パラメータ定義
class ParameterDef {
  final String key;
  final String label;
  final IconData icon;
  final double min;
  final double max;

  const ParameterDef({
    required this.key,
    required this.label,
    required this.icon,
    this.min = -1.0,
    this.max = 1.0,
  });
}

/// カテゴリ定義
class CategoryDef {
  final String id;
  final String label;
  final IconData icon;
  final List<ParameterDef> parameters;

  const CategoryDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.parameters,
  });
}

/// カテゴリ一覧
const List<CategoryDef> categories = [
  CategoryDef(
    id: 'light',
    label: 'Light',
    icon: Icons.wb_sunny,
    parameters: [
      ParameterDef(key: 'exposure', label: 'Exposure', icon: Icons.exposure),
      ParameterDef(
        key: 'brightness',
        label: 'Brightness',
        icon: Icons.brightness_6,
      ),
      ParameterDef(key: 'contrast', label: 'Contrast', icon: Icons.contrast),
      ParameterDef(
        key: 'highlight',
        label: 'Highlights',
        icon: Icons.wb_incandescent,
      ),
      ParameterDef(key: 'shadow', label: 'Shadows', icon: Icons.nights_stay),
    ],
  ),
  CategoryDef(
    id: 'color',
    label: 'Color',
    icon: Icons.palette,
    parameters: [
      ParameterDef(key: 'saturation', label: 'Saturation', icon: Icons.palette),
      ParameterDef(
        key: 'temperature',
        label: 'Temperature',
        icon: Icons.thermostat,
      ),
      ParameterDef(key: 'tint', label: 'Tint', icon: Icons.color_lens),
    ],
  ),
  CategoryDef(
    id: 'effect',
    label: 'Effect',
    icon: Icons.auto_fix_high,
    parameters: [
      ParameterDef(
        key: 'vignette',
        label: 'Vignette',
        icon: Icons.vignette,
        min: 0.0,
        max: 1.0,
      ),
      ParameterDef(
        key: 'grain',
        label: 'Grain',
        icon: Icons.grain,
        min: 0.0,
        max: 1.0,
      ),
    ],
  ),
  CategoryDef(
    id: 'geometry',
    label: 'Geometry',
    icon: Icons.crop_rotate,
    parameters: [],
  ),
  CategoryDef(
    id: 'subject',
    label: 'Subject',
    icon: Icons.person_outline,
    parameters: [
      ParameterDef(
        key: 'bgSaturation',
        label: 'Bg Saturation',
        icon: Icons.palette_outlined,
      ),
      ParameterDef(
        key: 'bgExposure',
        label: 'Bg Exposure',
        icon: Icons.exposure_outlined,
      ),
    ],
  ),
];

/// 選択中のカテゴリを管理するプロバイダー
final selectedCategoryProvider = StateProvider<String>((ref) => 'light');

/// 画面下部のコントロールパネル
///
/// カテゴリータブ（Light/Color/Effect）とスライダーリストを提供。
class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final currentCategory = categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => categories.first,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color.fromRGBO(0, 0, 0, 0.85),
            Color.fromRGBO(0, 0, 0, 0.95),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // フィルターカルーセル
            const FilterCarousel(),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),

            // カテゴリータブ
            _buildCategoryTabs(ref, selectedCategoryId),
            const SizedBox(height: 12),

            // パラメータースライダーリスト または 特殊コントロール
            if (currentCategory.id == 'geometry')
              _buildGeometryControls(context, ref)
            else if (currentCategory.id == 'subject')
              _buildSubjectControls(context, ref)
            else
              _buildParameterSliders(currentCategory),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// カテゴリータブ（Light / Color / Effect）
  Widget _buildCategoryTabs(WidgetRef ref, String selectedId) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((category) {
          final isSelected = category.id == selectedId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = category.id;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromRGBO(255, 193, 7, 0.25)
                      : const Color.fromRGBO(255, 255, 255, 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected ? Colors.amber : Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.label,
                      style: TextStyle(
                        color: isSelected ? Colors.amber : Colors.white60,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 選択中カテゴリのパラメータースライダー
  Widget _buildParameterSliders(CategoryDef category) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: category.parameters.length,
        itemBuilder: (context, index) {
          final param = category.parameters[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ParameterSlider(
              parameterKey: param.key,
              label: param.label,
              icon: param.icon,
              min: param.min,
              max: param.max,
            ),
          );
        },
      ),
    );
  }

  /// ジオメトリ操作ボタン群
  Widget _buildGeometryControls(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _GeometryButton(
              icon: Icons.rotate_left,
              label: 'Left',
              onTap: () => ref.read(editProvider.notifier).rotateLeft(),
            ),
            _GeometryButton(
              icon: Icons.rotate_right,
              label: 'Right',
              onTap: () => ref.read(editProvider.notifier).rotate90(),
            ),
            _GeometryButton(
              icon: Icons.swap_horiz,
              label: 'Flip H',
              onTap: () => ref.read(editProvider.notifier).flipHorizontal(),
            ),
            _GeometryButton(
              icon: Icons.swap_vert,
              label: 'Flip V',
              onTap: () => ref.read(editProvider.notifier).flipVertical(),
            ),
            _GeometryButton(
              icon: Icons.crop,
              label: 'Crop',
              onTap: () {
                final resources = ref.read(shaderResourcesProvider);
                if (resources != null) {
                  ref
                      .read(editProvider.notifier)
                      .cropImage(
                        context,
                        resources.program,
                        resources.neutralLut,
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shader resources not ready')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 被写体コントロール（被写体検出・背景調整）
  Widget _buildSubjectControls(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(editProvider);
    final hasMask = editState.hasMask;

    if (editState.isAiProcessing) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.amber),
              SizedBox(height: 16),
              Text('AI Processing...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (!hasMask) {
      return SizedBox(
        height: 160,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Subject Detection Section
                _buildAiFeatureCard(
                  context: context,
                  ref: ref,
                  icon: Icons.auto_awesome,
                  title: 'Subject Detection',
                  description: 'Separate subject from background',
                  buttonLabel: 'Detect Subject',
                  onPressed: () async {
                    final resources = ref.read(shaderResourcesProvider);
                    if (resources != null) {
                      try {
                        await ref
                            .read(editProvider.notifier)
                            .runAiSegmentation(
                              resources.program,
                              resources.neutralLut,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subject detection completed!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Detection failed: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shader resources not ready'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Show background adjustment sliders + Style Transfer
      return SizedBox(
        height: 160,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // Background Adjustments Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Background Adjustments',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(editProvider.notifier).clearMask(),
                      icon: const Icon(
                        Icons.clear,
                        size: 14,
                        color: Colors.white60,
                      ),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              // Background sliders
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ParameterSlider(
                      parameterKey: 'bgSaturation',
                      label: 'Bg Saturation',
                      icon: Icons.palette_outlined,
                    ),
                    const SizedBox(height: 4),
                    ParameterSlider(
                      parameterKey: 'bgExposure',
                      label: 'Bg Exposure',
                      icon: Icons.exposure_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// AI機能カード（共通レイアウト）
  Widget _buildAiFeatureCard({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.amber),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow, size: 16),
          label: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _GeometryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GeometryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

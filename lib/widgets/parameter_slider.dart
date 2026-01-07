import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/edit_provider.dart';

/// パラメータ設定用のスライダーウィジェット
class ParameterSlider extends ConsumerWidget {
  final String parameterKey;
  final String label;
  final double min;
  final double max;
  final IconData? icon;

  const ParameterSlider({
    super.key,
    required this.parameterKey,
    required this.label,
    this.min = -1.0,
    this.max = 1.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editState = ref.watch(editProvider);
    final value = editState.getParameter(parameterKey);
    final notifier = ref.read(editProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white70),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => notifier.resetParameter(parameterKey),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatValue(value),
                    style: TextStyle(
                      color: value != 0 ? Colors.amber : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.amber,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: const Color.fromRGBO(255, 193, 7, 0.3),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: (newValue) {
                notifier.updateParameter(parameterKey, newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(double value) {
    final intValue = (value * 100).round();
    return intValue >= 0 ? '+$intValue' : '$intValue';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/edit_provider.dart';

/// パラメータ設定用のスライダーウィジェット
class ParameterSlider extends ConsumerStatefulWidget {
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
  ConsumerState<ParameterSlider> createState() => _ParameterSliderState();
}

class _ParameterSliderState extends ConsumerState<ParameterSlider> {
  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProvider);
    final value = editState.getParameter(widget.parameterKey);
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
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: Colors.white70),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => notifier.resetParameter(widget.parameterKey),
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
              value: value.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              onChanged: (newValue) {
                // スライダー移動中は履歴を保存しない
                notifier.updateParameter(widget.parameterKey, newValue, saveHistory: false);
              },
              onChangeEnd: (newValue) {
                // スライダー操作終了時に履歴を保存
                notifier.updateParameter(widget.parameterKey, newValue, saveHistory: true);
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

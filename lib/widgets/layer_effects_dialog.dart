import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer_effect.dart';

/// レイヤーエフェクト設定ダイアログ
class LayerEffectsDialog extends ConsumerStatefulWidget {
  final LayerEffects? initialEffects;

  const LayerEffectsDialog({
    super.key,
    this.initialEffects,
  });

  @override
  ConsumerState<LayerEffectsDialog> createState() =>
      _LayerEffectsDialogState();
}

class _LayerEffectsDialogState extends ConsumerState<LayerEffectsDialog> {
  late LayerEffects _effects;

  @override
  void initState() {
    super.initState();
    _effects = widget.initialEffects ?? const LayerEffects();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'レイヤーエフェクト',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_effects),
                      child: const Text('適用'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // エフェクトリスト
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropShadowSection(),
                    const Divider(),
                    _buildStrokeSection(),
                    const Divider(),
                    _buildOuterGlowSection(),
                    const Divider(),
                    _buildInnerGlowSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropShadowSection() {
    return ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: _effects.dropShadow?.enabled ?? false,
            onChanged: (value) {
              setState(() {
                if (_effects.dropShadow == null) {
                  _effects = _effects.copyWith(
                    dropShadow: const DropShadowEffect(),
                  );
                } else {
                  _effects = _effects.copyWith(
                    dropShadow: _effects.dropShadow!.copyWith(enabled: value),
                  );
                }
              });
            },
          ),
          const Text('ドロップシャドウ'),
        ],
      ),
      initiallyExpanded: _effects.dropShadow?.enabled ?? false,
      children: [
        if (_effects.dropShadow != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildColorPicker(
                  'シャドウカラー',
                  Color(_effects.dropShadow!.color),
                  (color) {
                    setState(() {
                      _effects = _effects.copyWith(
                        dropShadow: _effects.dropShadow!.copyWith(
                          color: color.value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '不透明度',
                  _effects.dropShadow!.opacity,
                  0.0,
                  1.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        dropShadow: _effects.dropShadow!.copyWith(
                          opacity: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '角度',
                  _effects.dropShadow!.angle,
                  0.0,
                  360.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        dropShadow: _effects.dropShadow!.copyWith(
                          angle: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '距離',
                  _effects.dropShadow!.distance,
                  0.0,
                  50.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        dropShadow: _effects.dropShadow!.copyWith(
                          distance: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  'サイズ',
                  _effects.dropShadow!.size,
                  0.0,
                  50.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        dropShadow: _effects.dropShadow!.copyWith(
                          size: value,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStrokeSection() {
    return ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: _effects.stroke?.enabled ?? false,
            onChanged: (value) {
              setState(() {
                if (_effects.stroke == null) {
                  _effects = _effects.copyWith(
                    stroke: const StrokeEffect(),
                  );
                } else {
                  _effects = _effects.copyWith(
                    stroke: _effects.stroke!.copyWith(enabled: value),
                  );
                }
              });
            },
          ),
          const Text('境界線'),
        ],
      ),
      initiallyExpanded: _effects.stroke?.enabled ?? false,
      children: [
        if (_effects.stroke != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildColorPicker(
                  '境界線カラー',
                  Color(_effects.stroke!.color),
                  (color) {
                    setState(() {
                      _effects = _effects.copyWith(
                        stroke: _effects.stroke!.copyWith(
                          color: color.value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '不透明度',
                  _effects.stroke!.opacity,
                  0.0,
                  1.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        stroke: _effects.stroke!.copyWith(
                          opacity: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  'サイズ',
                  _effects.stroke!.size,
                  1.0,
                  20.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        stroke: _effects.stroke!.copyWith(
                          size: value,
                        ),
                      );
                    });
                  },
                ),
                _buildDropdown<StrokePosition>(
                  '位置',
                  _effects.stroke!.position,
                  const [
                    StrokePosition.outside,
                    StrokePosition.center,
                    StrokePosition.inside,
                  ],
                  (position) {
                    switch (position) {
                      case StrokePosition.outside:
                        return '外側';
                      case StrokePosition.center:
                        return '中央';
                      case StrokePosition.inside:
                        return '内側';
                    }
                  },
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        stroke: _effects.stroke!.copyWith(
                          position: value,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOuterGlowSection() {
    return ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: _effects.outerGlow?.enabled ?? false,
            onChanged: (value) {
              setState(() {
                if (_effects.outerGlow == null) {
                  _effects = _effects.copyWith(
                    outerGlow: const GlowEffect(),
                  );
                } else {
                  _effects = _effects.copyWith(
                    outerGlow: _effects.outerGlow!.copyWith(enabled: value),
                  );
                }
              });
            },
          ),
          const Text('外側の光彩'),
        ],
      ),
      initiallyExpanded: _effects.outerGlow?.enabled ?? false,
      children: [
        if (_effects.outerGlow != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildColorPicker(
                  'グローカラー',
                  Color(_effects.outerGlow!.color),
                  (color) {
                    setState(() {
                      _effects = _effects.copyWith(
                        outerGlow: _effects.outerGlow!.copyWith(
                          color: color.value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '不透明度',
                  _effects.outerGlow!.opacity,
                  0.0,
                  1.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        outerGlow: _effects.outerGlow!.copyWith(
                          opacity: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  'サイズ',
                  _effects.outerGlow!.size,
                  0.0,
                  50.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        outerGlow: _effects.outerGlow!.copyWith(
                          size: value,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInnerGlowSection() {
    return ExpansionTile(
      title: Row(
        children: [
          Checkbox(
            value: _effects.innerGlow?.enabled ?? false,
            onChanged: (value) {
              setState(() {
                if (_effects.innerGlow == null) {
                  _effects = _effects.copyWith(
                    innerGlow: const GlowEffect(),
                  );
                } else {
                  _effects = _effects.copyWith(
                    innerGlow: _effects.innerGlow!.copyWith(enabled: value),
                  );
                }
              });
            },
          ),
          const Text('内側の光彩'),
        ],
      ),
      initiallyExpanded: _effects.innerGlow?.enabled ?? false,
      children: [
        if (_effects.innerGlow != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildColorPicker(
                  'グローカラー',
                  Color(_effects.innerGlow!.color),
                  (color) {
                    setState(() {
                      _effects = _effects.copyWith(
                        innerGlow: _effects.innerGlow!.copyWith(
                          color: color.value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  '不透明度',
                  _effects.innerGlow!.opacity,
                  0.0,
                  1.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        innerGlow: _effects.innerGlow!.copyWith(
                          opacity: value,
                        ),
                      );
                    });
                  },
                ),
                _buildSlider(
                  'サイズ',
                  _effects.innerGlow!.size,
                  0.0,
                  50.0,
                  (value) {
                    setState(() {
                      _effects = _effects.copyWith(
                        innerGlow: _effects.innerGlow!.copyWith(
                          size: value,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                final result = await showDialog<Color>(
                  context: context,
                  builder: (context) => _ColorPickerDialog(initialColor: color),
                );
                if (result != null) {
                  onChanged(result);
                }
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    value.toStringAsFixed(1),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T value,
    List<T> items,
    String Function(T) itemLabel,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// シンプルなカラーピッカーダイアログ
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color;
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    final hsv = HSVColor.fromColor(_color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColor() {
    setState(() {
      _color = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'カラー選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: _color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            _buildColorSlider('色相', _hue, 0, 360, (value) {
              setState(() {
                _hue = value;
                _updateColor();
              });
            }),
            _buildColorSlider('彩度', _saturation, 0, 1, (value) {
              setState(() {
                _saturation = value;
                _updateColor();
              });
            }),
            _buildColorSlider('明度', _value, 0, 1, (value) {
              setState(() {
                _value = value;
                _updateColor();
              });
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_color),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value.toStringAsFixed(max > 2 ? 0 : 2),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

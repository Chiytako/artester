import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adjustment_layer.dart';

/// 調整レイヤー設定ダイアログ
class AdjustmentLayerDialog extends ConsumerStatefulWidget {
  final AdjustmentLayerData? initialData;

  const AdjustmentLayerDialog({
    super.key,
    this.initialData,
  });

  @override
  ConsumerState<AdjustmentLayerDialog> createState() =>
      _AdjustmentLayerDialogState();
}

class _AdjustmentLayerDialogState extends ConsumerState<AdjustmentLayerDialog> {
  late AdjustmentType _selectedType;
  late AdjustmentLayerData _adjustmentData;

  @override
  void initState() {
    super.initState();
    _selectedType =
        widget.initialData?.type ?? AdjustmentType.brightnessContrast;
    _adjustmentData = widget.initialData ?? _createDefaultData(_selectedType);
  }

  AdjustmentLayerData _createDefaultData(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.hueSaturation:
        return AdjustmentLayerData.hueSaturation();
      case AdjustmentType.brightnessContrast:
        return AdjustmentLayerData.brightnessContrast();
      case AdjustmentType.exposure:
        return AdjustmentLayerData.exposure();
      case AdjustmentType.colorBalance:
        return AdjustmentLayerData.colorBalance();
      case AdjustmentType.colorFilter:
        return AdjustmentLayerData.colorFilter();
      case AdjustmentType.invert:
        return AdjustmentLayerData.invert();
      case AdjustmentType.posterize:
        return AdjustmentLayerData.posterize(levels: 4);
      default:
        return AdjustmentLayerData.brightnessContrast();
    }
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
                  '調整レイヤー',
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
                      onPressed: () =>
                          Navigator.of(context).pop(_adjustmentData),
                      child: const Text('適用'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // 調整タイプ選択
            DropdownButton<AdjustmentType>(
              value: _selectedType,
              isExpanded: true,
              items: AdjustmentType.values.map((type) {
                return DropdownMenuItem<AdjustmentType>(
                  value: type,
                  child: Text(_getAdjustmentTypeName(type)),
                );
              }).toList(),
              onChanged: (newType) {
                if (newType != null) {
                  setState(() {
                    _selectedType = newType;
                    _adjustmentData = _createDefaultData(newType);
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 調整パラメーター
            Expanded(
              child: SingleChildScrollView(
                child: _buildAdjustmentControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAdjustmentTypeName(AdjustmentType type) {
    switch (type) {
      case AdjustmentType.hueSaturation:
        return '色相・彩度';
      case AdjustmentType.brightnessContrast:
        return '明度・コントラスト';
      case AdjustmentType.levels:
        return 'レベル補正';
      case AdjustmentType.curves:
        return 'トーンカーブ';
      case AdjustmentType.colorBalance:
        return 'カラーバランス';
      case AdjustmentType.exposure:
        return '露光量';
      case AdjustmentType.vibrance:
        return '自然な彩度';
      case AdjustmentType.colorFilter:
        return 'カラーフィルター';
      case AdjustmentType.invert:
        return '階調反転';
      case AdjustmentType.posterize:
        return 'ポスタリゼーション';
    }
  }

  Widget _buildAdjustmentControls() {
    switch (_selectedType) {
      case AdjustmentType.hueSaturation:
        return _buildHueSaturationControls();
      case AdjustmentType.brightnessContrast:
        return _buildBrightnessContrastControls();
      case AdjustmentType.exposure:
        return _buildExposureControls();
      case AdjustmentType.colorBalance:
        return _buildColorBalanceControls();
      case AdjustmentType.colorFilter:
        return _buildColorFilterControls();
      case AdjustmentType.invert:
        return const Center(
          child: Text('階調を反転します（パラメーターなし）'),
        );
      case AdjustmentType.posterize:
        return _buildPosterizeControls();
      default:
        return const Center(
          child: Text('この調整タイプは現在実装中です'),
        );
    }
  }

  Widget _buildHueSaturationControls() {
    final adjustment = _adjustmentData.hueSaturation!;
    return Column(
      children: [
        _buildSlider(
          '色相',
          adjustment.hue,
          -180.0,
          180.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                hueSaturation: adjustment.copyWith(hue: value),
              );
            });
          },
        ),
        _buildSlider(
          '彩度',
          adjustment.saturation,
          -100.0,
          100.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                hueSaturation: adjustment.copyWith(saturation: value),
              );
            });
          },
        ),
        _buildSlider(
          '明度',
          adjustment.lightness,
          -100.0,
          100.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                hueSaturation: adjustment.copyWith(lightness: value),
              );
            });
          },
        ),
        CheckboxListTile(
          title: const Text('カラー化'),
          value: adjustment.colorize,
          onChanged: (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                hueSaturation: adjustment.copyWith(colorize: value ?? false),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildBrightnessContrastControls() {
    final adjustment = _adjustmentData.brightnessContrast!;
    return Column(
      children: [
        _buildSlider(
          '明度',
          adjustment.brightness,
          -100.0,
          100.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                brightnessContrast: adjustment.copyWith(brightness: value),
              );
            });
          },
        ),
        _buildSlider(
          'コントラスト',
          adjustment.contrast,
          -100.0,
          100.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                brightnessContrast: adjustment.copyWith(contrast: value),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildExposureControls() {
    final adjustment = _adjustmentData.exposure!;
    return Column(
      children: [
        _buildSlider(
          '露光量',
          adjustment.exposure,
          -5.0,
          5.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                exposure: adjustment.copyWith(exposure: value),
              );
            });
          },
        ),
        _buildSlider(
          'オフセット',
          adjustment.offset,
          -0.5,
          0.5,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                exposure: adjustment.copyWith(offset: value),
              );
            });
          },
        ),
        _buildSlider(
          'ガンマ補正',
          adjustment.gammaCorrection,
          0.01,
          3.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                exposure: adjustment.copyWith(gammaCorrection: value),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorBalanceControls() {
    final adjustment = _adjustmentData.colorBalance!;
    return Column(
      children: [
        const Text(
          'シャドウ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildColorBalanceSlider(
          'シアン ← → レッド',
          adjustment.shadowsCyanRed,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(shadowsCyanRed: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'マゼンタ ← → グリーン',
          adjustment.shadowsMagentaGreen,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(shadowsMagentaGreen: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'イエロー ← → ブルー',
          adjustment.shadowsYellowBlue,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(shadowsYellowBlue: value),
              );
            });
          },
        ),
        const Divider(),
        const Text(
          'ミッドトーン',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildColorBalanceSlider(
          'シアン ← → レッド',
          adjustment.midtonesCyanRed,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(midtonesCyanRed: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'マゼンタ ← → グリーン',
          adjustment.midtonesMagentaGreen,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(midtonesMagentaGreen: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'イエロー ← → ブルー',
          adjustment.midtonesYellowBlue,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(midtonesYellowBlue: value),
              );
            });
          },
        ),
        const Divider(),
        const Text(
          'ハイライト',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildColorBalanceSlider(
          'シアン ← → レッド',
          adjustment.highlightsCyanRed,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(highlightsCyanRed: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'マゼンタ ← → グリーン',
          adjustment.highlightsMagentaGreen,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance:
                    adjustment.copyWith(highlightsMagentaGreen: value),
              );
            });
          },
        ),
        _buildColorBalanceSlider(
          'イエロー ← → ブルー',
          adjustment.highlightsYellowBlue,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance: adjustment.copyWith(highlightsYellowBlue: value),
              );
            });
          },
        ),
        CheckboxListTile(
          title: const Text('輝度を保持'),
          value: adjustment.preserveLuminosity,
          onChanged: (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorBalance:
                    adjustment.copyWith(preserveLuminosity: value ?? true),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorFilterControls() {
    final adjustment = _adjustmentData.colorFilter!;
    return Column(
      children: [
        _buildColorPicker(
          'フィルターカラー',
          Color(adjustment.color),
          (color) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorFilter: adjustment.copyWith(color: color.value),
              );
            });
          },
        ),
        _buildSlider(
          '濃度',
          adjustment.density,
          0.0,
          1.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorFilter: adjustment.copyWith(density: value),
              );
            });
          },
        ),
        CheckboxListTile(
          title: const Text('輝度を保持'),
          value: adjustment.preserveLuminosity,
          onChanged: (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                colorFilter:
                    adjustment.copyWith(preserveLuminosity: value ?? true),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildPosterizeControls() {
    final adjustment = _adjustmentData.posterize!;
    return Column(
      children: [
        _buildSlider(
          '階調レベル数',
          adjustment.levels.toDouble(),
          2.0,
          256.0,
          (value) {
            setState(() {
              _adjustmentData = _adjustmentData.copyWith(
                posterize: adjustment.copyWith(levels: value.round()),
              );
            });
          },
          divisions: 254,
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Row(
            children: [
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
                width: 60,
                child: Text(
                  divisions != null
                      ? value.toStringAsFixed(0)
                      : value.toStringAsFixed(1),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorBalanceSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return _buildSlider(label, value, -100.0, 100.0, onChanged);
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          GestureDetector(
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
              height: 50,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
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

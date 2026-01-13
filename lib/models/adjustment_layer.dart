import 'package:freezed_annotation/freezed_annotation.dart';

part 'adjustment_layer.freezed.dart';
part 'adjustment_layer.g.dart';

/// 調整レイヤーの種類
enum AdjustmentType {
  /// 色相・彩度
  hueSaturation('Hue/Saturation'),

  /// 明るさ・コントラスト
  brightnessContrast('Brightness/Contrast'),

  /// レベル補正
  levels('Levels'),

  /// カーブ
  curves('Curves'),

  /// カラーバランス
  colorBalance('Color Balance'),

  /// 露出
  exposure('Exposure'),

  /// 自然な彩度
  vibrance('Vibrance'),

  /// カラーフィルター
  colorFilter('Color Filter'),

  /// 反転
  invert('Invert'),

  /// ポスタリゼーション
  posterize('Posterize');

  const AdjustmentType(this.displayName);

  final String displayName;
}

/// 色相・彩度調整
@freezed
class HueSaturationAdjustment with _$HueSaturationAdjustment {
  const factory HueSaturationAdjustment({
    /// 色相（-180 to 180）
    @Default(0.0) double hue,

    /// 彩度（-100 to 100）
    @Default(0.0) double saturation,

    /// 明度（-100 to 100）
    @Default(0.0) double lightness,

    /// カラー化
    @Default(false) bool colorize,

    /// カラー化時の色相
    @Default(0.0) double colorizeHue,

    /// カラー化時の彩度
    @Default(50.0) double colorizeSaturation,
  }) = _HueSaturationAdjustment;

  factory HueSaturationAdjustment.fromJson(Map<String, dynamic> json) =>
      _$HueSaturationAdjustmentFromJson(json);
}

/// 明るさ・コントラスト調整
@freezed
class BrightnessContrastAdjustment with _$BrightnessContrastAdjustment {
  const factory BrightnessContrastAdjustment({
    /// 明るさ（-100 to 100）
    @Default(0.0) double brightness,

    /// コントラスト（-100 to 100）
    @Default(0.0) double contrast,
  }) = _BrightnessContrastAdjustment;

  factory BrightnessContrastAdjustment.fromJson(Map<String, dynamic> json) =>
      _$BrightnessContrastAdjustmentFromJson(json);
}

/// 露出調整
@freezed
class ExposureAdjustment with _$ExposureAdjustment {
  const factory ExposureAdjustment({
    /// 露出（-5.0 to 5.0）
    @Default(0.0) double exposure,

    /// オフセット（-0.5 to 0.5）
    @Default(0.0) double offset,

    /// ガンマ（0.01 to 9.99）
    @Default(1.0) double gamma,
  }) = _ExposureAdjustment;

  factory ExposureAdjustment.fromJson(Map<String, dynamic> json) =>
      _$ExposureAdjustmentFromJson(json);
}

/// カラーバランス調整
@freezed
class ColorBalanceAdjustment with _$ColorBalanceAdjustment {
  const factory ColorBalanceAdjustment({
    /// シャドウのシアン-レッド（-100 to 100）
    @Default(0.0) double shadowsCyanRed,

    /// シャドウのマゼンタ-グリーン（-100 to 100）
    @Default(0.0) double shadowsMagentaGreen,

    /// シャドウのイエロー-ブルー（-100 to 100）
    @Default(0.0) double shadowsYellowBlue,

    /// ミッドトーンのシアン-レッド（-100 to 100）
    @Default(0.0) double midtonesCyanRed,

    /// ミッドトーンのマゼンタ-グリーン（-100 to 100）
    @Default(0.0) double midtonesMagentaGreen,

    /// ミッドトーンのイエロー-ブルー（-100 to 100）
    @Default(0.0) double midtonesYellowBlue,

    /// ハイライトのシアン-レッド（-100 to 100）
    @Default(0.0) double highlightsCyanRed,

    /// ハイライトのマゼンタ-グリーン（-100 to 100）
    @Default(0.0) double highlightsMagentaGreen,

    /// ハイライトのイエロー-ブルー（-100 to 100）
    @Default(0.0) double highlightsYellowBlue,

    /// 輝度を保持
    @Default(true) bool preserveLuminosity,
  }) = _ColorBalanceAdjustment;

  factory ColorBalanceAdjustment.fromJson(Map<String, dynamic> json) =>
      _$ColorBalanceAdjustmentFromJson(json);
}

/// カラーフィルター調整
@freezed
class ColorFilterAdjustment with _$ColorFilterAdjustment {
  const factory ColorFilterAdjustment({
    /// フィルターカラー
    @Default(0xFFFF0000) int color,

    /// 濃度（0.0 to 1.0）
    @Default(0.5) double density,

    /// 輝度を保持
    @Default(true) bool preserveLuminosity,
  }) = _ColorFilterAdjustment;

  factory ColorFilterAdjustment.fromJson(Map<String, dynamic> json) =>
      _$ColorFilterAdjustmentFromJson(json);
}

/// 調整レイヤーデータ
@freezed
class AdjustmentLayerData with _$AdjustmentLayerData {
  const factory AdjustmentLayerData({
    /// 調整の種類
    required AdjustmentType type,

    /// 色相・彩度調整
    HueSaturationAdjustment? hueSaturation,

    /// 明るさ・コントラスト調整
    BrightnessContrastAdjustment? brightnessContrast,

    /// 露出調整
    ExposureAdjustment? exposure,

    /// カラーバランス調整
    ColorBalanceAdjustment? colorBalance,

    /// カラーフィルター調整
    ColorFilterAdjustment? colorFilter,

    /// 作成日時
    required DateTime createdAt,

    /// 最終更新日時
    required DateTime updatedAt,
  }) = _AdjustmentLayerData;

  factory AdjustmentLayerData.fromJson(Map<String, dynamic> json) =>
      _$AdjustmentLayerDataFromJson(json);

  /// 色相・彩度調整レイヤーを作成
  factory AdjustmentLayerData.hueSaturation() {
    final now = DateTime.now();
    return AdjustmentLayerData(
      type: AdjustmentType.hueSaturation,
      hueSaturation: const HueSaturationAdjustment(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 明るさ・コントラスト調整レイヤーを作成
  factory AdjustmentLayerData.brightnessContrast() {
    final now = DateTime.now();
    return AdjustmentLayerData(
      type: AdjustmentType.brightnessContrast,
      brightnessContrast: const BrightnessContrastAdjustment(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 露出調整レイヤーを作成
  factory AdjustmentLayerData.exposure() {
    final now = DateTime.now();
    return AdjustmentLayerData(
      type: AdjustmentType.exposure,
      exposure: const ExposureAdjustment(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// カラーバランス調整レイヤーを作成
  factory AdjustmentLayerData.colorBalance() {
    final now = DateTime.now();
    return AdjustmentLayerData(
      type: AdjustmentType.colorBalance,
      colorBalance: const ColorBalanceAdjustment(),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// カラーフィルター調整レイヤーを作成
  factory AdjustmentLayerData.colorFilter() {
    final now = DateTime.now();
    return AdjustmentLayerData(
      type: AdjustmentType.colorFilter,
      colorFilter: const ColorFilterAdjustment(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_state.freezed.dart';
part 'edit_state.g.dart';

/// 画像編集の状態を管理する不変クラス
///
/// 将来的に50以上のパラメータを追加可能な設計:
/// - parameters: 全ての調整値を格納するMap
/// - Undo/Redo対応のためcopyWithで容易にコピー可能
@freezed
class EditState with _$EditState {
  const EditState._();

  const factory EditState({
    /// 編集対象の画像（メモリ上）
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? image,

    /// LUT画像（メモリ上）
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? lutImage,

    /// 編集パラメータ（キー: パラメータ名、値: 調整値）
    /// 例: {'brightness': 0.0, 'contrast': 0.0, 'saturation': 0.0}
    @Default({}) Map<String, double> parameters,

    /// 現在適用中のプリセットID（null = プリセット未使用）
    String? currentPresetId,

    /// 画像パス（null = 画像未選択）
    String? imagePath,

    /// LUT画像パス（null = LUT未適用、'generated' = 生成済みLUT使用）
    String? activeLutPath,

    /// LUT適用強度（0.0〜1.0）
    @Default(1.0) double lutIntensity,

    /// フィルター適用強度（0.0〜1.0）
    @Default(1.0) double filterStrength,

    /// 回転状態 (0=0°, 1=90°, 2=180°, 3=270°)
    @Default(0) int rotation,

    /// 水平反転
    @Default(false) bool flipX,

    /// 垂直反転
    @Default(false) bool flipY,

    /// ローディング状態
    @Default(false) bool isLoading,
  }) = _EditState;

  factory EditState.fromJson(Map<String, dynamic> json) =>
      _$EditStateFromJson(json);

  /// デフォルトのパラメータ値
  static const Map<String, double> defaultParameters = {
    // Light
    'exposure': 0.0,
    'brightness': 0.0,
    'contrast': 0.0,
    'highlight': 0.0,
    'shadow': 0.0,
    // Color
    'saturation': 0.0,
    'temperature': 0.0,
    'tint': 0.0,
    // Effect
    'vignette': 0.0,
    'grain': 0.0,
  };

  /// 初期状態を作成
  factory EditState.initial() =>
      EditState(parameters: Map.from(defaultParameters));

  /// 特定のパラメータ値を取得（存在しない場合は0.0）
  double getParameter(String key) => parameters[key] ?? 0.0;

  /// LUTが適用されているか
  bool get hasLut => lutImage != null;

  /// パラメータがデフォルト値から変更されているか確認
  bool get isModified {
    for (final entry in parameters.entries) {
      final defaultValue = defaultParameters[entry.key] ?? 0.0;
      if (entry.value != defaultValue) return true;
    }
    // Geometry checks
    if (rotation != 0) return true;
    if (flipX) return true;
    if (flipY) return true;

    return activeLutPath != null;
  }
}

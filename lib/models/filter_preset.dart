import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_preset.freezed.dart';
part 'filter_preset.g.dart';

/// フィルタープリセットモデル
///
/// JSON化して保存・共有が可能。
/// parametersに調整値を格納し、再編集や適用が容易。
@freezed
class FilterPreset with _$FilterPreset {
  const FilterPreset._();

  const factory FilterPreset({
    /// ユニークな識別子
    required String id,

    /// プリセット名（ユーザー表示用）
    required String name,

    /// サムネイル画像パス（オプション）
    String? thumbnailPath,

    /// 調整パラメータのマップ
    /// 将来的に 'vignette', 'grain', 'split_tone_shadow' などが増えても
    /// このMapに追加するだけで対応可能
    required Map<String, double> parameters,

    /// 作成日時
    required DateTime createdAt,

    /// カテゴリ（例: 'vintage', 'portrait', 'landscape'）
    String? category,

    /// お気に入りフラグ
    @Default(false) bool isFavorite,

    /// LUTパス（LUT使用時に保存）
    String? lutPath,
  }) = _FilterPreset;

  factory FilterPreset.fromJson(Map<String, dynamic> json) =>
      _$FilterPresetFromJson(json);

  /// 現在の編集状態からプリセットを作成
  factory FilterPreset.fromEditState({
    required String id,
    required String name,
    required Map<String, double> parameters,
    String? category,
    String? lutPath,
  }) {
    return FilterPreset(
      id: id,
      name: name,
      parameters: Map.from(parameters),
      createdAt: DateTime.now(),
      category: category,
      lutPath: lutPath,
    );
  }
}

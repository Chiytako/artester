import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_group.freezed.dart';
part 'layer_group.g.dart';

/// レイヤーグループ（フォルダ）モデル
///
/// 複数のレイヤーをグループ化して管理
@freezed
class LayerGroup with _$LayerGroup {
  const LayerGroup._();

  const factory LayerGroup({
    /// グループID（ユニーク）
    required String id,

    /// グループ名
    required String name,

    /// グループ内のレイヤーID一覧
    @Default([]) List<String> layerIds,

    /// 子グループID一覧（ネスト可能）
    @Default([]) List<String> childGroupIds,

    /// グループの不透明度（0.0 - 1.0）
    @Default(1.0) double opacity,

    /// グループが展開されているか
    @Default(true) bool isExpanded,

    /// グループが表示されているか
    @Default(true) bool isVisible,

    /// グループがロックされているか
    @Default(false) bool isLocked,

    /// グループの順序
    required int order,

    /// 親グループID（ネストされている場合）
    String? parentGroupId,

    /// 作成日時
    required DateTime createdAt,

    /// 最終更新日時
    required DateTime updatedAt,
  }) = _LayerGroup;

  factory LayerGroup.fromJson(Map<String, dynamic> json) =>
      _$LayerGroupFromJson(json);

  /// 新しいグループを作成
  factory LayerGroup.create({
    required String id,
    required String name,
    required int order,
    String? parentGroupId,
  }) {
    final now = DateTime.now();
    return LayerGroup(
      id: id,
      name: name,
      order: order,
      parentGroupId: parentGroupId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// グループ内のレイヤー数
  int get layerCount => layerIds.length;

  /// グループ内に子グループがあるか
  bool get hasChildGroups => childGroupIds.isNotEmpty;

  /// グループ内にレイヤーがあるか
  bool get hasLayers => layerIds.isNotEmpty;

  /// グループが空か
  bool get isEmpty => !hasLayers && !hasChildGroups;
}

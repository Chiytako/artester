import 'package:freezed_annotation/freezed_annotation.dart';

import 'layer.dart';
import 'layer_group.dart';

part 'layer_stack.freezed.dart';
part 'layer_stack.g.dart';

/// レイヤースタックモデル
///
/// 複数のレイヤーを管理し、アクティブレイヤーを追跡
@freezed
class LayerStack with _$LayerStack {
  const LayerStack._();

  const factory LayerStack({
    /// レイヤーのリスト（order順にソート済み）
    @Default([]) List<Layer> layers,

    /// レイヤーグループのリスト
    @Default([]) List<LayerGroup> groups,

    /// アクティブなレイヤーのID
    String? activeLayerId,

    /// キャンバスサイズ（全レイヤー共通）
    required int canvasWidth,
    required int canvasHeight,

    /// 背景色（透明部分の表示色）
    @Default(0xFFFFFFFF) int backgroundColor,

    /// レイヤースタックの変更を追跡（Undo/Redo用）
    @Default(0) int version,

    /// 作成日時
    required DateTime createdAt,

    /// 最終更新日時
    required DateTime updatedAt,
  }) = _LayerStack;

  factory LayerStack.fromJson(Map<String, dynamic> json) =>
      _$LayerStackFromJson(json);

  /// 空のスタックを作成
  factory LayerStack.empty({
    required int width,
    required int height,
  }) {
    final now = DateTime.now();
    return LayerStack(
      canvasWidth: width,
      canvasHeight: height,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// アクティブなレイヤーを取得
  Layer? get activeLayer {
    if (activeLayerId == null) return null;
    try {
      return layers.firstWhere((layer) => layer.id == activeLayerId);
    } catch (e) {
      return null;
    }
  }

  /// 表示されているレイヤーのみを取得
  List<Layer> get visibleLayers =>
      layers.where((layer) => layer.isVisible).toList();

  /// レイヤーの総数
  int get layerCount => layers.length;

  /// レイヤーが存在するか
  bool get hasLayers => layers.isNotEmpty;

  /// 最大レイヤー数に達しているか
  bool get isMaxLayers => layers.length >= 20; // 最大20レイヤー

  /// 指定したIDのレイヤーを取得
  Layer? getLayerById(String id) {
    try {
      return layers.firstWhere((layer) => layer.id == id);
    } catch (e) {
      return null;
    }
  }

  /// レイヤーのインデックスを取得
  int? getLayerIndex(String id) {
    final index = layers.indexWhere((layer) => layer.id == id);
    return index >= 0 ? index : null;
  }

  /// グループが存在するか
  bool get hasGroups => groups.isNotEmpty;

  /// 指定したIDのグループを取得
  LayerGroup? getGroupById(String id) {
    try {
      return groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  /// グループ内のレイヤーを取得
  List<Layer> getLayersInGroup(String groupId) {
    final group = getGroupById(groupId);
    if (group == null) return [];

    return layers.where((layer) {
      return group.layerIds.contains(layer.id);
    }).toList();
  }

  /// レイヤーが属しているグループを取得
  LayerGroup? getLayerGroup(String layerId) {
    try {
      return groups.firstWhere(
        (group) => group.layerIds.contains(layerId),
      );
    } catch (e) {
      return null;
    }
  }
}

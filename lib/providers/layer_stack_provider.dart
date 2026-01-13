import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/layer.dart';
import '../models/layer_mask.dart';
import '../models/layer_stack.dart';
import '../models/blend_mode.dart';

/// レイヤースタック管理Provider
final layerStackProvider =
    StateNotifierProvider<LayerStackNotifier, LayerStack>((ref) {
  return LayerStackNotifier();
});

/// レイヤースタック管理Notifier
///
/// レイヤーの追加、削除、並び替え、マスク編集などを管理
class LayerStackNotifier extends StateNotifier<LayerStack> {
  LayerStackNotifier() : super(LayerStack.empty(width: 1000, height: 1000));

  final _uuid = const Uuid();

  /// 初期化（画像を読み込んだとき）
  void initialize({
    required ui.Image image,
    String? name,
  }) {
    final now = DateTime.now();
    final layer = Layer.create(
      id: _uuid.v4(),
      name: name ?? 'Background',
      image: image,
      order: 0,
    );

    state = LayerStack(
      layers: [layer],
      activeLayerId: layer.id,
      canvasWidth: image.width,
      canvasHeight: image.height,
      createdAt: now,
      updatedAt: now,
    );

    debugPrint('[LayerStack] Initialized with image ${image.width}x${image.height}');
  }

  /// レイヤーを追加
  Future<void> addLayer({
    required ui.Image image,
    String? name,
    int? insertAt,
  }) async {
    final now = DateTime.now();
    final newOrder = insertAt ?? state.layers.length;

    // 挿入位置以降のレイヤーのorderを更新
    final updatedLayers = state.layers.map((layer) {
      if (layer.order >= newOrder) {
        return layer.copyWith(order: layer.order + 1);
      }
      return layer;
    }).toList();

    final newLayer = Layer.create(
      id: _uuid.v4(),
      name: name ?? 'Layer ${state.layers.length + 1}',
      image: image,
      order: newOrder,
    );

    state = state.copyWith(
      layers: [...updatedLayers, newLayer]..sort((a, b) => a.order.compareTo(b.order)),
      activeLayerId: newLayer.id,
      updatedAt: now,
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Added layer: ${newLayer.name} at order $newOrder');
  }

  /// レイヤーを削除
  void removeLayer(String layerId) {
    final layerToRemove = state.getLayerById(layerId);
    if (layerToRemove == null) return;

    final now = DateTime.now();
    final removedOrder = layerToRemove.order;

    // 削除されたレイヤーより上のレイヤーのorderを調整
    final updatedLayers = state.layers
        .where((layer) => layer.id != layerId)
        .map((layer) {
          if (layer.order > removedOrder) {
            return layer.copyWith(order: layer.order - 1);
          }
          return layer;
        })
        .toList();

    // アクティブレイヤーが削除された場合、次のレイヤーを選択
    String? newActiveId = state.activeLayerId;
    if (state.activeLayerId == layerId) {
      if (updatedLayers.isNotEmpty) {
        // 同じorder位置か、最も近いレイヤーを選択
        final nearestLayer = updatedLayers.firstWhere(
          (layer) => layer.order >= removedOrder,
          orElse: () => updatedLayers.last,
        );
        newActiveId = nearestLayer.id;
      } else {
        newActiveId = null;
      }
    }

    state = state.copyWith(
      layers: updatedLayers,
      activeLayerId: newActiveId,
      updatedAt: now,
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Removed layer: ${layerToRemove.name}');
  }

  /// レイヤーを複製
  Future<void> duplicateLayer(String layerId) async {
    final layer = state.getLayerById(layerId);
    if (layer == null || layer.image == null) return;

    final now = DateTime.now();
    final newOrder = layer.order + 1;

    // 挿入位置以降のレイヤーのorderを更新
    final updatedLayers = state.layers.map((l) {
      if (l.order >= newOrder) {
        return l.copyWith(order: l.order + 1);
      }
      return l;
    }).toList();

    final duplicatedLayer = layer.copyWith(
      id: _uuid.v4(),
      name: '${layer.name} copy',
      order: newOrder,
      createdAt: now,
      updatedAt: now,
    );

    state = state.copyWith(
      layers: [...updatedLayers, duplicatedLayer]..sort((a, b) => a.order.compareTo(b.order)),
      activeLayerId: duplicatedLayer.id,
      updatedAt: now,
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Duplicated layer: ${layer.name}');
  }

  /// レイヤーの順序を変更
  void reorderLayer(String layerId, int newOrder) {
    final layer = state.getLayerById(layerId);
    if (layer == null) return;

    final now = DateTime.now();
    final oldOrder = layer.order;

    if (oldOrder == newOrder) return;

    // 順序を調整
    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(order: newOrder);
      } else if (oldOrder < newOrder && l.order > oldOrder && l.order <= newOrder) {
        // 上に移動: 間のレイヤーを下げる
        return l.copyWith(order: l.order - 1);
      } else if (oldOrder > newOrder && l.order >= newOrder && l.order < oldOrder) {
        // 下に移動: 間のレイヤーを上げる
        return l.copyWith(order: l.order + 1);
      }
      return l;
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: now,
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Reordered layer: ${layer.name} from $oldOrder to $newOrder');
  }

  /// アクティブレイヤーを設定
  void setActiveLayer(String layerId) {
    if (state.getLayerById(layerId) == null) return;

    state = state.copyWith(
      activeLayerId: layerId,
      updatedAt: DateTime.now(),
    );

    debugPrint('[LayerStack] Active layer: $layerId');
  }

  /// レイヤーの表示/非表示を切り替え
  void toggleLayerVisibility(String layerId) {
    final layer = state.getLayerById(layerId);
    if (layer == null) return;

    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          isVisible: !l.isVisible,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Toggled visibility: ${layer.name} -> ${!layer.isVisible}');
  }

  /// レイヤーの不透明度を設定
  void setLayerOpacity(String layerId, double opacity) {
    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          opacity: opacity.clamp(0.0, 1.0),
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );
  }

  /// レイヤーのブレンドモードを設定
  void setLayerBlendMode(String layerId, BlendMode blendMode) {
    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          blendMode: blendMode,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Set blend mode: $layerId -> ${blendMode.displayName}');
  }

  /// レイヤーにマスクを追加
  void addMaskToLayer(String layerId, {ui.Image? maskImage}) {
    final layer = state.getLayerById(layerId);
    if (layer == null) return;

    final newMask = maskImage != null
        ? LayerMask.fromAI(maskImage: maskImage)
        : LayerMask.empty().copyWith(isEnabled: true);

    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          mask: newMask,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Added mask to layer: ${layer.name}');
  }

  /// レイヤーのマスクを削除
  void removeMaskFromLayer(String layerId) {
    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          mask: LayerMask.empty(),
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Removed mask from layer: $layerId');
  }

  /// レイヤーのマスクを更新
  void updateLayerMask(String layerId, ui.Image maskImage) {
    final layer = state.getLayerById(layerId);
    if (layer == null) return;

    final updatedMask = layer.mask.copyWith(
      maskImage: maskImage,
      updatedAt: DateTime.now(),
    );

    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          mask: updatedMask,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Updated mask for layer: ${layer.name}');
  }

  /// レイヤーのパラメータを更新
  void updateLayerParameter(String layerId, String key, double value) {
    final layer = state.getLayerById(layerId);
    if (layer == null) return;

    final updatedParameters = Map<String, double>.from(layer.parameters);
    updatedParameters[key] = value;

    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          parameters: updatedParameters,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );
  }

  /// レイヤー名を変更
  void renameLayer(String layerId, String newName) {
    final updatedLayers = state.layers.map((l) {
      if (l.id == layerId) {
        return l.copyWith(
          name: newName,
          updatedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();

    state = state.copyWith(
      layers: updatedLayers,
      updatedAt: DateTime.now(),
      version: state.version + 1,
    );

    debugPrint('[LayerStack] Renamed layer: $layerId -> $newName');
  }

  /// すべてクリア
  void clear() {
    state = LayerStack.empty(
      width: state.canvasWidth,
      height: state.canvasHeight,
    );
    debugPrint('[LayerStack] Cleared all layers');
  }
}

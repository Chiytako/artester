import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'blend_mode.dart';
import 'layer_mask.dart';
import 'layer_effect.dart';
import 'adjustment_layer.dart';

part 'layer.freezed.dart';
part 'layer.g.dart';

/// レイヤーモデル
///
/// 画像編集の各レイヤーを表現
/// 画像、マスク、編集パラメータ、不透明度などを保持
@freezed
class Layer with _$Layer {
  const Layer._();

  const factory Layer({
    /// レイヤーID（ユニーク）
    required String id,

    /// レイヤー名
    required String name,

    /// レイヤー画像
    /// JsonKeyでシリアライズから除外（ui.Imageはシリアライズ不可）
    @JsonKey(includeFromJson: false, includeToJson: false) required ui.Image? image,

    /// レイヤーマスク
    required LayerMask mask,

    /// レイヤーの不透明度（0.0 - 1.0）
    @Default(1.0) double opacity,

    /// ブレンドモード
    @Default(BlendMode.normal) BlendMode blendMode,

    /// レイヤーが表示されているか
    @Default(true) bool isVisible,

    /// レイヤーがロックされているか（編集不可）
    @Default(false) bool isLocked,

    /// 編集パラメータ（明度、コントラストなど）
    /// EditStateと同じ構造
    @Default({}) Map<String, double> parameters,

    /// LUTパス
    String? lutPath,

    /// LUT適用強度（0.0 - 1.0）
    @Default(0.0) double lutIntensity,

    /// ジオメトリ変換
    @Default(0) int rotation, // 0=0°, 1=90°, 2=180°, 3=270°
    @Default(false) bool flipX,
    @Default(false) bool flipY,

    /// レイヤーの順序（0が最下層）
    required int order,

    /// サムネイル画像パス（キャッシュ用）
    String? thumbnailPath,

    /// レイヤーエフェクト
    LayerEffects? effects,

    /// 調整レイヤーデータ（調整レイヤーの場合のみ）
    AdjustmentLayerData? adjustmentData,

    /// 作成日時
    required DateTime createdAt,

    /// 最終更新日時
    required DateTime updatedAt,
  }) = _Layer;

  factory Layer.fromJson(Map<String, dynamic> json) => _$LayerFromJson(json);

  /// 新しいレイヤーを作成
  factory Layer.create({
    required String id,
    required String name,
    required ui.Image image,
    required int order,
    Map<String, double>? parameters,
  }) {
    final now = DateTime.now();
    return Layer(
      id: id,
      name: name,
      image: image,
      mask: LayerMask.empty(),
      order: order,
      parameters: parameters ?? {},
      createdAt: now,
      updatedAt: now,
    );
  }

  /// レイヤーが有効か（表示されていて、画像が存在する）
  bool get isActive => isVisible && image != null;

  /// マスクが有効か
  bool get hasMask => mask.isEnabled && mask.hasMask;

  /// レイヤーに編集が適用されているか
  bool get hasEdits =>
      parameters.values.any((v) => v != 0.0) ||
      lutIntensity > 0.0 ||
      rotation != 0 ||
      flipX ||
      flipY ||
      (effects?.hasEffects ?? false);

  /// エフェクトが有効か
  bool get hasEffects => effects?.hasEffects ?? false;

  /// 調整レイヤーかどうか
  bool get isAdjustmentLayer => adjustmentData != null;

  /// 通常のレイヤーかどうか
  bool get isNormalLayer => !isAdjustmentLayer;
}

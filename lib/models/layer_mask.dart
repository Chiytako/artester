import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_mask.freezed.dart';
part 'layer_mask.g.dart';

/// レイヤーマスクモデル
///
/// 各レイヤーに適用するマスク情報を保持
/// マスクは白（表示）と黒（非表示）のグレースケール画像
@freezed
class LayerMask with _$LayerMask {
  const LayerMask._();

  const factory LayerMask({
    /// マスク画像（グレースケール）
    /// 白=100%表示、黒=0%表示
    /// JsonKeyでシリアライズから除外（ui.Imageはシリアライズ不可）
    @JsonKey(includeFromJson: false, includeToJson: false) ui.Image? maskImage,

    /// マスクが有効かどうか
    @Default(false) bool isEnabled,

    /// マスクの不透明度（0.0 - 1.0）
    @Default(1.0) double opacity,

    /// マスクを反転するか
    @Default(false) bool isInverted,

    /// マスク編集履歴（Undo用）
    /// 実装では簡略化のため、マスク画像のバイトデータを保存
    @Default([]) List<String> editHistory,

    /// 作成日時
    required DateTime createdAt,

    /// 最終更新日時
    required DateTime updatedAt,
  }) = _LayerMask;

  factory LayerMask.fromJson(Map<String, dynamic> json) =>
      _$LayerMaskFromJson(json);

  /// 空のマスクを作成（全て表示）
  factory LayerMask.empty() {
    final now = DateTime.now();
    return LayerMask(
      isEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// AIセグメンテーションからマスクを作成
  factory LayerMask.fromAI({
    required ui.Image maskImage,
    bool inverted = false,
  }) {
    final now = DateTime.now();
    return LayerMask(
      maskImage: maskImage,
      isEnabled: true,
      isInverted: inverted,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// マスクが存在するか
  bool get hasMask => maskImage != null;
}

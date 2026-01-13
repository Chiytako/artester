import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_effect.freezed.dart';
part 'layer_effect.g.dart';

/// レイヤーエフェクトの種類
enum LayerEffectType {
  /// ドロップシャドウ
  dropShadow('Drop Shadow'),

  /// インナーシャドウ
  innerShadow('Inner Shadow'),

  /// 境界線
  stroke('Stroke'),

  /// 外側光彩
  outerGlow('Outer Glow'),

  /// 内側光彩
  innerGlow('Inner Glow');

  const LayerEffectType(this.displayName);

  final String displayName;
}

/// ドロップシャドウエフェクト
@freezed
class DropShadowEffect with _$DropShadowEffect {
  const factory DropShadowEffect({
    /// 有効/無効
    @Default(true) bool enabled,

    /// 色
    @Default(0xFF000000) int color,

    /// 不透明度（0.0 - 1.0）
    @Default(0.75) double opacity,

    /// 角度（度）
    @Default(120.0) double angle,

    /// 距離（ピクセル）
    @Default(5.0) double distance,

    /// スプレッド（0.0 - 1.0）
    @Default(0.0) double spread,

    /// サイズ（ピクセル）
    @Default(5.0) double size,
  }) = _DropShadowEffect;

  factory DropShadowEffect.fromJson(Map<String, dynamic> json) =>
      _$DropShadowEffectFromJson(json);
}

/// ストローク（境界線）エフェクト
@freezed
class StrokeEffect with _$StrokeEffect {
  const factory StrokeEffect({
    /// 有効/無効
    @Default(true) bool enabled,

    /// 色
    @Default(0xFFFFFFFF) int color,

    /// 不透明度（0.0 - 1.0）
    @Default(1.0) double opacity,

    /// サイズ（ピクセル）
    @Default(3.0) double size,

    /// 位置
    @Default(StrokePosition.outside) StrokePosition position,
  }) = _StrokeEffect;

  factory StrokeEffect.fromJson(Map<String, dynamic> json) =>
      _$StrokeEffectFromJson(json);
}

/// ストロークの位置
enum StrokePosition {
  /// 外側
  outside('Outside'),

  /// 中央
  center('Center'),

  /// 内側
  inside('Inside');

  const StrokePosition(this.displayName);

  final String displayName;
}

/// 光彩エフェクト
@freezed
class GlowEffect with _$GlowEffect {
  const factory GlowEffect({
    /// 有効/無効
    @Default(true) bool enabled,

    /// 色
    @Default(0xFFFFFFFF) int color,

    /// 不透明度（0.0 - 1.0）
    @Default(0.75) double opacity,

    /// サイズ（ピクセル）
    @Default(5.0) double size,

    /// スプレッド（0.0 - 1.0）
    @Default(0.0) double spread,
  }) = _GlowEffect;

  factory GlowEffect.fromJson(Map<String, dynamic> json) =>
      _$GlowEffectFromJson(json);
}

/// レイヤーエフェクトのコレクション
@freezed
class LayerEffects with _$LayerEffects {
  const factory LayerEffects({
    /// ドロップシャドウ
    DropShadowEffect? dropShadow,

    /// ストローク
    StrokeEffect? stroke,

    /// 外側光彩
    GlowEffect? outerGlow,

    /// 内側光彩
    GlowEffect? innerGlow,
  }) = _LayerEffects;

  factory LayerEffects.fromJson(Map<String, dynamic> json) =>
      _$LayerEffectsFromJson(json);

  /// エフェクトが有効か
  const LayerEffects._();

  bool get hasEffects =>
      (dropShadow?.enabled ?? false) ||
      (stroke?.enabled ?? false) ||
      (outerGlow?.enabled ?? false) ||
      (innerGlow?.enabled ?? false);
}

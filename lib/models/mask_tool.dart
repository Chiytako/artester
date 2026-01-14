import 'package:flutter/material.dart';

/// マスク編集ツール
enum MaskTool {
  /// ブラシ（追加）
  brush('Brush', Icons.brush, Colors.white),

  /// 消しゴム（削除）
  eraser('Eraser', Icons.auto_fix_normal, Colors.black),

  /// グラデーション
  gradient('Gradient', Icons.gradient, Colors.grey),

  /// 塗りつぶし
  fill('Fill', Icons.format_color_fill, Colors.white),

  /// 選択範囲
  selection('Selection', Icons.select_all, Colors.blue);

  const MaskTool(this.displayName, this.icon, this.color);

  /// 表示名
  final String displayName;

  /// アイコン
  final IconData icon;

  /// ツールのテーマカラー
  final Color color;
}

/// マスク編集設定
class MaskEditSettings {
  /// ブラシサイズ（ピクセル）
  final double brushSize;

  /// ブラシの硬さ（0.0 - 1.0）
  final double hardness;

  /// ブラシの不透明度（0.0 - 1.0）
  final double opacity;

  /// 現在のツール
  final MaskTool tool;

  const MaskEditSettings({
    this.brushSize = 50.0,
    this.hardness = 0.5,
    this.opacity = 1.0,
    this.tool = MaskTool.brush,
  });

  MaskEditSettings copyWith({
    double? brushSize,
    double? hardness,
    double? opacity,
    MaskTool? tool,
  }) {
    return MaskEditSettings(
      brushSize: brushSize ?? this.brushSize,
      hardness: hardness ?? this.hardness,
      opacity: opacity ?? this.opacity,
      tool: tool ?? this.tool,
    );
  }
}

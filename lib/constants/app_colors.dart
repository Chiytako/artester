import 'package:flutter/material.dart';

/// アプリケーション全体で使用する色定数
class AppColors {
  // プライマリーカラー
  static const Color primary = Colors.amber;
  static const Color secondary = Colors.orange;

  // サーフェスカラー
  static const Color surface = Color(0xFF121212);
  static const Color background = Colors.black;
  static const Color dialogBackground = Color(0xFF1E1E1E);

  // テキストカラー
  static const Color onSurface = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white30;

  // UI要素
  static const Color border = Colors.white24;
  static const Color divider = Colors.white12;

  // 状態カラー
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.amber;

  // 半透明カラー
  static const Color overlayDark = Colors.black54;
  static final Color overlayLight = Colors.black.withValues(alpha: 0.3);
  static final Color primaryOverlay = const Color.fromRGBO(255, 193, 7, 0.2);
  static final Color shadowColor = const Color.fromRGBO(255, 193, 7, 0.3);

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppColors._();
}

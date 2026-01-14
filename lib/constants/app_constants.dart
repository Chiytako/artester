/// アプリケーション全体で使用する定数
class AppConstants {
  // アプリ名
  static const String appName = 'Artester';

  // UI サイズ
  static const double controlPanelHeight = 160.0;
  static const double tabBarHeight = 50.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 28.0;

  // スペーシング
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 32.0;

  // ボーダー半径
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  static const double borderRadiusCircular = 24.0;

  // アニメーション時間
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration animationDurationFast = Duration(milliseconds: 100);
  static const Duration animationDurationSlow = Duration(milliseconds: 300);

  // パディング
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;

  // エレベーション
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ブラー効果
  static const double blurRadiusSmall = 8.0;
  static const double blurRadiusMedium = 12.0;
  static const double blurRadiusLarge = 20.0;

  // 不透明度
  static const double opacityHigh = 0.9;
  static const double opacityMedium = 0.7;
  static const double opacityLow = 0.3;

  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppConstants._();
}

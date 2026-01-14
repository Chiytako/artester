/// レイヤーブレンドモード
///
/// 各レイヤーの合成方法を定義
enum BlendMode {
  /// 通常（上書き）
  normal('Normal'),

  /// 乗算（暗くなる）
  multiply('Multiply'),

  /// スクリーン（明るくなる）
  screen('Screen'),

  /// オーバーレイ
  overlay('Overlay'),

  /// ソフトライト
  softLight('Soft Light'),

  /// ハードライト
  hardLight('Hard Light'),

  /// 加算
  add('Add'),

  /// 減算
  subtract('Subtract'),

  /// 差の絶対値
  difference('Difference'),

  /// 比較（暗）
  darken('Darken'),

  /// 比較（明）
  lighten('Lighten');

  const BlendMode(this.displayName);

  /// 表示名
  final String displayName;

  /// シェーダー用のインデックス
  int get shaderIndex => index;
}

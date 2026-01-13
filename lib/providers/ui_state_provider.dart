import 'package:flutter_riverpod/flutter_riverpod.dart';

/// レイヤーパネルの表示状態を管理するProvider
final layerPanelVisibleProvider = StateProvider<bool>((ref) => false);

/// マスク編集モードの状態を管理するProvider
final maskEditModeProvider = StateProvider<bool>((ref) => false);

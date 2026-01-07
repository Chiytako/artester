import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/editor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ArtesterApp()));
}

/// Artester アプリケーション
///
/// Riverpod による状態管理の初期化と
/// ダークテーマの設定を行う。
class ArtesterApp extends StatelessWidget {
  const ArtesterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artester',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.orange,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.amber,
          inactiveTrackColor: Colors.white24,
          thumbColor: Colors.white,
          overlayColor: const Color.fromRGBO(255, 193, 7, 0.2),
        ),
      ),
      home: const EditorScreen(),
    );
  }
}

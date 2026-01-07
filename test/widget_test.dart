// Basic widget test for Artester app

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:artester/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ArtesterApp()));

    // Verify that the app title is displayed
    expect(find.text('Artester'), findsOneWidget);

    // Verify that the image picker button is visible
    expect(find.text('画像を選択'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artester/models/edit_state.dart';
import 'package:artester/providers/edit_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should have 0 rotation and no flip', () {
    final state = container.read(editProvider);
    expect(state.rotation, 0);
    expect(state.flipX, false);
    expect(state.flipY, false);
    expect(state.isModified, false);
  });

  test('rotate90 should increment rotation', () {
    final notifier = container.read(editProvider.notifier);

    notifier.rotate90();
    expect(container.read(editProvider).rotation, 1);
    expect(container.read(editProvider).isModified, true);

    notifier.rotate90();
    expect(container.read(editProvider).rotation, 2);

    notifier.rotate90();
    expect(container.read(editProvider).rotation, 3);

    notifier.rotate90();
    expect(container.read(editProvider).rotation, 0);
  });

  test('rotateLeft should decrement rotation', () {
    final notifier = container.read(editProvider.notifier);

    notifier.rotateLeft();
    expect(container.read(editProvider).rotation, 3);
    expect(container.read(editProvider).isModified, true);

    notifier.rotateLeft();
    expect(container.read(editProvider).rotation, 2);
  });

  test('flipHorizontal should toggle flipX', () {
    final notifier = container.read(editProvider.notifier);

    notifier.flipHorizontal();
    expect(container.read(editProvider).flipX, true);
    expect(container.read(editProvider).isModified, true);

    notifier.flipHorizontal();
    expect(container.read(editProvider).flipX, false);
  });

  test('flipVertical should toggle flipY', () {
    final notifier = container.read(editProvider.notifier);

    notifier.flipVertical();
    expect(container.read(editProvider).flipY, true);
    expect(container.read(editProvider).isModified, true);

    notifier.flipVertical();
    expect(container.read(editProvider).flipY, false);
  });

  test('Geometry changes allow saving history', () {
    final notifier = container.read(editProvider.notifier);

    expect(notifier.canUndo, false);

    notifier.rotate90();
    expect(notifier.canUndo, true); // History saved before change

    notifier.undo();
    expect(container.read(editProvider).rotation, 0);
  });
}

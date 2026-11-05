import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/app/mergro_app.dart';
import 'package:mergro_ai_voice_assistant/core/theme/theme_mode_controller.dart';
import 'package:mergro_ai_voice_assistant/features/profile/screens/profile_screen.dart';

import '../../features/shell/dashboard_screens_test.dart' show pumpScreen;
import '../../helpers/fakes.dart';

/// A container whose theme store is [store].
ProviderContainer _containerWith(InMemoryThemePreferenceStore store) {
  final container = ProviderContainer.test(
    overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
  );
  container.listen(themeModeControllerProvider, (_, _) {});
  return container;
}

void main() {
  test('follows the system until a choice is saved', () async {
    final container = _containerWith(InMemoryThemePreferenceStore());
    expect(container.read(themeModeControllerProvider), ThemeMode.system);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(themeModeControllerProvider), ThemeMode.system);
  });

  test('restores the saved choice on launch', () async {
    final store = InMemoryThemePreferenceStore()..saved = ThemeMode.dark;
    final container = _containerWith(store);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('select applies at once and is saved', () async {
    final store = InMemoryThemePreferenceStore();
    final container = _containerWith(store);
    await container
        .read(themeModeControllerProvider.notifier)
        .select(ThemeMode.light);
    expect(container.read(themeModeControllerProvider), ThemeMode.light);
    expect(store.saved, ThemeMode.light);
  });

  test('a broken store never blocks the choice', () async {
    final store = InMemoryThemePreferenceStore()
      ..failWith = StateError('keychain locked');
    final container = _containerWith(store);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(themeModeControllerProvider), ThemeMode.system);
    await container
        .read(themeModeControllerProvider.notifier)
        .select(ThemeMode.dark);
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  testWidgets('the root app uses the chosen mode', (tester) async {
    final store = InMemoryThemePreferenceStore()..saved = ThemeMode.dark;
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeOverrides(themeStore: store),
        child: const MergroApp(),
      ),
    );
    await tester.pump();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    // Let the splash finish so no timers are left running.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Profile → Appearance switches the theme', (tester) async {
    await pumpScreen(tester, ProfileScreen(onSignOut: () {}));
    await tester.scrollUntilVisible(
      find.text('Dark'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Dark'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });
}

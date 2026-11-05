import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/theme_preference_store.dart';
import '../utils/app_logger.dart';

/// Where the theme choice is saved; overridden with a fake in tests.
final themePreferenceStoreProvider = Provider<ThemePreferenceStore>(
  (ref) => SecureThemePreferenceStore(),
);

/// The app's theme mode. App-wide; survives sign-out (it is a device
/// preference, not an account one).
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Holds and saves the Light / Dark / System choice.
class ThemeModeController extends Notifier<ThemeMode> {
  /// Starts by following the system, then applies the saved choice.
  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  /// Applies [mode] now and saves it for next launch.
  Future<void> select(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(themePreferenceStoreProvider).write(mode);
    } catch (error, stackTrace) {
      // The choice still applies for this session.
      AppLogger.error('Saving the theme choice failed', error, stackTrace);
    }
  }

  /// Loads the saved choice; keeps "system" when there is none or it fails.
  Future<void> _restore() async {
    try {
      final saved = await ref.read(themePreferenceStoreProvider).read();
      if (saved != null && ref.mounted) state = saved;
    } catch (error) {
      AppLogger.warning('Reading the theme choice failed', error);
    }
  }
}

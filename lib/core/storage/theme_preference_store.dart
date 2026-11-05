import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the user's Light / Dark / System choice on this device.
abstract interface class ThemePreferenceStore {
  /// The saved choice, or null when none was saved.
  Future<ThemeMode?> read();

  /// Saves [mode].
  Future<void> write(ThemeMode mode);
}

/// [ThemePreferenceStore] on the platform keychain / keystore (the approved
/// storage package; the value itself is not secret).
class SecureThemePreferenceStore implements ThemePreferenceStore {
  /// Creates the store; pass [storage] to replace the plugin in tests.
  SecureThemePreferenceStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'mergro.themeMode';

  final FlutterSecureStorage _storage;

  /// Reads the saved mode by its enum name.
  @override
  Future<ThemeMode?> read() async {
    final name = await _storage.read(key: _key);
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  /// Saves the mode by its enum name.
  @override
  Future<void> write(ThemeMode mode) =>
      _storage.write(key: _key, value: mode.name);
}

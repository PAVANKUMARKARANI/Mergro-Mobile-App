import 'package:flutter/material.dart';
import 'package:mergro_ai_voice_assistant/core/storage/theme_preference_store.dart';
import 'package:mergro_ai_voice_assistant/core/storage/token_storage.dart';

/// In-memory [TokenStorage].
class InMemoryTokenStorage implements TokenStorage {
  /// Current token.
  String? token;

  /// Whether the last save asked to persist.
  bool? lastPersist;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String token, {required bool persist}) async {
    this.token = token;
    lastPersist = persist;
  }

  @override
  Future<void> clear() async => token = null;
}

/// In-memory [ThemePreferenceStore]; [failWith] makes every call throw.
class InMemoryThemePreferenceStore implements ThemePreferenceStore {
  /// Saved mode.
  ThemeMode? saved;

  /// Thrown by every call when set.
  Object? failWith;

  @override
  Future<ThemeMode?> read() async {
    if (failWith case final error?) throw error;
    return saved;
  }

  @override
  Future<void> write(ThemeMode mode) async {
    if (failWith case final error?) throw error;
    saved = mode;
  }
}

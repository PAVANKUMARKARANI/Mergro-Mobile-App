import 'package:flutter/foundation.dart';

/// Where the Mergro API lives and how long to wait for it.
abstract final class ApiConfig {
  /// Set with `--dart-define=API_BASE_URL=https://api.example.com/api`.
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Port of the local development server (`npm start` in the backend repo).
  static const int localPort = 2282;

  /// Base URL including the `/api` prefix. Defaults to the local dev server:
  /// the Android emulator reaches the host machine at 10.0.2.2.
  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:$localPort/api';
  }

  /// Time allowed to open a connection.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Time allowed to send a request or receive a response.
  static const Duration transferTimeout = Duration(seconds: 20);

  /// Login type the backend expects for app users.
  static const String entityType = 'employee';
}

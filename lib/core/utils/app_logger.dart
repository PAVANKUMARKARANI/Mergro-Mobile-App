import 'dart:developer' as developer;

/// Central logger (standards A14). Never pass passwords, tokens or personal
/// data to it.
abstract final class AppLogger {
  static const String _name = 'mergro';
  static const int _warningLevel = 900;
  static const int _errorLevel = 1000;

  /// Logs a recoverable problem.
  static void warning(String message, [Object? error]) =>
      developer.log(message, name: _name, level: _warningLevel, error: error);

  /// Logs a failure.
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      developer.log(
        message,
        name: _name,
        level: _errorLevel,
        error: error,
        stackTrace: stackTrace,
      );
}

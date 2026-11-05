import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the API access token for the current session.
abstract interface class TokenStorage {
  /// The current token, or null when signed out.
  Future<String?> readAccessToken();

  /// Stores [token]. When [persist] is false it lives only until the app
  /// closes ("Remember me" off).
  Future<void> saveAccessToken(String token, {required bool persist});

  /// Forgets the token everywhere.
  Future<void> clear();
}

/// [TokenStorage] backed by the platform keychain / keystore, with an
/// in-memory copy so each request doesn't hit secure storage.
class SecureTokenStorage implements TokenStorage {
  /// Creates the storage; pass [storage] to replace the plugin in tests.
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'mergro.accessToken';

  final FlutterSecureStorage _storage;
  String? _cachedToken;
  bool _hasLoaded = false;

  /// Returns the cached token, loading it from secure storage once.
  @override
  Future<String?> readAccessToken() async {
    if (!_hasLoaded) {
      _cachedToken ??= await _storage.read(key: _accessTokenKey);
      _hasLoaded = true;
    }
    return _cachedToken;
  }

  /// Caches [token] and writes it to secure storage when [persist] is true.
  @override
  Future<void> saveAccessToken(String token, {required bool persist}) async {
    _cachedToken = token;
    _hasLoaded = true;
    if (persist) {
      await _storage.write(key: _accessTokenKey, value: token);
    } else {
      await _storage.delete(key: _accessTokenKey);
    }
  }

  /// Clears the cache and secure storage.
  @override
  Future<void> clear() async {
    _cachedToken = null;
    _hasLoaded = true;
    await _storage.delete(key: _accessTokenKey);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../models/app_user.dart';
import '../services/auth_api_service.dart';

/// Sessions and accounts for the app; overridden with a fake in tests.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(authApiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

/// Signs users in and out and restores sessions. Throws [ApiException] on
/// failure.
class AuthRepository {
  /// Creates the repository from its service and token storage.
  AuthRepository(this._api, this._tokens);

  final AuthApiService _api;
  final TokenStorage _tokens;

  /// Signs in and loads the user. With [rememberMe] off, the session ends
  /// when the app closes.
  Future<AppUser> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final token = await _api.login(email: email, password: password);
    await _tokens.saveAccessToken(token, persist: rememberMe);
    try {
      return await fetchCurrentUser();
    } on Object {
      await _tokens.clear();
      rethrow;
    }
  }

  /// Loads the signed-in user (`GET /auth/me`).
  Future<AppUser> fetchCurrentUser() async {
    final json = await _api.fetchCurrentUser();
    try {
      return AppUser.fromJson(json);
    } on FormatException catch (error) {
      AppLogger.error('Unreadable user from /auth/me', error);
      throw ApiException(ApiErrorKind.unexpected);
    }
  }

  /// Returns the user of a stored session, or null when there is none or it
  /// expired. Throws on connectivity or server errors so the caller can
  /// decide whether to retry.
  Future<AppUser?> restoreSession() async {
    final token = await _tokens.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return await fetchCurrentUser();
    } on ApiException catch (error) {
      if (error.kind != ApiErrorKind.unauthorized) rethrow;
      await _tokens.clear();
      return null;
    }
  }

  /// Ends the session on the server (best effort) and forgets the token.
  Future<void> signOut() async {
    try {
      await _api.logout();
    } on ApiException catch (error) {
      // The local session ends regardless; the server token expires anyway.
      AppLogger.warning('Logout request failed', error);
    } finally {
      await _tokens.clear();
    }
  }

  /// Asks the server to email a password reset link to [email].
  Future<void> requestPasswordReset(String email) =>
      _api.requestPasswordReset(email);
}

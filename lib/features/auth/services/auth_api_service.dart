import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';

/// Auth endpoints of the Mergro API.
final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(ref.watch(apiClientProvider)),
);

/// Raw calls to `/api/auth/*`. Returns JSON; [AuthRepository] adds meaning.
class AuthApiService {
  /// Creates the service on top of [_client].
  AuthApiService(this._client);

  final ApiClient _client;

  /// `POST /auth/login`. Returns the access token.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'entityType': ApiConfig.entityType,
        'type': _deviceType,
      },
    );
    final token = json['accessToken'];
    if (token is! String || token.isEmpty) {
      throw ApiException(ApiErrorKind.unexpected);
    }
    return token;
  }

  /// `GET /auth/me`. Returns the user's `details`.
  Future<JsonMap> fetchCurrentUser() async {
    final json = await _client.get('/auth/me');
    final details = json['details'];
    if (details is! Map<String, dynamic>) {
      throw ApiException(ApiErrorKind.unexpected);
    }
    return details;
  }

  /// `POST /auth/logout`: ends the session on the server.
  Future<void> logout() => _client.post('/auth/logout');

  /// `POST /auth/forgotPassword?email=`: emails a reset link.
  Future<void> requestPasswordReset(String email) => _client.post(
    '/auth/forgotPassword',
    query: {'email': email},
    body: {'entityType': ApiConfig.entityType},
  );

  /// Device type the backend records with the session.
  static String get _deviceType => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => 'web',
  };
}

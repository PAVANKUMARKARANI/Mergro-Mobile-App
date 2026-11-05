import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_client.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/auth/repositories/auth_repository.dart';
import 'package:mergro_ai_voice_assistant/features/auth/services/auth_api_service.dart';

import '../../helpers/fakes.dart';

/// Scriptable [AuthApiService].
class _FakeAuthApi implements AuthApiService {
  ApiException? meError;
  ApiException? logoutError;
  JsonMap me = {
    '_id': 'u1',
    'email': 'priya@skyline.in',
    'name': 'Priya Sharma',
    'role': 'brokerageAdmin',
    'brokerageName': 'Skyline Realty',
    'onboardingCompleted': true,
  };
  int logoutCount = 0;

  @override
  Future<String> login({required String email, required String password}) =>
      Future.value('token-1');

  @override
  Future<JsonMap> fetchCurrentUser() async {
    if (meError case final error?) throw error;
    return me;
  }

  @override
  Future<void> logout() async {
    logoutCount++;
    if (logoutError case final error?) throw error;
  }

  @override
  Future<void> requestPasswordReset(String email) async {}
}

void main() {
  late _FakeAuthApi api;
  late InMemoryTokenStorage tokens;
  late AuthRepository repository;

  setUp(() {
    api = _FakeAuthApi();
    tokens = InMemoryTokenStorage();
    repository = AuthRepository(api, tokens);
  });

  test('signIn stores the token and returns the /me user', () async {
    final user = await repository.signIn(
      email: 'priya@skyline.in',
      password: 'secret',
      rememberMe: false,
    );
    expect(user.role, UserRole.brokerageAdmin);
    expect(user.isOnboardingComplete, isTrue);
    expect(tokens.token, 'token-1');
    expect(tokens.lastPersist, isFalse, reason: 'Remember me off');
  });

  test('signIn drops the token when /me fails', () async {
    api.meError = ApiException(ApiErrorKind.server);
    await expectLater(
      repository.signIn(email: 'a@b.co', password: 'x', rememberMe: true),
      throwsA(isA<ApiException>()),
    );
    expect(tokens.token, isNull);
  });

  test('an unreadable user becomes an unexpected error', () async {
    api.me = {'_id': 'u1', 'email': 'a@b.co', 'role': 'astronaut'};
    tokens.token = 't';
    final error = await repository.fetchCurrentUser().then<Object?>(
      (_) => null,
      onError: (Object e) => e,
    );
    expect((error as ApiException?)?.kind, ApiErrorKind.unexpected);
  });

  group('restoreSession', () {
    test('returns null without a stored token', () async {
      expect(await repository.restoreSession(), isNull);
    });

    test('returns the user for a valid token', () async {
      tokens.token = 't';
      expect((await repository.restoreSession())?.email, 'priya@skyline.in');
    });

    test('clears an expired token and returns null', () async {
      tokens.token = 't';
      api.meError = ApiException(ApiErrorKind.unauthorized);
      expect(await repository.restoreSession(), isNull);
      expect(tokens.token, isNull);
    });

    test('keeps the token and rethrows when offline', () async {
      tokens.token = 't';
      api.meError = ApiException(ApiErrorKind.network);
      await expectLater(
        repository.restoreSession(),
        throwsA(isA<ApiException>()),
      );
      expect(tokens.token, 't');
    });
  });

  test('signOut clears the token even when logout fails', () async {
    tokens.token = 't';
    api.logoutError = ApiException(ApiErrorKind.network);
    await repository.signOut();
    expect(api.logoutCount, 1);
    expect(tokens.token, isNull);
  });
}

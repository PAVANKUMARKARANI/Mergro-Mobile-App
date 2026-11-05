import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/splash/controllers/splash_controller.dart';
import 'package:mergro_ai_voice_assistant/features/splash/models/splash_destination.dart';

import '../../helpers/fakes.dart';

/// Where the splash sends a user given the [auth] fake's session.
Future<SplashDestination> _destination(FakeAuthRepository auth) async {
  final container = fakeContainer(auth: auth);
  container.listen(splashControllerProvider, (_, _) {});
  return container.read(splashControllerProvider.future);
}

void main() {
  group('SplashController', () {
    test('no stored session → login', () async {
      expect(await _destination(FakeAuthRepository()), SplashDestination.login);
    });

    test('onboarding not finished → onboarding, user restored', () async {
      final auth = FakeAuthRepository()
        ..restoredUser = testUser(UserRole.salesAgent);
      final container = fakeContainer(auth: auth);
      container.listen(splashControllerProvider, (_, _) {});
      expect(
        await container.read(splashControllerProvider.future),
        SplashDestination.onboarding,
      );
      expect(container.read(currentUserProvider)?.role, UserRole.salesAgent);
    });

    test('onboarding finished → home', () async {
      final auth = FakeAuthRepository()
        ..restoredUser = testUser(UserRole.teamLead, 'n@skyline.in', true);
      expect(await _destination(auth), SplashDestination.home);
    });

    test('server unreachable or storage broken → login', () async {
      final offline = FakeAuthRepository()
        ..restoreError = ApiException(ApiErrorKind.network);
      expect(await _destination(offline), SplashDestination.login);
      final broken = FakeAuthRepository()
        ..restoreError = StateError('keychain');
      expect(await _destination(broken), SplashDestination.login);
    });
  });

  group('CurrentUserController', () {
    test('signOut ends the server session and clears the user', () async {
      final auth = FakeAuthRepository();
      final container = fakeContainer(auth: auth);
      final controller = container.read(currentUserProvider.notifier)
        ..setUser(testUser(UserRole.brokerageAdmin));

      await controller.signOut();

      expect(auth.signOutCount, 1);
      expect(container.read(currentUserProvider), isNull);
    });

    test('refresh loads the user, and keeps the old one on failure', () async {
      final auth = FakeAuthRepository();
      final container = fakeContainer(auth: auth);
      final controller = container.read(currentUserProvider.notifier)
        ..setUser(testUser(UserRole.brokerageAdmin));

      await controller.refresh();
      expect(container.read(currentUserProvider)?.name, 'Priya Sharma');

      auth.currentUser = testUser(UserRole.brokerageAdmin, 'p@x.in', true);
      await controller.refresh();
      expect(container.read(currentUserProvider)?.isOnboardingComplete, true);
    });
  });

  group('AppUser.fromJson', () {
    test('parses /auth/me details', () {
      final user = AppUser.fromJson({
        '_id': 'u1',
        'email': 'asha@skyline.in',
        'name': 'Asha Rao',
        'role': 'teamLead',
        'brokerageName': 'Skyline Realty',
        'onboardingCompleted': false,
      });
      expect(user.role, UserRole.teamLead);
      expect(user.firstName, 'Asha');
      expect(user.isOnboardingComplete, isFalse);
    });

    test('an invited user without a name greets by email', () {
      final user = AppUser.fromJson({
        '_id': 'u2',
        'email': 'new@skyline.in',
        'role': 'salesAgent',
      });
      expect(user.name, isEmpty);
      expect(user.firstName, 'new@skyline.in');
      expect(user.brokerageName, isEmpty);
    });

    test('rejects an unknown role', () {
      expect(
        () => AppUser.fromJson({'_id': 'u', 'email': 'a@b.co', 'role': 'x'}),
        throwsFormatException,
      );
    });
  });
}

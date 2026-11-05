import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/core/validation/form_validators.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/forgot_password_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/login_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/login_models.dart';

import '../../helpers/fakes.dart';

/// Creates a container with [auth] that keeps the auto-disposed login
/// providers alive.
ProviderContainer _createContainer(FakeAuthRepository auth) {
  final container = fakeContainer(auth: auth);
  container.listen(loginControllerProvider, (_, _) {});
  container.listen(forgotPasswordControllerProvider, (_, _) {});
  return container;
}

/// Fills the login form.
LoginController _fill(ProviderContainer container, String password) =>
    container.read(loginControllerProvider.notifier)
      ..updateEmail(' Asha@Skyline.in ')
      ..updatePassword(password);

void main() {
  group('LoginController', () {
    test('validates email format and required password', () async {
      final auth = FakeAuthRepository();
      final container = _createContainer(auth);
      final controller = container.read(loginControllerProvider.notifier);
      controller.updateEmail('not-an-email');

      final outcome = await controller.signIn();

      final state = container.read(loginControllerProvider);
      expect(outcome, isA<LoginFailed>());
      expect(state.emailError, ValidationMessages.emailInvalid);
      expect(state.passwordError, 'Enter a password.');
      expect(state.isSubmitting, isFalse);
      expect(auth.lastSignIn, isNull, reason: 'no request for a bad form');
    });

    test('server credential errors show one generic message', () async {
      final container = _createContainer(FakeAuthRepository());

      final outcome = await _fill(container, 'wrong').signIn();

      expect(
        (outcome as LoginFailed).message,
        LoginController.invalidCredentialsMessage,
      );
      final state = container.read(loginControllerProvider);
      expect(state.bannerMessage, LoginController.invalidCredentialsMessage);
      expect(state.isSubmitting, isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('an invited, inactive account explains what to do', () async {
      final auth = FakeAuthRepository()
        ..signInError = ApiException(
          ApiErrorKind.validation,
          message: 'Please activate your account.',
        );
      final container = _createContainer(auth);

      final outcome = await _fill(container, 'secret').signIn();

      expect(
        (outcome as LoginFailed).message,
        LoginController.inactiveAccountMessage,
      );
    });

    test('network failures show the connectivity message', () async {
      final auth = FakeAuthRepository()
        ..signInError = ApiException(ApiErrorKind.network);
      final container = _createContainer(auth);

      await _fill(container, 'secret').signIn();

      expect(
        container.read(loginControllerProvider).bannerMessage,
        ApiException.defaultMessages[ApiErrorKind.network],
      );
    });

    test('success stores the server user and blocks double submits', () async {
      final auth = FakeAuthRepository()..role = UserRole.salesAgent;
      final container = _createContainer(auth);
      final controller = _fill(container, 'secret')..setRememberMe(false);

      final future = controller.signIn();
      expect(container.read(loginControllerProvider).isSubmitting, isTrue);
      expect(await controller.signIn(), isA<LoginFailed>(), reason: 'busy');
      final outcome = await future;

      expect((outcome as LoginSucceeded).user.role, UserRole.salesAgent);
      expect(container.read(currentUserProvider)?.email, 'asha@skyline.in');
      expect(auth.lastSignIn?.email, 'asha@skyline.in', reason: 'normalized');
      expect(auth.lastSignIn?.rememberMe, isFalse);
    });

    test('company SSO requires a valid work email', () async {
      final container = _createContainer(FakeAuthRepository());
      final controller = container.read(loginControllerProvider.notifier);

      final outcome = await controller.signInWithProvider(
        SsoProvider.companySso,
        workEmail: 'bad',
      );

      expect((outcome as LoginFailed).message, ValidationMessages.emailInvalid);
    });

    test('provider sign-in is reported as not available yet', () async {
      final container = _createContainer(FakeAuthRepository());
      final controller = container.read(loginControllerProvider.notifier);

      final outcome = await controller.signInWithProvider(SsoProvider.google);

      expect(
        (outcome as LoginFailed).message,
        LoginController.ssoUnavailableMessage,
      );
      final state = container.read(loginControllerProvider);
      expect(state.bannerMessage, LoginController.ssoUnavailableMessage);
      expect(state.activeSsoProvider, isNull);
    });
  });

  group('ForgotPasswordController', () {
    test('rejects an invalid email', () async {
      final container = _createContainer(FakeAuthRepository());
      final controller = container.read(
        forgotPasswordControllerProvider.notifier,
      )..updateEmail('nope');

      expect(await controller.sendResetLink(), isFalse);
      expect(
        container.read(forgotPasswordControllerProvider).emailError,
        ValidationMessages.emailInvalid,
      );
    });

    test('moves from sending to sent', () async {
      final auth = FakeAuthRepository();
      final container = _createContainer(auth);
      final controller = container.read(
        forgotPasswordControllerProvider.notifier,
      )..updateEmail('Asha@Skyline.in');

      final future = controller.sendResetLink();
      expect(
        container.read(forgotPasswordControllerProvider).isSending,
        isTrue,
      );
      expect(await future, isTrue);

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.isSending, isFalse);
      expect(state.isSent, isTrue);
      expect(auth.resetEmails, ['asha@skyline.in']);
    });

    test('an unknown email still looks sent (no account leak)', () async {
      final auth = FakeAuthRepository()
        ..resetError = ApiException(
          ApiErrorKind.validation,
          message: 'Email does not exist.',
        );
      final container = _createContainer(auth);
      final controller = container.read(
        forgotPasswordControllerProvider.notifier,
      )..updateEmail('nobody@skyline.in');

      expect(await controller.sendResetLink(), isTrue);
      expect(container.read(forgotPasswordControllerProvider).isSent, isTrue);
    });

    test('a network failure is shown and can be retried', () async {
      final auth = FakeAuthRepository()
        ..resetError = ApiException(ApiErrorKind.timeout);
      final container = _createContainer(auth);
      final controller = container.read(
        forgotPasswordControllerProvider.notifier,
      )..updateEmail('asha@skyline.in');

      expect(await controller.sendResetLink(), isFalse);
      final state = container.read(forgotPasswordControllerProvider);
      expect(state.isSent, isFalse);
      expect(
        state.emailError,
        ApiException.defaultMessages[ApiErrorKind.timeout],
      );
    });
  });
}

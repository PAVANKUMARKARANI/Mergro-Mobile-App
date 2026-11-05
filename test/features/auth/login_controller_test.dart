import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/validation/form_validators.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/forgot_password_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/login_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/login_models.dart';

/// Creates a container that keeps the auto-disposed login providers alive.
ProviderContainer _createContainer() {
  final container = ProviderContainer.test();
  container.listen(loginControllerProvider, (_, _) {});
  container.listen(forgotPasswordControllerProvider, (_, _) {});
  return container;
}

void main() {
  group('LoginController', () {
    test('validates email format and required password', () async {
      final container = _createContainer();
      final controller = container.read(loginControllerProvider.notifier);
      controller.updateEmail('not-an-email');

      final outcome = await controller.signIn();

      final state = container.read(loginControllerProvider);
      expect(outcome, isA<LoginFailed>());
      expect(state.emailError, ValidationMessages.emailInvalid);
      expect(state.passwordError, 'Enter a password.');
      expect(state.isSubmitting, isFalse);
    });

    test('"wrong" password fails with the banner message', () async {
      final container = _createContainer();
      final controller = container.read(loginControllerProvider.notifier)
        ..updateEmail('asha@skyline.in')
        ..updatePassword('wrong');

      final outcome = await controller.signIn();

      expect(
        (outcome as LoginFailed).message,
        LoginController.invalidCredentialsMessage,
      );
      final state = container.read(loginControllerProvider);
      expect(state.bannerMessage, LoginController.invalidCredentialsMessage);
      expect(state.isSubmitting, isFalse);
      expect(container.read(currentUserProvider), isNull);
    });

    test('success sets the current user with the preview role', () async {
      final container = _createContainer();
      final controller = container.read(loginControllerProvider.notifier)
        ..updateEmail('asha@skyline.in')
        ..updatePassword('secret')
        ..setPreviewRole(UserRole.salesAgent);

      final future = controller.signIn();
      expect(container.read(loginControllerProvider).isSubmitting, isTrue);
      expect(await controller.signIn(), isA<LoginFailed>(), reason: 'busy');
      final outcome = await future;

      expect((outcome as LoginSucceeded).user.role, UserRole.salesAgent);
      expect(container.read(currentUserProvider)?.email, 'asha@skyline.in');
    });

    test('company SSO requires a valid work email', () async {
      final container = _createContainer();
      final controller = container.read(loginControllerProvider.notifier);

      final outcome = await controller.signInWithProvider(
        SsoProvider.companySso,
        workEmail: 'bad',
      );

      expect((outcome as LoginFailed).message, ValidationMessages.emailInvalid);
      expect(container.read(loginControllerProvider).activeSsoProvider, isNull);
    });

    test('provider sign-in tracks the active provider', () async {
      final container = _createContainer();
      final controller = container.read(loginControllerProvider.notifier);

      final future = controller.signInWithProvider(SsoProvider.google);
      expect(
        container.read(loginControllerProvider).activeSsoProvider,
        SsoProvider.google,
      );
      expect(await future, isA<LoginSucceeded>());
      expect(container.read(loginControllerProvider).activeSsoProvider, isNull);
    });
  });

  group('ForgotPasswordController', () {
    test('rejects an invalid email', () async {
      final container = _createContainer();
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
      final container = _createContainer();
      final controller = container.read(
        forgotPasswordControllerProvider.notifier,
      )..updateEmail('asha@skyline.in');

      final future = controller.sendResetLink();
      expect(
        container.read(forgotPasswordControllerProvider).isSending,
        isTrue,
      );
      expect(await future, isTrue);

      final state = container.read(forgotPasswordControllerProvider);
      expect(state.isSending, isFalse);
      expect(state.isSent, isTrue);
    });
  });
}

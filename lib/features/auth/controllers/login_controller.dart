import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/validation/form_validators.dart';
import '../models/app_user.dart';
import '../models/login_models.dart';
import '../repositories/auth_repository.dart';
import 'current_user_controller.dart';

/// Login screen state; disposed when the screen closes.
final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
      LoginController.new,
    );

/// Validates the form and signs in through [AuthRepository].
class LoginController extends Notifier<LoginState> {
  /// Message for a credentials failure. Deliberately doesn't say whether
  /// the email or the password was wrong.
  static const String invalidCredentialsMessage =
      'Email or password is incorrect.';

  /// Message for an invited account that hasn't set a password yet.
  static const String inactiveAccountMessage =
      "Your account isn't active yet. Use the link in your invite email to "
      'set a password.';

  /// Message for provider sign-in, which the backend doesn't support yet.
  static const String ssoUnavailableMessage =
      'This sign-in option is coming soon. Use your email and password.';

  /// Message returned when a sign-in is already running.
  static const String busyMessage = 'Sign-in already in progress.';

  /// Message returned when the form has validation errors.
  static const String invalidFormMessage = 'Check the highlighted fields.';

  /// Starts with an empty form.
  @override
  LoginState build() => const LoginState();

  /// Updates the email and clears its error and the banner.
  void updateEmail(String email) => state = state.copyWith(
    email: email,
    emailError: () => null,
    bannerMessage: () => null,
  );

  /// Updates the password and clears its error and the banner.
  void updatePassword(String password) => state = state.copyWith(
    password: password,
    passwordError: () => null,
    bannerMessage: () => null,
  );

  /// Sets "Remember me".
  void setRememberMe(bool rememberMe) =>
      state = state.copyWith(rememberMe: rememberMe);

  /// Validates the form, then signs in with email and password.
  Future<LoginOutcome> signIn() async {
    if (state.isBusy) return const LoginFailed(busyMessage);
    final emailError = FormValidators.email(state.email);
    final passwordError = FormValidators.required(state.password, 'a password');
    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: () => emailError,
        passwordError: () => passwordError,
      );
      return const LoginFailed(invalidFormMessage);
    }
    state = state.copyWith(isSubmitting: true, bannerMessage: () => null);

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(
            email: state.email.trim().toLowerCase(),
            password: state.password,
            rememberMe: state.rememberMe,
          );
      if (!ref.mounted) return const LoginFailed(busyMessage);
      return _succeed(user);
    } on ApiException catch (error) {
      return _fail(_messageFor(error));
    } catch (error, stackTrace) {
      // E.g. secure storage failing; never leave the button spinning.
      AppLogger.error('Sign-in crashed', error, stackTrace);
      return _fail(ApiException.defaultMessages[ApiErrorKind.unexpected]!);
    }
  }

  /// Stops the spinner and shows [message] in the banner.
  LoginOutcome _fail(String message) {
    if (!ref.mounted) return const LoginFailed(busyMessage);
    state = state.copyWith(isSubmitting: false, bannerMessage: () => message);
    return LoginFailed(message);
  }

  /// Signs in with a third-party provider. Company SSO needs [workEmail] to
  /// discover the brokerage's identity provider.
  Future<LoginOutcome> signInWithProvider(
    SsoProvider provider, {
    String? workEmail,
  }) async {
    if (state.isBusy) return const LoginFailed(busyMessage);
    if (provider == SsoProvider.companySso) {
      final emailError = FormValidators.email(workEmail);
      if (emailError != null) return LoginFailed(emailError);
    }
    // TODO(backend): SSO / OAuth — google/microsoft: native OAuth then
    // POST /auth/oauth/{provider} {idToken}; companySso: GET
    // /auth/sso/discover?email= then the SAML/OIDC web flow. The backend has
    // no such endpoints yet, so provider sign-in is reported as unavailable.
    if (provider != SsoProvider.companySso) {
      state = state.copyWith(bannerMessage: () => ssoUnavailableMessage);
    }
    return const LoginFailed(ssoUnavailableMessage);
  }

  /// Stores [user] as the session user and returns success.
  LoginOutcome _succeed(AppUser user) {
    ref.read(currentUserProvider.notifier).setUser(user);
    state = state.copyWith(isSubmitting: false, activeSsoProvider: () => null);
    return LoginSucceeded(user);
  }

  /// User-facing text for a failed sign-in.
  static String _messageFor(ApiException error) {
    if (error.kind != ApiErrorKind.validation) return error.message;
    // The template sends "Please activate your account." for invited users.
    if (error.message.toLowerCase().contains('activate')) {
      return inactiveAccountMessage;
    }
    return invalidCredentialsMessage;
  }
}

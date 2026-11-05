import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/validation/form_validators.dart';
import '../auth_demo_data.dart';
import '../models/app_user.dart';
import '../models/login_models.dart';
import 'current_user_controller.dart';

/// Login screen state; disposed when the screen closes.
final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
      LoginController.new,
    );

/// Validates and (for now) simulates email/password and provider sign-in.
class LoginController extends Notifier<LoginState> {
  /// Message for a credentials failure.
  static const String invalidCredentialsMessage =
      'Email or password is incorrect.';

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

  /// Debug-only: picks the dummy user's role.
  void setPreviewRole(UserRole role) =>
      state = state.copyWith(previewRole: role);

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

    // TODO(backend): POST /auth/login {email, password, rememberMe}
    // → tokens + user; map 401 to invalidCredentialsMessage.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return const LoginFailed(busyMessage);

    if (state.password == AuthDemoData.wrongPassword) {
      state = state.copyWith(
        isSubmitting: false,
        bannerMessage: () => invalidCredentialsMessage,
      );
      return const LoginFailed(invalidCredentialsMessage);
    }
    return _succeed(state.email.trim());
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
    state = state.copyWith(
      activeSsoProvider: () => provider,
      bannerMessage: () => null,
    );

    // TODO(backend): SSO / OAuth — google/microsoft: native OAuth then
    // POST /auth/oauth/{provider} {idToken}; companySso: GET
    // /auth/sso/discover?email= then the SAML/OIDC web flow.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return const LoginFailed(busyMessage);

    return _succeed(workEmail?.trim() ?? AuthDemoData.providerEmail);
  }

  /// Stores the dummy user for the preview role and returns success.
  LoginOutcome _succeed(String email) {
    final user = AuthDemoData.userFor(state.previewRole, email);
    ref.read(currentUserProvider.notifier).setUser(user);
    state = state.copyWith(isSubmitting: false, activeSsoProvider: () => null);
    return LoginSucceeded(user);
  }
}

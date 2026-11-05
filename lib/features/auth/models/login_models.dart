import 'package:flutter/foundation.dart';

import 'app_user.dart';

/// Third-party sign-in options.
enum SsoProvider {
  /// Google Workspace OAuth.
  google('Continue with Google'),

  /// Microsoft Entra ID OAuth.
  microsoft('Continue with Microsoft'),

  /// The brokerage's own SAML/OIDC identity provider.
  companySso('Sign in with company SSO');

  /// Creates a provider with its button label.
  const SsoProvider(this.buttonLabel);

  /// Button text.
  final String buttonLabel;
}

/// Result of a sign-in attempt; the screen navigates only on success.
sealed class LoginOutcome {
  /// Base constructor.
  const LoginOutcome();
}

/// Sign-in succeeded with [user].
class LoginSucceeded extends LoginOutcome {
  /// Creates a success outcome.
  const LoginSucceeded(this.user);

  /// The signed-in user.
  final AppUser user;
}

/// Sign-in failed or was rejected; [message] is user-facing.
class LoginFailed extends LoginOutcome {
  /// Creates a failure outcome.
  const LoginFailed(this.message);

  /// Why it failed.
  final String message;
}

/// Immutable state of the Login screen.
@immutable
class LoginState {
  /// Creates a state; defaults are an empty form.
  const LoginState({
    this.email = '',
    this.password = '',
    this.rememberMe = true,
    this.isSubmitting = false,
    this.activeSsoProvider,
    this.emailError,
    this.passwordError,
    this.bannerMessage,
    this.previewRole = UserRole.brokerageAdmin,
  });

  /// Email field value.
  final String email;

  /// Password field value.
  final String password;

  /// "Remember me" checkbox.
  final bool rememberMe;

  /// True while email/password sign-in runs.
  final bool isSubmitting;

  /// Provider whose sign-in is running (spinner on that button only).
  final SsoProvider? activeSsoProvider;

  /// Inline email error.
  final String? emailError;

  /// Inline password error.
  final String? passwordError;

  /// Error banner above the Sign in button.
  final String? bannerMessage;

  /// Debug-only: role of the dummy user, which picks the onboarding flow.
  final UserRole previewRole;

  /// True while any sign-in is running; all sign-in buttons are blocked.
  bool get isBusy => isSubmitting || activeSsoProvider != null;

  /// Copies with changes. Nullable fields take a getter so they can be
  /// cleared explicitly, e.g. `emailError: () => null`.
  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? isSubmitting,
    ValueGetter<SsoProvider?>? activeSsoProvider,
    ValueGetter<String?>? emailError,
    ValueGetter<String?>? passwordError,
    ValueGetter<String?>? bannerMessage,
    UserRole? previewRole,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeSsoProvider: activeSsoProvider != null
          ? activeSsoProvider()
          : this.activeSsoProvider,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError: passwordError != null
          ? passwordError()
          : this.passwordError,
      bannerMessage: bannerMessage != null
          ? bannerMessage()
          : this.bannerMessage,
      previewRole: previewRole ?? this.previewRole,
    );
  }
}

/// Immutable state of the Forgot-password sheet.
@immutable
class ForgotPasswordState {
  /// Creates a state; defaults are an empty, unsent form.
  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.isSending = false,
    this.isSent = false,
  });

  /// Email field value.
  final String email;

  /// Inline email error.
  final String? emailError;

  /// True while the reset link is being sent.
  final bool isSending;

  /// True once the link was sent (sheet shows the success state).
  final bool isSent;

  /// Copies with changes; [emailError] takes a getter so it can be cleared.
  ForgotPasswordState copyWith({
    String? email,
    ValueGetter<String?>? emailError,
    bool? isSending,
    bool? isSent,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: emailError != null ? emailError() : this.emailError,
      isSending: isSending ?? this.isSending,
      isSent: isSent ?? this.isSent,
    );
  }
}

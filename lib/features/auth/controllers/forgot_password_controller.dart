import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/validation/form_validators.dart';
import '../models/login_models.dart';
import '../repositories/auth_repository.dart';

/// Forgot-password sheet state; disposed when the sheet closes.
final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );

/// Requests a password reset email.
class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  /// Starts with an empty, unsent form.
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  /// Updates the email and clears its error.
  void updateEmail(String email) =>
      state = state.copyWith(email: email, emailError: () => null);

  /// Validates the email and sends the link. Returns true once sent.
  ///
  /// Answers the server gives about the account itself (no such email, link
  /// already sent) still count as sent, so the sheet never reveals whether an
  /// account exists. Only connectivity and server failures are shown.
  Future<bool> sendResetLink() async {
    if (state.isSending || state.isSent) return state.isSent;
    final emailError = FormValidators.email(state.email);
    if (emailError != null) {
      state = state.copyWith(emailError: () => emailError);
      return false;
    }
    state = state.copyWith(isSending: true);

    String? failure;
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(state.email.trim().toLowerCase());
    } on ApiException catch (error) {
      if (error.kind != ApiErrorKind.validation) failure = error.message;
    }
    if (!ref.mounted) return false;

    state = state.copyWith(
      isSending: false,
      isSent: failure == null,
      emailError: () => failure,
    );
    return failure == null;
  }
}

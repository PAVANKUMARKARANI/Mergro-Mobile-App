import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/validation/form_validators.dart';
import '../models/login_models.dart';

/// Forgot-password sheet state; disposed when the sheet closes.
final forgotPasswordControllerProvider =
    NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>(
      ForgotPasswordController.new,
    );

/// Sends (for now, simulates) a password reset link.
class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  /// Starts with an empty, unsent form.
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  /// Updates the email and clears its error.
  void updateEmail(String email) =>
      state = state.copyWith(email: email, emailError: () => null);

  /// Validates the email and sends the link. Returns true once sent.
  Future<bool> sendResetLink() async {
    if (state.isSending || state.isSent) return state.isSent;
    final emailError = FormValidators.email(state.email);
    if (emailError != null) {
      state = state.copyWith(emailError: () => emailError);
      return false;
    }
    state = state.copyWith(isSending: true);

    // TODO(backend): POST /auth/forgot-password {email}. Always show success
    // so the response never reveals whether an account exists.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return false;

    state = state.copyWith(isSending: false, isSent: true);
    return true;
  }
}

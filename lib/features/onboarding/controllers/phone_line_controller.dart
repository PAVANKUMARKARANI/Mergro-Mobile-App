import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/validation/form_validators.dart';
import '../models/onboarding_options.dart';
import '../models/phone_line_draft.dart';

/// Admin step 4 draft; kept alive so values survive Back / Next.
final phoneLineControllerProvider =
    NotifierProvider<PhoneLineController, PhoneLineDraft>(
      PhoneLineController.new,
    );

/// Picks the telephony provider and number, and verifies existing numbers.
class PhoneLineController extends Notifier<PhoneLineDraft> {
  /// Starts with nothing chosen.
  @override
  PhoneLineDraft build() => const PhoneLineDraft();

  /// Selects the telephony provider.
  void selectProvider(TelephonyProvider provider) =>
      state = state.copyWith(provider: provider);

  /// Switches between buying a new number and using an existing one.
  void setNumberSource(NumberSource source) =>
      state = state.copyWith(numberSource: source);

  /// Picks one of the sample numbers.
  void selectNumber(String number) =>
      state = state.copyWith(selectedNumber: () => number);

  /// Updates the existing number; editing it invalidates a past verification.
  void updateExistingNumber(String number) => state = state.copyWith(
    existingNumber: number,
    existingNumberError: () => null,
    isVerified: false,
  );

  /// Validates the existing number and sends a 6-digit code to it.
  /// Returns true when the code sheet should open.
  Future<bool> sendVerificationCode() async {
    if (state.isSendingCode) return false;
    final error = FormValidators.phone(state.existingNumber);
    if (error != null) {
      state = state.copyWith(existingNumberError: () => error);
      return false;
    }
    state = state.copyWith(isSendingCode: true);

    // TODO(backend): POST /phone-numbers/verify {number, provider} — sends an
    // OTP by SMS/voice through the chosen provider.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return false;

    state = state.copyWith(isSendingCode: false);
    return true;
  }

  /// Checks a 6-digit [code]. Returns an error message, or null when verified.
  /// Any well-formed code is accepted in this phase.
  Future<String?> verifyCode(String code) async {
    final error = FormValidators.otp(code);
    if (error != null || state.isVerifying) return error;
    state = state.copyWith(isVerifying: true);

    // TODO(backend): POST /phone-numbers/verify/confirm {number, code}.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return null;

    state = state.copyWith(isVerifying: false, isVerified: true);
    return null;
  }

  /// Sets the consent confirmation.
  void setConsent(bool confirmed) =>
      state = state.copyWith(consentConfirmed: confirmed);
}

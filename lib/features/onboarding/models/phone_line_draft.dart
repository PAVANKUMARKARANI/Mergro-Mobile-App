import 'package:flutter/foundation.dart';

import 'onboarding_options.dart';

/// Draft for admin step 4: phone line and calling rules.
@immutable
class PhoneLineDraft {
  /// Creates an empty draft.
  const PhoneLineDraft({
    this.provider,
    this.numberSource = NumberSource.newNumber,
    this.selectedNumber,
    this.existingNumber = '',
    this.existingNumberError,
    this.isSendingCode = false,
    this.isVerifying = false,
    this.isVerified = false,
    this.consentConfirmed = false,
  });

  /// Telephony provider (required).
  final TelephonyProvider? provider;

  /// New number or existing number.
  final NumberSource numberSource;

  /// Chosen sample number when buying a new one.
  final String? selectedNumber;

  /// Existing number typed by the admin.
  final String existingNumber;

  /// Validation / verification error for the existing number.
  final String? existingNumberError;

  /// True while the verification code is being sent.
  final bool isSendingCode;

  /// True while the entered code is being checked.
  final bool isVerifying;

  /// True once the existing number was verified.
  final bool isVerified;

  /// Required consent checkbox.
  final bool consentConfirmed;

  /// Provider chosen, a number ready (picked or verified) and consent given.
  bool get isValid {
    final hasNumber = switch (numberSource) {
      NumberSource.newNumber => selectedNumber != null,
      NumberSource.existing => isVerified,
    };
    return provider != null && hasNumber && consentConfirmed;
  }

  /// Copies with changes; nullable fields take getters so they can be cleared.
  PhoneLineDraft copyWith({
    TelephonyProvider? provider,
    NumberSource? numberSource,
    ValueGetter<String?>? selectedNumber,
    String? existingNumber,
    ValueGetter<String?>? existingNumberError,
    bool? isSendingCode,
    bool? isVerifying,
    bool? isVerified,
    bool? consentConfirmed,
  }) {
    return PhoneLineDraft(
      provider: provider ?? this.provider,
      numberSource: numberSource ?? this.numberSource,
      selectedNumber: selectedNumber != null
          ? selectedNumber()
          : this.selectedNumber,
      existingNumber: existingNumber ?? this.existingNumber,
      existingNumberError: existingNumberError != null
          ? existingNumberError()
          : this.existingNumberError,
      isSendingCode: isSendingCode ?? this.isSendingCode,
      isVerifying: isVerifying ?? this.isVerifying,
      isVerified: isVerified ?? this.isVerified,
      consentConfirmed: consentConfirmed ?? this.consentConfirmed,
    );
  }
}

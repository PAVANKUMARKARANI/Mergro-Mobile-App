/// User-facing validation messages, kept in one place for consistency.
abstract final class ValidationMessages {
  /// Shown when an email is empty.
  static const String emailRequired = 'Enter your work email.';

  /// Shown when an email is malformed.
  static const String emailInvalid = 'Enter a valid email address.';

  /// Shown when a phone number is empty.
  static const String phoneRequired = 'Enter a mobile number.';

  /// Shown when a phone number has the wrong number of digits.
  static const String phoneInvalid = 'Enter a valid phone number.';

  /// Shown when a verification code is not the expected length.
  static const String otpInvalid = 'Enter the 6-digit code.';

  /// Builds the "required" message for a named field.
  static String fieldRequired(String fieldName) => 'Enter $fieldName.';
}

/// Pure validation functions. Each returns `null` when the value is valid,
/// otherwise a user-facing error message.
abstract final class FormValidators {
  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Minimum digits in a phone number (national numbers, no country code).
  static const int minPhoneDigits = 7;

  /// Maximum digits in a phone number (E.164 limit, including country code).
  static const int maxPhoneDigits = 15;

  /// Length of a one-time verification code.
  static const int otpLength = 6;

  /// Validates an email address after trimming whitespace.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return ValidationMessages.emailRequired;
    if (!_emailPattern.hasMatch(trimmed)) {
      return ValidationMessages.emailInvalid;
    }
    return null;
  }

  /// Validates that [value] is not blank; [fieldName] reads like "a password".
  static String? required(String? value, String fieldName) {
    if ((value?.trim() ?? '').isEmpty) {
      return ValidationMessages.fieldRequired(fieldName);
    }
    return null;
  }

  /// Validates a phone number by its digit count, ignoring spaces, dashes,
  /// brackets and a leading `+`.
  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return ValidationMessages.phoneRequired;
    final digitCount = trimmed.replaceAll(_nonDigits, '').length;
    if (digitCount < minPhoneDigits || digitCount > maxPhoneDigits) {
      return ValidationMessages.phoneInvalid;
    }
    return null;
  }

  /// Validates a numeric one-time code of exactly [otpLength] digits.
  static String? otp(String? value) {
    final trimmed = value?.trim() ?? '';
    final isDigitsOnly = !_nonDigits.hasMatch(trimmed);
    if (trimmed.length != otpLength || !isDigitsOnly) {
      return ValidationMessages.otpInvalid;
    }
    return null;
  }
}

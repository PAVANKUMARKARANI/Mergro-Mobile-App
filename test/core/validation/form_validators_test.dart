import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/validation/form_validators.dart';

void main() {
  group('FormValidators.email', () {
    test('rejects empty and malformed emails', () {
      expect(FormValidators.email(''), ValidationMessages.emailRequired);
      expect(FormValidators.email('   '), ValidationMessages.emailRequired);
      expect(FormValidators.email('asha@'), ValidationMessages.emailInvalid);
      expect(FormValidators.email('asha.com'), ValidationMessages.emailInvalid);
    });

    test('accepts a valid email with surrounding spaces', () {
      expect(FormValidators.email(' asha@brokerage.co.in '), isNull);
    });
  });

  test('required rejects blank values', () {
    expect(FormValidators.required(' ', 'a password'), 'Enter a password.');
    expect(FormValidators.required('x', 'a password'), isNull);
  });

  test('phone checks digit count and ignores formatting', () {
    expect(FormValidators.phone(''), ValidationMessages.phoneRequired);
    expect(FormValidators.phone('12345'), ValidationMessages.phoneInvalid);
    expect(FormValidators.phone('+91 98765-43210'), isNull);
  });

  test('otp requires exactly six digits', () {
    expect(FormValidators.otp('12345'), ValidationMessages.otpInvalid);
    expect(FormValidators.otp('12a456'), ValidationMessages.otpInvalid);
    expect(FormValidators.otp('123456'), isNull);
  });
}

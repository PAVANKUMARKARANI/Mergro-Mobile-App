import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/validation/form_validators.dart';
import '../../../../shared/ui.dart';
import '../../controllers/phone_line_controller.dart';

/// Bottom sheet asking for the 6-digit code sent to the existing number.
class OtpSheet extends ConsumerStatefulWidget {
  /// Creates the sheet for [phoneNumber].
  const OtpSheet({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
  });

  /// Number the code was sent to.
  final String phoneNumber;

  /// Closes the sheet after successful verification.
  final VoidCallback onVerified;

  /// Creates the state owning the code controller.
  @override
  ConsumerState<OtpSheet> createState() => _OtpSheetState();
}

/// Owns the code field and its error.
class _OtpSheetState extends ConsumerState<OtpSheet> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorText;

  /// Releases the controller.
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Verifies the code and closes on success.
  Future<void> _verify() async {
    final error = await ref
        .read(phoneLineControllerProvider.notifier)
        .verifyCode(_codeController.text);
    if (!mounted) return;
    if (error == null) {
      widget.onVerified();
    } else {
      setState(() => _errorText = error);
    }
  }

  /// Builds the sheet.
  @override
  Widget build(BuildContext context) {
    final isVerifying = ref.watch(
      phoneLineControllerProvider.select((draft) => draft.isVerifying),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: 'Enter verification code',
              subtitle:
                  'We sent a 6-digit code to ${widget.phoneNumber}. '
                  'Any code works in this preview.',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Verification code',
              controller: _codeController,
              prefixIcon: LucideIcons.keyRound,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: FormValidators.otpLength,
              errorText: _errorText,
              enabled: !isVerifying,
              onChanged: (_) => setState(() => _errorText = null),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Verify',
              isLoading: isVerifying,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/forgot_password_controller.dart';
import '../models/login_models.dart';

/// Bottom sheet: email → "Send reset link" → success state → Done.
class ForgotPasswordSheet extends ConsumerStatefulWidget {
  /// Creates the sheet, pre-filled with [initialEmail].
  const ForgotPasswordSheet({
    super.key,
    required this.initialEmail,
    required this.onDone,
  });

  /// Email typed on the login form, if any.
  final String initialEmail;

  /// Closes the sheet.
  final VoidCallback onDone;

  /// Creates the state owning the email controller.
  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

/// Owns the email field controller.
class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail,
  );

  /// Seeds the controller state with the pre-filled email after the first
  /// frame (providers can't be modified during build).
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(forgotPasswordControllerProvider.notifier)
          .updateEmail(widget.initialEmail);
    });
  }

  /// Releases the controller.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Builds the form or the success state.
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppDurations.medium,
          child: state.isSent ? _buildSuccess() : _buildForm(state),
        ),
      ),
    );
  }

  /// Email field and send button.
  Widget _buildForm(ForgotPasswordState state) {
    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Reset your password',
          subtitle: "We'll email you a link to choose a new password.",
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Work email',
          controller: _emailController,
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          errorText: state.emailError,
          enabled: !state.isSending,
          onChanged: controller.updateEmail,
          onSubmitted: (_) => controller.sendResetLink(),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Send reset link',
          isLoading: state.isSending,
          onPressed: controller.sendResetLink,
        ),
      ],
    );
  }

  /// Mail icon, confirmation text and Done.
  Widget _buildSuccess() {
    final palette = context.palette;
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          LucideIcons.mailCheck,
          size: AppSizes.logoMd,
          color: palette.accent,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Check your inbox for a reset link',
          textAlign: TextAlign.center,
          style: context.textStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'Done', onPressed: widget.onDone),
      ],
    );
  }
}

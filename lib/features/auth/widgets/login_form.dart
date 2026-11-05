import '../../../shared/ui.dart';
import '../models/login_models.dart';

/// Email + password fields, "Remember me" / "Forgot password?" row, error
/// banner and the Sign in button. Text controllers and focus nodes belong to
/// the screen's State.
class LoginForm extends StatelessWidget {
  /// Creates the form.
  const LoginForm({
    super.key,
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  /// Current login state.
  final LoginState state;

  /// Email field controller.
  final TextEditingController emailController;

  /// Password field controller.
  final TextEditingController passwordController;

  /// Password focus node (email's Next action moves here).
  final FocusNode passwordFocusNode;

  /// Called on email edits.
  final ValueChanged<String> onEmailChanged;

  /// Called on password edits.
  final ValueChanged<String> onPasswordChanged;

  /// Called when "Remember me" toggles.
  final ValueChanged<bool> onRememberMeChanged;

  /// Opens the forgot-password sheet.
  final VoidCallback onForgotPassword;

  /// Submits the form.
  final VoidCallback onSubmit;

  /// Builds the form.
  @override
  Widget build(BuildContext context) {
    final banner = state.bannerMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Work email',
          hint: 'you@brokerage.com',
          controller: emailController,
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: state.emailError,
          enabled: !state.isBusy,
          onChanged: onEmailChanged,
          onSubmitted: (_) => passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Password',
          controller: passwordController,
          focusNode: passwordFocusNode,
          prefixIcon: LucideIcons.lock,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: state.passwordError,
          enabled: !state.isBusy,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.xs),
        _buildOptionsRow(context),
        if (banner != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InfoBanner(message: banner, type: InfoBannerType.error),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Sign in',
          isLoading: state.isSubmitting,
          onPressed: state.isBusy && !state.isSubmitting ? null : onSubmit,
        ),
      ],
    );
  }

  /// "Remember me" checkbox and the "Forgot password?" link.
  Widget _buildOptionsRow(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => onRememberMeChanged(!state.rememberMe),
          borderRadius: AppRadius.inputAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: state.rememberMe,
                onChanged: (value) => onRememberMeChanged(value ?? false),
              ),
              Text('Remember me', style: context.textStyles.bodyMedium),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
        AppButton(
          label: 'Forgot password?',
          variant: AppButtonVariant.ghost,
          expand: false,
          onPressed: onForgotPassword,
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/login_controller.dart';
import '../models/app_user.dart';
import '../models/login_models.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
import '../widgets/preview_role_selector.dart';
import '../widgets/sso_buttons.dart';

/// Login: navy header, overlapping form card, provider buttons and footer.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the screen with its navigation callbacks.
  const LoginScreen({
    super.key,
    required this.onSignedIn,
    required this.onForgotPassword,
    required this.onCompanySso,
    required this.onRequestAccess,
  });

  /// Called with the user after any successful sign-in.
  final ValueChanged<AppUser> onSignedIn;

  /// Opens the forgot-password sheet, pre-filled with the typed email.
  final ValueChanged<String> onForgotPassword;

  /// Opens the company-SSO sheet.
  final VoidCallback onCompanySso;

  /// Opens the request-access sheet.
  final VoidCallback onRequestAccess;

  /// Creates the state owning the text controllers.
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// Owns text controllers and focus nodes; all logic lives in the controller.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  /// Releases controllers and focus nodes.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Signs in with email and password.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final outcome = await ref.read(loginControllerProvider.notifier).signIn();
    _handleOutcome(outcome);
  }

  /// Signs in with a provider; company SSO opens its own sheet first.
  Future<void> _signInWithProvider(SsoProvider provider) async {
    if (provider == SsoProvider.companySso) {
      widget.onCompanySso();
      return;
    }
    final outcome = await ref
        .read(loginControllerProvider.notifier)
        .signInWithProvider(provider);
    _handleOutcome(outcome);
  }

  /// Navigates on success; failures are already shown from state.
  void _handleOutcome(LoginOutcome outcome) {
    if (!mounted) return;
    if (outcome case LoginSucceeded(:final user)) widget.onSignedIn(user);
  }

  /// Builds the scrollable, keyboard-aware layout.
  @override
  Widget build(BuildContext context) {
    // The navy header sits under the status bar, so its icons must be light.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(),
                  Transform.translate(
                    offset: const Offset(0, -AppSpacing.xl),
                    child: _buildCard(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: SafeArea(
                      top: false,
                      child: LoginFooter(
                        onRequestAccess: widget.onRequestAccess,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Surface card holding the form, provider buttons and preview switch.
  Widget _buildCard() {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: palette.border),
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginForm(
              state: state,
              emailController: _emailController,
              passwordController: _passwordController,
              passwordFocusNode: _passwordFocusNode,
              onEmailChanged: controller.updateEmail,
              onPasswordChanged: controller.updatePassword,
              onRememberMeChanged: controller.setRememberMe,
              onForgotPassword: () =>
                  widget.onForgotPassword(_emailController.text.trim()),
              onSubmit: _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
            SsoButtons(
              activeProvider: state.activeSsoProvider,
              isBusy: state.isBusy,
              onSelected: _signInWithProvider,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.lg),
              PreviewRoleSelector(
                selectedRole: state.previewRole,
                onSelected: controller.setPreviewRole,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

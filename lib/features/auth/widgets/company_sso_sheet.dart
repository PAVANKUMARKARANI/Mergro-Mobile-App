import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/login_controller.dart';
import '../models/app_user.dart';
import '../models/login_models.dart';

/// Bottom sheet asking for a work email to start company SSO.
class CompanySsoSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const CompanySsoSheet({super.key, required this.onSignedIn});

  /// Called with the user after a successful SSO sign-in.
  final ValueChanged<AppUser> onSignedIn;

  /// Creates the state owning the email controller.
  @override
  ConsumerState<CompanySsoSheet> createState() => _CompanySsoSheetState();
}

/// Owns the email field and the last error message.
class _CompanySsoSheetState extends ConsumerState<CompanySsoSheet> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorText;

  /// Releases the controller.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Starts SSO and reacts to the outcome.
  Future<void> _continue() async {
    final outcome = await ref
        .read(loginControllerProvider.notifier)
        .signInWithProvider(
          SsoProvider.companySso,
          workEmail: _emailController.text,
        );
    if (!mounted) return;
    switch (outcome) {
      case LoginSucceeded(:final user):
        widget.onSignedIn(user);
      case LoginFailed(:final message):
        setState(() => _errorText = message);
    }
  }

  /// Builds the sheet.
  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(loginControllerProvider).activeSsoProvider ==
        SsoProvider.companySso;
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
            const SectionHeader(
              title: 'Sign in with company SSO',
              subtitle:
                  "Enter your work email and we'll find your "
                  "brokerage's sign-in page.",
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Work email',
              controller: _emailController,
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.go,
              errorText: _errorText,
              enabled: !isLoading,
              onChanged: (_) => setState(() => _errorText = null),
              onSubmitted: (_) => _continue(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Continue',
              isLoading: isLoading,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

import '../../../shared/ui.dart';

/// "New brokerage? Request access" link and the legal caption.
class LoginFooter extends StatelessWidget {
  /// Creates the footer.
  const LoginFooter({super.key, required this.onRequestAccess});

  /// Opens the request-access sheet.
  final VoidCallback onRequestAccess;

  /// Builds the footer.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('New brokerage?', style: text.bodyMedium),
            AppButton(
              label: 'Request access',
              variant: AppButtonVariant.ghost,
              expand: false,
              onPressed: onRequestAccess,
            ),
          ],
        ),
        Text(
          'By continuing you agree to the Terms and Privacy Policy',
          textAlign: TextAlign.center,
          style: text.labelSmall,
        ),
      ],
    );
  }
}

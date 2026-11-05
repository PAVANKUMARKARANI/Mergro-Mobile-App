import '../../../shared/ui.dart';

/// Info sheet explaining how a new brokerage gets access.
class RequestAccessSheet extends StatelessWidget {
  /// Creates the sheet.
  const RequestAccessSheet({super.key, required this.onClose});

  /// Closes the sheet.
  final VoidCallback onClose;

  /// Builds the sheet.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: 'Bring Mergro to your brokerage',
              subtitle:
                  'Mergro workspaces are set up with our team so your '
                  'CRM, phone line and compliance rules are ready on day one.',
            ),
            const SizedBox(height: AppSpacing.lg),
            const InfoBanner(
              title: 'How it works',
              message:
                  'Share your brokerage details, book a 20-minute '
                  'walkthrough, and your admin gets an invite within one '
                  'business day.',
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Got it', onPressed: onClose),
          ],
        ),
      ),
    );
  }
}

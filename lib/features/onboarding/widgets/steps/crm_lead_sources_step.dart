import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/brokerage_profile_controller.dart';
import '../../controllers/crm_controller.dart';
import '../../models/onboarding_options.dart';
import '../../onboarding_demo_data.dart';

/// Admin step 2: Zoho CRM (required), lead sources and the webhook URL.
class CrmLeadSourcesStep extends ConsumerWidget {
  /// Creates the step.
  const CrmLeadSourcesStep({super.key});

  /// Builds the step.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(crmControllerProvider);
    final controller = ref.read(crmControllerProvider.notifier);
    final country =
        ref.watch(brokerageProfileControllerProvider).country ?? Country.india;
    final sources = OnboardingDemoData.leadSources[country] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'CRM'),
        const SizedBox(height: AppSpacing.sm),
        IntegrationCard(
          name: 'Zoho CRM',
          isRequired: true,
          description: 'Sync leads, call outcomes and bookings both ways.',
          status: draft.zohoStatus,
          onConnect: controller.connectZoho,
          onDisconnect: controller.disconnectZoho,
        ),
        const SizedBox(height: AppSpacing.sm),
        const IntegrationCard(
          name: 'Salesforce',
          description: 'Two-way lead and activity sync.',
          status: IntegrationStatus.comingSoon,
        ),
        const SizedBox(height: AppSpacing.sm),
        const IntegrationCard(
          name: 'HubSpot',
          description: 'Contacts, deals and call logging.',
          status: IntegrationStatus.comingSoon,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Lead sources',
          subtitle:
              'Mergro calls every new lead from these within 60 seconds '
              '(${country.label}).',
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final source in sources) ...[
          SettingSwitchTile(
            title: source,
            value: draft.enabledLeadSources.contains(source),
            onChanged: (_) => controller.toggleLeadSource(source),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.lg),
        const _WebhookCard(url: OnboardingDemoData.webhookUrl),
      ],
    );
  }
}

/// Monospace webhook URL with a Copy button.
class _WebhookCard extends StatelessWidget {
  /// Creates the card for [url].
  const _WebhookCard({required this.url});

  /// Webhook URL to show and copy.
  final String url;

  /// Copies the URL and confirms with a snackbar.
  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Copied')));
  }

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Webhook URL', style: context.textStyles.labelMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Paste this into any form or portal that can post leads.',
            style: context.textStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: AppRadius.inputAll,
            ),
            child: SelectableText(
              url,
              style: AppTypography.mono(palette.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Copy URL',
            variant: AppButtonVariant.secondary,
            leading: const Icon(LucideIcons.copy, size: AppSizes.iconMd),
            onPressed: () => _copy(context),
          ),
        ],
      ),
    );
  }
}

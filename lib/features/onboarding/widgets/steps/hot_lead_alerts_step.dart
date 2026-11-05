import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/agent_profile_controllers.dart';

/// Agent step 2: explainer, alert channels and quiet hours.
class HotLeadAlertsStep extends ConsumerWidget {
  /// Creates the step.
  const HotLeadAlertsStep({super.key});

  /// Builds the step.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(hotLeadAlertsControllerProvider);
    final controller = ref.read(hotLeadAlertsControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InfoBanner(
          title: 'How hot-lead alerts work',
          icon: LucideIcons.flame,
          message:
              "When the AI qualifies a hot lead, we'll alert you. Accept it "
              'to claim the lead and call them back.',
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Alert me by'),
        const SizedBox(height: AppSpacing.sm),
        SettingSwitchTile(
          icon: LucideIcons.bellRing,
          title: 'Push notifications',
          subtitle: 'Instant alert on this phone',
          value: draft.pushEnabled,
          onChanged: controller.setPush,
        ),
        const SizedBox(height: AppSpacing.xs),
        SettingSwitchTile(
          icon: LucideIcons.messageSquareText,
          title: 'SMS fallback',
          subtitle: "Text me if I don't open the push within 60 s",
          value: draft.smsFallbackEnabled,
          onChanged: controller.setSmsFallback,
        ),
        const SizedBox(height: AppSpacing.xs),
        SettingSwitchTile(
          icon: LucideIcons.volume2,
          title: 'Alert sound',
          value: draft.soundEnabled,
          onChanged: controller.setSound,
        ),
        if (!draft.isValid) ...[
          const SizedBox(height: AppSpacing.sm),
          const InfoBanner(
            type: InfoBannerType.error,
            message: 'Keep push or SMS on so hot leads can reach you.',
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        TimeRangeField(
          label: 'Quiet hours',
          start: draft.quietStart,
          end: draft.quietEnd,
          onStartChanged: controller.setQuietStart,
          onEndChanged: controller.setQuietEnd,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'No alert sound during quiet hours. Leads go to the next available '
          'agent.',
          style: context.textStyles.bodySmall,
        ),
      ],
    );
  }
}

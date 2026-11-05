import '../../../shared/ui.dart';
import '../../leads/widgets/lead_badges.dart';
import '../models/lead_profile.dart';

/// Top of the lead profile: who, how to reach them, score, status, source,
/// owner, and a do-not-contact warning when suppressed.
class LeadProfileHeader extends StatelessWidget {
  /// Creates the header.
  const LeadProfileHeader({
    super.key,
    required this.profile,
    required this.now,
  });

  /// The profile shown.
  final LeadProfile profile;

  /// Current time, for "captured … ago".
  final DateTime now;

  /// "Captured 18 min ago", "Captured yesterday" or "Captured on 3 Nov".
  static String capturedLabel(DateTime createdAt, DateTime now) {
    final ago = TimeFormat.ago(createdAt, now);
    if (ago == 'Just now' || ago == 'Yesterday' || ago.endsWith(' ago')) {
      return 'Captured ${ago.toLowerCase()}';
    }
    return 'Captured on $ago';
  }

  /// Builds the header.
  @override
  Widget build(BuildContext context) {
    final lead = profile.lead;
    final text = context.textStyles;
    final email = profile.email;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(
                    name: lead.name,
                    size: AppSizes.controlHeight,
                    tone: lead.status.tone,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.name, style: text.titleMedium),
                        Text(lead.phone, style: text.bodySmall),
                        if (email != null)
                          Text(
                            email,
                            style: text.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  LeadScoreChip(lead: lead),
                  StatusChip(label: lead.status.label, tone: lead.status.tone),
                  StatusChip(label: lead.source.label),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoLine(
                icon: LucideIcons.house,
                text: '${lead.propertyType} · ${lead.budget} · ${lead.area}',
              ),
              _InfoLine(
                icon: LucideIcons.userRound,
                text: 'Owner: ${lead.ownerName ?? 'Unassigned'}',
              ),
              _InfoLine(
                icon: LucideIcons.clock,
                text: capturedLabel(lead.createdAt, now),
              ),
            ],
          ),
        ),
        if (profile.isDoNotContact) ...[
          const SizedBox(height: AppSpacing.sm),
          const InfoBanner(
            type: InfoBannerType.error,
            title: 'Do not contact',
            message: 'This lead opted out. Calls, messages and journeys are stopped.',
          ),
        ],
      ],
    );
  }
}

/// Icon plus one line of secondary text.
class _InfoLine extends StatelessWidget {
  /// Creates the line.
  const _InfoLine({required this.icon, required this.text});

  /// Leading icon.
  final IconData icon;

  /// The text.
  final String text;

  /// Builds the line.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: context.textStyles.bodySmall)),
        ],
      ),
    );
  }
}

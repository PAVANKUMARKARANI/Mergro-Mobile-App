import '../../../shared/ui.dart';
import '../models/lead.dart';
import 'lead_badges.dart';

/// One lead in a list: avatar, name, score, source, area, status and age.
class LeadTile extends StatelessWidget {
  /// Creates the tile.
  const LeadTile({super.key, required this.lead, required this.now});

  /// The lead shown.
  final Lead lead;

  /// Current time, for "3 min ago".
  final DateTime now;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final temperature = lead.temperature;
    return SurfaceCard(
      accentColor: temperature == LeadTemperature.hot ? palette.error : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: lead.name, tone: lead.status.tone),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lead.name,
                        style: text.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      TimeFormat.ago(lead.createdAt, now),
                      style: text.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${lead.propertyType} · ${lead.budget}',
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${lead.source.label} · ${lead.area}',
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    LeadScoreChip(lead: lead),
                    StatusChip(
                      label: lead.status.label,
                      tone: lead.status.tone,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

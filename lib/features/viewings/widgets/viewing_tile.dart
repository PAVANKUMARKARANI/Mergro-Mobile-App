import '../../../shared/ui.dart';
import '../models/viewing.dart';

/// Colour tone per viewing status.
extension ViewingStatusTone on ViewingStatus {
  /// Tone for the status chip.
  StatusTone get tone => switch (this) {
    ViewingStatus.confirmed => StatusTone.success,
    ViewingStatus.pending => StatusTone.warning,
    ViewingStatus.completed => StatusTone.neutral,
    ViewingStatus.noShow => StatusTone.error,
  };
}

/// One viewing: time column, property, lead, agent and status.
class ViewingTile extends StatelessWidget {
  /// Creates the tile.
  const ViewingTile({super.key, required this.viewing});

  /// The viewing shown.
  final Viewing viewing;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSizes.logoLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TimeFormat.clock(viewing.startsAt),
                  style: text.titleSmall,
                ),
                Text('${viewing.durationMinutes} min', style: text.labelSmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(viewing.property, style: text.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                _IconLine(icon: LucideIcons.mapPin, text: viewing.address),
                _IconLine(
                  icon: LucideIcons.userRound,
                  text: '${viewing.leadName} · host ${viewing.agentName}',
                ),
                const SizedBox(height: AppSpacing.xs),
                StatusChip(
                  label: viewing.status.label,
                  tone: viewing.status.tone,
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.calendarCheck,
            size: AppSizes.iconMd,
            color: palette.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Small icon followed by secondary text.
class _IconLine extends StatelessWidget {
  /// Creates the line.
  const _IconLine({required this.icon, required this.text});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: context.palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(child: Text(text, style: context.textStyles.bodySmall)),
        ],
      ),
    );
  }
}

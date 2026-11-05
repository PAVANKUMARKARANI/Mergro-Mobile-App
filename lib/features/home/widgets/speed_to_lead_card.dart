import '../../../shared/ui.dart';
import '../models/dashboard_summary.dart';

/// Compact navy card: today's P95 time-to-call against the 60 s target.
class SpeedToLeadCard extends StatelessWidget {
  /// Creates the card.
  const SpeedToLeadCard({super.key, required this.summary});

  /// Today's numbers.
  final DashboardSummary summary;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final target = summary.speedToLeadTargetSeconds;
    final seconds = summary.speedToLeadSeconds;
    final ratio = seconds == null ? 0.0 : (seconds / target).clamp(0.0, 1.0);
    final status = seconds == null
        ? 'No calls yet'
        : summary.isOnTarget
        ? 'On target'
        : 'Over target';
    final muted = text.bodySmall?.copyWith(color: AppColors.headerSubtitle);
    return Semantics(
      label:
          'Speed to lead today: '
          '${seconds == null ? 'not measured yet' : '$seconds seconds'}, '
          'target $target seconds, $status, '
          '${summary.contactRatePercent} percent reached',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.brandNavy,
          borderRadius: AppRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.timer,
                  size: AppSizes.iconMd,
                  color: AppColors.headerSubtitle,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text('Speed to lead · today (P95)', style: muted),
                ),
                StatusChip(
                  label: status,
                  tone: seconds == null
                      ? StatusTone.neutral
                      : summary.isOnTarget
                      ? StatusTone.success
                      : StatusTone.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  seconds == null ? '—' : TimeFormat.seconds(seconds),
                  style: text.headlineSmall?.copyWith(color: AppColors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: Text('target $target s', style: muted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: AppSizes.progressBarHeight,
                color: summary.isOnTarget ? palette.accent : palette.highlight,
                backgroundColor: AppColors.headerSubtitle.withValues(
                  alpha: AppColors.splashRingOpacity,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              seconds == null
                  ? 'Measured once the AI starts calling new leads'
                  : '${summary.contactRatePercent}% of today\'s leads reached by the AI',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

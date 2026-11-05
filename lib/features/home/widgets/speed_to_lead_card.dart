import '../../../shared/ui.dart';
import '../models/dashboard_summary.dart';

/// Navy hero card: today's P95 time-to-call against the 60 s target.
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
    final ratio = (summary.speedToLeadSeconds / target).clamp(0.0, 1.0);
    final status = summary.isOnTarget ? 'On target' : 'Over target';
    return Semantics(
      label:
          'Speed to lead today: ${summary.speedToLeadSeconds} seconds, '
          'target $target seconds, $status',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.brandNavy,
          borderRadius: AppRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.timer, color: AppColors.headerSubtitle),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Speed to lead · today (P95)',
                    style: text.labelMedium?.copyWith(
                      color: AppColors.headerSubtitle,
                    ),
                  ),
                ),
                StatusChip(
                  label: status,
                  tone: summary.isOnTarget
                      ? StatusTone.success
                      : StatusTone.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              TimeFormat.seconds(summary.speedToLeadSeconds),
              style: text.displaySmall?.copyWith(color: AppColors.white),
            ),
            Text(
              'Every new lead called within $target s · '
              '${summary.contactRatePercent}% reached today',
              style: text.bodySmall?.copyWith(color: AppColors.headerSubtitle),
            ),
            const SizedBox(height: AppSpacing.sm),
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
          ],
        ),
      ),
    );
  }
}

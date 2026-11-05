import '../../../shared/ui.dart';
import '../models/onboarding_flow_models.dart';
import 'step_rail.dart';

/// Admin Review page: a checklist of every step before launch.
class ReviewView extends StatelessWidget {
  /// Creates the review for [flow].
  const ReviewView({super.key, required this.flow});

  /// Current flow state.
  final OnboardingFlowState flow;

  /// Builds the checklist.
  @override
  Widget build(BuildContext context) {
    final skippedCount = flow.skippedSteps.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Review & launch',
            subtitle: 'Mergro starts calling new leads as soon as you launch.',
            isLarge: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var index = 0; index < flow.steps.length; index++) ...[
            _ReviewRow(
              title: flow.steps[index].title,
              isDone: flow.statusAt(index) == StepStatus.done,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (skippedCount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            InfoBanner(
              message: skippedCount == 1
                  ? '1 optional step was skipped. You can finish it later '
                        'from Settings.'
                  : '$skippedCount optional steps were skipped. You can '
                        'finish them later from Settings.',
            ),
          ],
        ],
      ),
    );
  }
}

/// One checklist row: ✓ done, or ○ skipped with "Finish later".
class _ReviewRow extends StatelessWidget {
  /// Creates the row.
  const _ReviewRow({required this.title, required this.isDone});

  /// Step title.
  final String title;

  /// Whether the step was completed (otherwise skipped).
  final bool isDone;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: '$title, ${isDone ? 'done' : 'skipped, finish later'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? LucideIcons.circleCheck : LucideIcons.circle,
              size: AppSizes.iconLg,
              color: isDone ? palette.accent : palette.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(title, style: context.textStyles.titleSmall)),
            if (!isDone)
              const StatusChip(label: 'Finish later', tone: StatusTone.warning),
          ],
        ),
      ),
    );
  }
}

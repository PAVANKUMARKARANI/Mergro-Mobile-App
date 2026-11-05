import '../../../shared/ui.dart';
import '../models/onboarding_flow_models.dart';

/// Status of one step, as shown in the rail and on the Review page.
enum StepStatus {
  /// Finished with Continue.
  done,

  /// Skipped with "Skip for now".
  skipped,

  /// The step on screen.
  current,

  /// Not reached yet.
  upcoming,
}

/// Resolves a step's [StepStatus] from the flow state.
extension StepStatusOf on OnboardingFlowState {
  /// Status of the step at [index].
  StepStatus statusAt(int index) {
    final step = steps[index];
    if (index == currentIndex) return StepStatus.current;
    if (completedSteps.contains(step)) return StepStatus.done;
    if (skippedSteps.contains(step)) return StepStatus.skipped;
    return StepStatus.upcoming;
  }
}

/// Left-hand list of steps shown on wide (≥ 900 px) layouts.
class StepRail extends StatelessWidget {
  /// Creates the rail for [flow].
  const StepRail({super.key, required this.flow});

  /// Current flow state.
  final OnboardingFlowState flow;

  static const double _width = 280;

  /// Builds the rail.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: _width,
      color: palette.surface,
      // Scrolls so long titles at large text sizes never overflow.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MergroLogo(markSize: AppSizes.logoSm),
            const SizedBox(height: AppSpacing.xxl),
            for (var index = 0; index < flow.steps.length; index++)
              _RailItem(
                number: index + 1,
                title: flow.steps[index].title,
                status: flow.statusAt(index),
              ),
            if (flow.hasReview)
              _RailItem(
                number: flow.steps.length + 1,
                title: 'Review & launch',
                status: flow.isReview
                    ? StepStatus.current
                    : StepStatus.upcoming,
              ),
          ],
        ),
      ),
    );
  }
}

/// One rail row: numbered / checked circle and the step title.
class _RailItem extends StatelessWidget {
  /// Creates the row.
  const _RailItem({
    required this.number,
    required this.title,
    required this.status,
  });

  /// 1-based step number.
  final int number;

  /// Step title.
  final String title;

  /// Step status.
  final StepStatus status;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isCurrent = status == StepStatus.current;
    final marker = switch (status) {
      StepStatus.done => Icon(
        LucideIcons.circleCheck,
        size: AppSizes.iconMd,
        color: palette.accent,
      ),
      StepStatus.skipped => Icon(
        LucideIcons.circle,
        size: AppSizes.iconMd,
        color: palette.textSecondary,
      ),
      _ => Text(
        '$number',
        style: context.textStyles.labelMedium?.copyWith(
          color: isCurrent ? palette.accentText : palette.textSecondary,
        ),
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox.square(
            dimension: AppSizes.iconLg,
            child: Center(child: marker),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.w600 : null,
                color: isCurrent ? palette.textPrimary : palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Onboarding header: back arrow, "Step X of N" and a segmented progress bar.
class StepProgressHeader extends StatelessWidget {
  /// Creates a header for step [currentStep] (1-based) of [totalSteps].
  const StepProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.trailing,
    this.label,
  }) : assert(totalSteps > 0),
       assert(currentStep >= 1 && currentStep <= totalSteps);

  /// The active step, starting at 1.
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Back arrow handler; the arrow is hidden when null.
  final VoidCallback? onBack;

  /// Optional widget at the end of the top row (e.g. "Skip for now").
  final Widget? trailing;

  /// Replaces the "Step X of N" text (e.g. "Review").
  final String? label;

  /// Builds the header.
  @override
  Widget build(BuildContext context) {
    final back = onBack;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Row(
            children: [
              if (back != null)
                IconButton(
                  onPressed: back,
                  tooltip: 'Back',
                  icon: const Icon(LucideIcons.arrowLeft),
                ),
              Expanded(
                child: Text(
                  label ?? 'Step $currentStep of $totalSteps',
                  style: context.textStyles.labelMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _SegmentedBar(currentStep: currentStep, totalSteps: totalSteps),
      ],
    );
  }
}

/// Row of rounded segments; steps up to [currentStep] are teal.
class _SegmentedBar extends StatelessWidget {
  /// Creates the bar.
  const _SegmentedBar({required this.currentStep, required this.totalSteps});

  /// The active step, starting at 1.
  final int currentStep;

  /// Total number of segments.
  final int totalSteps;

  /// Builds the segments; exposed to screen readers as a single progress value.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Progress',
      value: 'Step $currentStep of $totalSteps',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var index = 0; index < totalSteps; index++) ...[
            if (index > 0) const SizedBox(width: AppSizes.progressSegmentGap),
            Expanded(
              child: AnimatedContainer(
                duration: disableMotion ? Duration.zero : AppDurations.medium,
                height: AppSizes.progressBarHeight,
                decoration: BoxDecoration(
                  color: index < currentStep ? palette.accent : palette.border,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

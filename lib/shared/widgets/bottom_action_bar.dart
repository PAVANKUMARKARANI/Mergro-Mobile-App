import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'app_button.dart';

/// Sticky footer for step screens: Back (ghost) + Continue (primary), with an
/// optional "Skip for now" link above.
class BottomActionBar extends StatelessWidget {
  /// Creates the bar.
  const BottomActionBar({
    super.key,
    required this.onContinue,
    this.onBack,
    this.onSkip,
    this.continueLabel = 'Continue',
    this.backLabel = 'Back',
    this.skipLabel = 'Skip for now',
    this.isLoading = false,
  });

  /// Continue handler; null disables the button (e.g. step not valid).
  final VoidCallback? onContinue;

  /// Back handler; the Back button is hidden when null.
  final VoidCallback? onBack;

  /// Skip handler; the skip link is hidden when null (required steps).
  final VoidCallback? onSkip;

  /// Primary button text.
  final String continueLabel;

  /// Back button text.
  final String backLabel;

  /// Skip link text.
  final String skipLabel;

  /// Shows a spinner on Continue.
  final bool isLoading;

  /// Builds the bar inside a bottom safe area.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final back = onBack;
    final skip = onSkip;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (skip != null)
                Center(
                  child: AppButton(
                    label: skipLabel,
                    variant: AppButtonVariant.ghost,
                    expand: false,
                    onPressed: isLoading ? null : skip,
                  ),
                ),
              Row(
                children: [
                  if (back != null) ...[
                    AppButton(
                      label: backLabel,
                      variant: AppButtonVariant.ghost,
                      expand: false,
                      onPressed: isLoading ? null : back,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: AppButton(
                      label: continueLabel,
                      isLoading: isLoading,
                      onPressed: onContinue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

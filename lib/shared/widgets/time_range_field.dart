import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_of_day_format.dart';

/// Two side-by-side time buttons (e.g. Open / Close) that open the system
/// time picker.
class TimeRangeField extends StatelessWidget {
  /// Creates the field.
  const TimeRangeField({
    super.key,
    required this.label,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    this.startLabel = 'From',
    this.endLabel = 'To',
    this.errorText,
  });

  /// Label above both buttons.
  final String label;

  /// Start time.
  final TimeOfDay start;

  /// End time.
  final TimeOfDay end;

  /// Called with a newly picked start time.
  final ValueChanged<TimeOfDay> onStartChanged;

  /// Called with a newly picked end time.
  final ValueChanged<TimeOfDay> onEndChanged;

  /// Caption of the start button.
  final String startLabel;

  /// Caption of the end button.
  final String endLabel;

  /// Optional error under the buttons (e.g. end before start).
  final String? errorText;

  /// Builds the label, buttons and error.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final error = errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _TimeButton(
                caption: startLabel,
                time: start,
                onPicked: onStartChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TimeButton(
                caption: endLabel,
                time: end,
                onPicked: onEndChanged,
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            error,
            style: text.bodySmall?.copyWith(color: context.palette.error),
          ),
        ],
      ],
    );
  }
}

/// One bordered button showing a caption and a time.
class _TimeButton extends StatelessWidget {
  /// Creates the button.
  const _TimeButton({
    required this.caption,
    required this.time,
    required this.onPicked,
  });

  /// "From" / "To" caption.
  final String caption;

  /// Shown time.
  final TimeOfDay time;

  /// Called with the picked time.
  final ValueChanged<TimeOfDay> onPicked;

  /// Opens the time picker and reports a new value.
  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) onPicked(picked);
  }

  /// Builds the button.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return Semantics(
      button: true,
      label: '$caption ${time.label24}',
      excludeSemantics: true,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.inputAll,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          borderRadius: AppRadius.inputAll,
          onTap: () => _pick(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.controlHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: AppSizes.iconSm,
                    color: palette.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '$caption ${time.label24}',
                      style: text.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

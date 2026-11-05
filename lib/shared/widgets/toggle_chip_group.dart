import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Wrap of multi-select chips (languages, weekdays…).
class ToggleChipGroup<T> extends StatelessWidget {
  /// Creates a chip group over [options].
  const ToggleChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onToggled,
    this.label,
  });

  /// Choices in display order.
  final List<T> options;

  /// Currently selected choices.
  final Set<T> selected;

  /// Display text for an option.
  final String Function(T option) labelOf;

  /// Called with the option whose chip was tapped.
  final ValueChanged<T> onToggled;

  /// Optional label above the chips.
  final String? label;

  /// Builds the label and chips.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final groupLabel = label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (groupLabel != null) ...[
          Text(groupLabel, style: text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
        ],
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(labelOf(option)),
                selected: selected.contains(option),
                onSelected: (_) => onToggled(option),
                showCheckmark: true,
                checkmarkColor: palette.accentText,
                selectedColor: palette.successContainer,
                backgroundColor: palette.surface,
                side: BorderSide(
                  color: selected.contains(option)
                      ? palette.accent
                      : palette.border,
                ),
                labelStyle: text.labelMedium?.copyWith(
                  color: selected.contains(option)
                      ? palette.textPrimary
                      : palette.textSecondary,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.inputAll,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

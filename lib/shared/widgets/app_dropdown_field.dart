import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Labelled single-choice dropdown that matches [AppTextField]'s look.
class AppDropdownField<T> extends StatelessWidget {
  /// Creates a dropdown over [options].
  const AppDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.labelOf,
    required this.value,
    required this.onChanged,
    this.hint,
    this.isRequired = false,
  });

  /// Text shown above the field.
  final String label;

  /// Choices in display order.
  final List<T> options;

  /// Display text for an option.
  final String Function(T option) labelOf;

  /// Selected option, or null for none.
  final T? value;

  /// Called with the new selection.
  final ValueChanged<T> onChanged;

  /// Placeholder when nothing is selected.
  final String? hint;

  /// Appends " *" to the label.
  final bool isRequired;

  /// Builds the label and dropdown.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(isRequired ? '$label *' : label, style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          initialValue: options.contains(value) ? value : null,
          isExpanded: true,
          hint: hint == null ? null : Text(hint ?? '', style: text.bodyMedium),
          style: text.bodyLarge,
          dropdownColor: context.palette.surface,
          items: [
            for (final option in options)
              DropdownMenuItem<T>(
                value: option,
                child: Text(labelOf(option), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}

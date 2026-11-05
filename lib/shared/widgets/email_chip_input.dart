import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Email field that turns entries into removable chips.
///
/// An entry is committed by the Add button, the keyboard action, or typing a
/// comma or space. The parent validates and stores it in [onAdd], returning an
/// error message to keep the text in the field, or null to accept and clear it.
class EmailChipInput extends StatefulWidget {
  /// Creates the input.
  const EmailChipInput({
    super.key,
    required this.label,
    required this.emails,
    required this.onAdd,
    required this.onRemove,
    this.hint,
    this.addLabel = 'Add',
  });

  /// Field label.
  final String label;

  /// Emails already added, shown as chips.
  final List<String> emails;

  /// Validates and stores an email; returns an error message or null.
  final String? Function(String email) onAdd;

  /// Removes an email chip.
  final ValueChanged<String> onRemove;

  /// Placeholder text.
  final String? hint;

  /// Add button text.
  final String addLabel;

  /// Creates the state holding the text controller and inline error.
  @override
  State<EmailChipInput> createState() => _EmailChipInputState();
}

/// Owns the text controller, focus node and the last validation error.
class _EmailChipInputState extends State<EmailChipInput> {
  static const List<String> _separators = [',', ' '];

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  /// Releases the controller and focus node.
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Commits the current text; keeps focus so several emails can be typed.
  void _commit() {
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    final error = widget.onAdd(email);
    setState(() => _errorText = error);
    if (error == null) _controller.clear();
    _focusNode.requestFocus();
  }

  /// Commits when a separator is typed; clears a stale error otherwise.
  void _handleChanged(String value) {
    final endsWithSeparator = _separators.any(value.endsWith);
    if (endsWithSeparator) {
      _controller.text = value.substring(0, value.length - 1);
      _commit();
    } else if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  /// Builds the field, Add button and chips.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                label: widget.label,
                hint: widget.hint,
                controller: _controller,
                focusNode: _focusNode,
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onChanged: _handleChanged,
                onSubmitted: (_) => _commit(),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            AppButton(
              label: widget.addLabel,
              variant: AppButtonVariant.secondary,
              expand: false,
              onPressed: _commit,
            ),
          ],
        ),
        if (_errorText case final error?) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            error,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.palette.error,
            ),
          ),
        ],
        if (widget.emails.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _EmailChips(emails: widget.emails, onRemove: widget.onRemove),
        ],
      ],
    );
  }
}

/// Wrap of removable email chips.
class _EmailChips extends StatelessWidget {
  /// Creates the chip list.
  const _EmailChips({required this.emails, required this.onRemove});

  /// Emails to show.
  final List<String> emails;

  /// Called with the email whose delete icon was tapped.
  final ValueChanged<String> onRemove;

  /// Builds the chips.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final email in emails)
          InputChip(
            label: Text(email, style: context.textStyles.labelMedium),
            backgroundColor: palette.background,
            side: BorderSide(color: palette.border),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.inputAll,
            ),
            deleteIcon: const Icon(LucideIcons.x, size: AppSizes.iconSm),
            deleteButtonTooltipMessage: 'Remove $email',
            onDeleted: () => onRemove(email),
          ),
      ],
    );
  }
}

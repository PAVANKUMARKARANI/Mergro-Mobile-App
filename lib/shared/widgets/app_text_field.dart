import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Labelled text input with an optional prefix icon, password visibility
/// toggle and error text.
///
/// The label sits above the field rather than floating inside it, which keeps
/// the 52 px field readable at large text scales.
class AppTextField extends StatefulWidget {
  /// Creates a labelled input.
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.prefixIcon,
    this.errorText,
    this.isPassword = false,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.suffix,
  });

  /// Text shown above the field.
  final String label;

  /// Controller owned by the parent widget's State.
  final TextEditingController? controller;

  /// Focus node owned by the parent widget's State.
  final FocusNode? focusNode;

  /// Placeholder text.
  final String? hint;

  /// Icon shown at the start of the field.
  final IconData? prefixIcon;

  /// Validation message; shows the error style when non-null.
  final String? errorText;

  /// Obscures input and shows a show/hide toggle.
  final bool isPassword;

  /// Appends " *" to the label.
  final bool isRequired;

  /// Whether the field accepts input.
  final bool enabled;

  /// Shows the value without allowing edits (e.g. picker fields).
  final bool readOnly;

  /// Keyboard type, e.g. email or phone.
  final TextInputType? keyboardType;

  /// Keyboard action button (Next / Done).
  final TextInputAction? textInputAction;

  /// Auto-capitalisation behaviour.
  final TextCapitalization textCapitalization;

  /// Autofill hints for password managers.
  final Iterable<String>? autofillHints;

  /// Input formatters (e.g. digits only).
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum length; the counter is hidden.
  final int? maxLength;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard action is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Called when the field is tapped (used by read-only picker fields).
  final VoidCallback? onTap;

  /// Optional trailing widget; ignored when [isPassword] is true.
  final Widget? suffix;

  /// Creates the state that tracks password visibility.
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

/// Holds the password visibility toggle.
class _AppTextFieldState extends State<AppTextField> {
  bool _isObscured = true;

  /// Flips password visibility.
  void _toggleObscured() => setState(() => _isObscured = !_isObscured);

  /// Builds the label and the input.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final label = widget.isRequired ? '${widget.label} *' : widget.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword && _isObscured,
          enableSuggestions: !widget.isPassword,
          autocorrect: !widget.isPassword,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            errorMaxLines: 3,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: AppSizes.iconMd),
            suffixIcon: widget.isPassword ? _buildToggle() : widget.suffix,
          ),
        ),
      ],
    );
  }

  /// Eye / eye-off button that reveals or hides the password.
  Widget _buildToggle() {
    return IconButton(
      onPressed: _toggleObscured,
      tooltip: _isObscured ? 'Show password' : 'Hide password',
      icon: Icon(
        _isObscured ? LucideIcons.eye : LucideIcons.eyeOff,
        size: AppSizes.iconMd,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Visual style of an [AppButton].
enum AppButtonVariant {
  /// Filled navy (light) / teal (dark) call to action.
  primary,

  /// Outlined, surface-coloured secondary action.
  secondary,

  /// Text-only, low-emphasis action.
  ghost,

  /// Outlined provider sign-in button with a leading logo/icon.
  sso,
}

/// The app's single button: 52 px high, 12 px radius, with loading and
/// disabled states.
///
/// Passing `onPressed: null` disables it. While [isLoading] is true it shows a
/// spinner, ignores taps and keeps its enabled colours so it does not flicker.
class AppButton extends StatelessWidget {
  /// Creates a button with the given [label] and [variant].
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leading,
    this.expand = true,
  });

  /// Button text.
  final String label;

  /// Tap handler; `null` disables the button.
  final VoidCallback? onPressed;

  /// Visual style.
  final AppButtonVariant variant;

  /// Shows a spinner instead of the label and blocks taps.
  final bool isLoading;

  /// Optional widget shown before the label (icon or provider logo).
  final Widget? leading;

  /// Whether the button stretches to the full available width.
  final bool expand;

  /// Builds the button for the current variant.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = _styleFor(palette, context.textStyles);
    final handler = isLoading ? () {} : onPressed;
    final child = _ButtonContent(
      label: label,
      leading: leading,
      isLoading: isLoading,
      spinnerColor: _foregroundFor(palette),
    );
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: handler,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary || AppButtonVariant.sso => OutlinedButton(
        onPressed: handler,
        style: style,
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: handler,
        style: style,
        child: child,
      ),
    };
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: isLoading ? '$label, loading' : null,
      excludeSemantics: isLoading,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  /// Label / spinner colour for the variant.
  Color _foregroundFor(AppPalette palette) => switch (variant) {
    AppButtonVariant.primary => palette.onPrimaryButton,
    AppButtonVariant.ghost => palette.accentText,
    _ => palette.textPrimary,
  };

  /// Shared shape, size and colours for every variant.
  ButtonStyle _styleFor(AppPalette palette, TextTheme text) {
    final isPrimary = variant == AppButtonVariant.primary;
    final isOutlined =
        variant == AppButtonVariant.secondary ||
        variant == AppButtonVariant.sso;
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(AppSizes.minTouchTarget, AppSizes.controlHeight),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
      ),
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? palette.textSecondary
            : _foregroundFor(palette),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (isPrimary) {
          return states.contains(WidgetState.disabled)
              ? palette.border
              : palette.primaryButton;
        }
        return isOutlined ? palette.surface : null;
      }),
      side: isOutlined
          ? WidgetStatePropertyAll(
              BorderSide(color: palette.border, width: AppSizes.borderThin),
            )
          : null,
    );
  }
}

/// Label row (optional leading widget + text) or a loading spinner.
class _ButtonContent extends StatelessWidget {
  /// Creates the inner content of an [AppButton].
  const _ButtonContent({
    required this.label,
    required this.leading,
    required this.isLoading,
    required this.spinnerColor,
  });

  /// Button text.
  final String label;

  /// Optional leading widget.
  final Widget? leading;

  /// Whether to show the spinner instead of the label.
  final bool isLoading;

  /// Spinner colour.
  final Color spinnerColor;

  /// Builds either the spinner or the label row.
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: AppSizes.buttonSpinner,
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.spinnerStroke,
          color: spinnerColor,
        ),
      );
    }
    final text = Text(label, textAlign: TextAlign.center, maxLines: 2);
    final leadingWidget = leading;
    if (leadingWidget == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leadingWidget,
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}

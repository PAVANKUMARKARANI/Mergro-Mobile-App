import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brightness-aware semantic colours, attached to [ThemeData] as an extension.
///
/// Read it with `context.palette` (see `app_theme.dart`).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Creates a palette from explicit semantic colours.
  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.brandNavy,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.violet,
    required this.violetContainer,
    required this.error,
    required this.errorContainer,
    required this.success,
    required this.successContainer,
    required this.highlight,
    required this.onHighlight,
    required this.primaryButton,
    required this.onPrimaryButton,
  });

  /// Light-mode palette.
  static const AppPalette light = AppPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    border: AppColors.lightBorder,
    brandNavy: AppColors.lightBrandNavy,
    accent: AppColors.lightAccent,
    accentText: AppColors.lightAccentText,
    onAccent: AppColors.splashNavy,
    violet: AppColors.lightViolet,
    violetContainer: AppColors.lightVioletContainer,
    error: AppColors.lightError,
    errorContainer: AppColors.lightErrorContainer,
    success: AppColors.lightSuccess,
    successContainer: AppColors.lightSuccessContainer,
    highlight: AppColors.highlightAmber,
    onHighlight: AppColors.lightTextPrimary,
    primaryButton: AppColors.lightBrandNavy,
    onPrimaryButton: AppColors.white,
  );

  /// Dark-mode palette.
  static const AppPalette dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    brandNavy: AppColors.darkBrandNavy,
    accent: AppColors.darkAccent,
    accentText: AppColors.darkAccent,
    onAccent: AppColors.splashNavy,
    violet: AppColors.darkViolet,
    violetContainer: AppColors.darkVioletContainer,
    error: AppColors.darkError,
    errorContainer: AppColors.darkErrorContainer,
    success: AppColors.darkSuccess,
    successContainer: AppColors.darkSuccessContainer,
    highlight: AppColors.highlightAmber,
    onHighlight: AppColors.splashNavy,
    primaryButton: AppColors.darkAccent,
    onPrimaryButton: AppColors.splashNavy,
  );

  /// Page background.
  final Color background;

  /// Card and sheet surface.
  final Color surface;

  /// Primary text.
  final Color textPrimary;

  /// Secondary text (hints, captions).
  final Color textSecondary;

  /// Borders and dividers.
  final Color border;

  /// Navy used for headers.
  final Color brandNavy;

  /// Teal used for fills, focus, active steps and icons.
  final Color accent;

  /// Teal that meets 4.5:1 when used as text on [surface] or [background].
  final Color accentText;

  /// Text and icons placed on an [accent] fill.
  final Color onAccent;

  /// Setup violet foreground (info tone).
  final Color violet;

  /// Setup violet container (info tone background).
  final Color violetContainer;

  /// Error foreground.
  final Color error;

  /// Error container.
  final Color errorContainer;

  /// Success foreground.
  final Color success;

  /// Success container.
  final Color successContainer;

  /// Amber highlight fill.
  final Color highlight;

  /// Text and icons placed on a [highlight] fill.
  final Color onHighlight;

  /// Primary button fill (navy in light mode, teal in dark mode).
  final Color primaryButton;

  /// Label colour on [primaryButton].
  final Color onPrimaryButton;

  /// Returns this palette unchanged. Palettes are fixed per brightness, so
  /// use [light] or [dark] rather than copying with overrides.
  @override
  AppPalette copyWith() => this;

  /// Interpolates every colour so theme changes animate smoothly.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AppPalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      border: mix(border, other.border),
      brandNavy: mix(brandNavy, other.brandNavy),
      accent: mix(accent, other.accent),
      accentText: mix(accentText, other.accentText),
      onAccent: mix(onAccent, other.onAccent),
      violet: mix(violet, other.violet),
      violetContainer: mix(violetContainer, other.violetContainer),
      error: mix(error, other.error),
      errorContainer: mix(errorContainer, other.errorContainer),
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      highlight: mix(highlight, other.highlight),
      onHighlight: mix(onHighlight, other.onHighlight),
      primaryButton: mix(primaryButton, other.primaryButton),
      onPrimaryButton: mix(onPrimaryButton, other.onPrimaryButton),
    );
  }
}

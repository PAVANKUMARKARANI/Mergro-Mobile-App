import 'package:flutter/widgets.dart';

/// Raw Mergro colour values from the design spec.
///
/// Widgets should not use these directly. Read the brightness-aware
/// `AppPalette` from the theme (`context.palette`) instead, so light and dark
/// mode stay consistent.
abstract final class AppColors {
  // Light theme.
  /// Light page background.
  static const Color lightBackground = Color(0xFFEDF0F6);

  /// Light card / sheet surface.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light primary text.
  static const Color lightTextPrimary = Color(0xFF141D33);

  /// Light secondary text.
  static const Color lightTextSecondary = Color(0xFF56607A);

  /// Light borders and dividers.
  static const Color lightBorder = Color(0xFFD3D9E6);

  /// Brand navy used for headers and the light primary button.
  static const Color lightBrandNavy = Color(0xFF12224A);

  /// Teal accent used for fills, focus rings and icons in light mode.
  static const Color lightAccent = Color(0xFF0E9482);

  /// Darker teal for teal *text* on light surfaces; plain teal is 3.8:1, below
  /// the 4.5:1 contrast target.
  static const Color lightAccentText = Color(0xFF0B7A6B);

  /// Setup violet foreground in light mode.
  static const Color lightViolet = Color(0xFF4A39B3);

  /// Setup violet container in light mode.
  static const Color lightVioletContainer = Color(0xFFF3F0FF);

  /// Error foreground in light mode.
  static const Color lightError = Color(0xFFAE2F2F);

  /// Error container in light mode.
  static const Color lightErrorContainer = Color(0xFFFDEEEE);

  /// Success foreground in light mode.
  static const Color lightSuccess = Color(0xFF1C7643);

  /// Success container in light mode.
  static const Color lightSuccessContainer = Color(0xFFEBF7EF);

  // Dark theme.
  /// Dark page background.
  static const Color darkBackground = Color(0xFF090E1B);

  /// Dark card / sheet surface.
  static const Color darkSurface = Color(0xFF0F172B);

  /// Dark primary text.
  static const Color darkTextPrimary = Color(0xFFE5EAF5);

  /// Dark secondary text.
  static const Color darkTextSecondary = Color(0xFFA3AEC7);

  /// Dark borders and dividers.
  static const Color darkBorder = Color(0xFF26324D);

  /// Brand navy used for headers in dark mode.
  static const Color darkBrandNavy = Color(0xFF0A1532);

  /// Teal accent in dark mode; also the dark primary button fill.
  static const Color darkAccent = Color(0xFF3CC9B4);

  /// Setup violet foreground in dark mode.
  static const Color darkViolet = Color(0xFFC3B9FF);

  /// Setup violet container in dark mode.
  static const Color darkVioletContainer = Color(0xFF1F1B42);

  /// Error foreground in dark mode.
  static const Color darkError = Color(0xFFF5AAAA);

  /// Error container in dark mode.
  static const Color darkErrorContainer = Color(0xFF371517);

  /// Success foreground in dark mode.
  static const Color darkSuccess = Color(0xFF8FDDAE);

  /// Success container in dark mode.
  static const Color darkSuccessContainer = Color(0xFF0E2B1D);

  // Shared.
  /// Deep navy behind the native and Flutter splash, and text on teal fills.
  static const Color splashNavy = Color(0xFF0A1532);

  /// Splash tagline colour.
  static const Color splashTagline = Color(0xFFAEBBDD);

  /// Highlight amber for warnings and emphasis.
  static const Color highlightAmber = Color(0xFFF4B740);

  /// Subtitle text on navy headers.
  static const Color headerSubtitle = Color(0xFFC3CEEA);

  /// Opacity of the teal glow behind the splash logo.
  static const double splashGlowOpacity = 0.08;

  /// Starting opacity of a splash call ring.
  static const double splashRingOpacity = 0.35;

  /// Placeholder brand colours for provider marks until SVG logos exist.
  static const Color googleBlue = Color(0xFF4285F4);

  /// Microsoft logo red square.
  static const Color microsoftRed = Color(0xFFF25022);

  /// Microsoft logo green square.
  static const Color microsoftGreen = Color(0xFF7FBA00);

  /// Microsoft logo blue square.
  static const Color microsoftBlue = Color(0xFF00A4EF);

  /// Microsoft logo yellow square.
  static const Color microsoftYellow = Color(0xFFFFB900);

  /// Pure white for text and icons on navy.
  static const Color white = Color(0xFFFFFFFF);

  /// Fully transparent colour.
  static const Color transparent = Color(0x00000000);
}

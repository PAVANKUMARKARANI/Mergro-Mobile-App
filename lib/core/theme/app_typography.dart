import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mergro type scale: Sora for headings, Figtree for body and labels,
/// JetBrains Mono for URLs.
///
/// Role → Material slot:
/// display 28 → `displaySmall`, login title 24 → `headlineSmall`,
/// title 22 → `titleLarge`, heading 18 → `titleMedium`,
/// card title 15 → `titleSmall`, body 15 → `bodyLarge` / `bodyMedium`,
/// label 13 → `labelMedium` / `bodySmall`, button 15 → `labelLarge`,
/// caption 12 → `labelSmall`.
abstract final class AppTypography {
  /// Display size.
  static const double display = 28;

  /// Large header size (login "Welcome back").
  static const double headline = 24;

  /// Title size.
  static const double title = 22;

  /// Heading size.
  static const double heading = 18;

  /// Body size.
  static const double body = 15;

  /// Label size.
  static const double label = 13;

  /// Caption size.
  static const double caption = 12;

  /// Whether fonts load from Google Fonts. Tests set this to false because
  /// the test environment has no network and would fail to fetch fonts.
  @visibleForTesting
  static bool useGoogleFonts = true;

  /// Builds a Sora (heading) style.
  static TextStyle sora(double size, FontWeight weight, Color color) {
    final base = TextStyle(fontSize: size, fontWeight: weight, color: color);
    return useGoogleFonts ? GoogleFonts.sora(textStyle: base) : base;
  }

  /// Builds a Figtree (body / label) style.
  static TextStyle figtree(double size, FontWeight weight, Color color) {
    final base = TextStyle(fontSize: size, fontWeight: weight, color: color);
    return useGoogleFonts ? GoogleFonts.figtree(textStyle: base) : base;
  }

  /// Builds a JetBrains Mono style for URLs and codes.
  static TextStyle mono(Color color, {double size = label}) {
    final base = TextStyle(fontSize: size, color: color);
    return useGoogleFonts ? GoogleFonts.jetBrainsMono(textStyle: base) : base;
  }

  /// Wordmark style for the "Mergro" logo text at the given [size].
  static TextStyle wordmark(double size, Color color) =>
      sora(size, FontWeight.w700, color);

  /// Builds the full Material [TextTheme] for the given text colours.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displaySmall: sora(display, FontWeight.w700, primary),
      headlineSmall: sora(headline, FontWeight.w700, primary),
      titleLarge: sora(title, FontWeight.w600, primary),
      titleMedium: sora(heading, FontWeight.w600, primary),
      titleSmall: figtree(body, FontWeight.w600, primary),
      bodyLarge: figtree(body, FontWeight.w400, primary),
      bodyMedium: figtree(body, FontWeight.w400, primary),
      bodySmall: figtree(label, FontWeight.w400, secondary),
      labelLarge: figtree(body, FontWeight.w600, primary),
      labelMedium: figtree(label, FontWeight.w600, primary),
      labelSmall: figtree(caption, FontWeight.w500, secondary),
    );
  }
}

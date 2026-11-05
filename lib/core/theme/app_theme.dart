import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Material 3 light and dark themes from [AppPalette].
abstract final class AppTheme {
  /// Light theme.
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  /// Dark theme.
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  /// Maps the palette onto a [ColorScheme] and component themes.
  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.primaryButton,
      onPrimary: palette.onPrimaryButton,
      secondary: palette.accent,
      onSecondary: palette.onAccent,
      tertiary: palette.violet,
      onTertiary: palette.surface,
      error: palette.error,
      onError: palette.surface,
      errorContainer: palette.errorContainer,
      onErrorContainer: palette.error,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.border,
      outlineVariant: palette.border,
    );
    final textTheme = AppTypography.textTheme(
      primary: palette.textPrimary,
      secondary: palette.textSecondary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      extensions: [palette],
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: AppSizes.borderThin,
        space: AppSpacing.xl,
      ),
      inputDecorationTheme: _inputTheme(palette, textTheme),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionHandleColor: palette.accent,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accent
              : palette.surface,
        ),
        checkColor: WidgetStatePropertyAll(palette.onAccent),
        side: BorderSide(color: palette.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.onAccent
              : palette.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accent
              : palette.border,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.brandNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonAll),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.violetContainer,
        surfaceTintColor: AppColors.transparent,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.iconLg,
            color: states.contains(WidgetState.selected)
                ? palette.violet
                : palette.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.violetContainer,
        selectedIconTheme: IconThemeData(color: palette.violet),
        unselectedIconTheme: IconThemeData(color: palette.textSecondary),
        selectedLabelTextStyle: textTheme.labelMedium,
        unselectedLabelTextStyle: textTheme.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleMedium,
      ),
    );
  }

  /// Outlined input style: 8 px radius, teal focus ring, 52 px minimum height.
  static InputDecorationTheme _inputTheme(AppPalette palette, TextTheme text) {
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: AppRadius.inputAll,
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      constraints: const BoxConstraints(minHeight: AppSizes.controlHeight),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      hintStyle: text.bodyMedium?.copyWith(color: palette.textSecondary),
      errorStyle: text.bodySmall?.copyWith(color: palette.error),
      prefixIconColor: palette.textSecondary,
      suffixIconColor: palette.textSecondary,
      border: outline(palette.border, AppSizes.borderThin),
      enabledBorder: outline(palette.border, AppSizes.borderThin),
      focusedBorder: outline(palette.accent, AppSizes.borderThick),
      errorBorder: outline(palette.error, AppSizes.borderThin),
      focusedErrorBorder: outline(palette.error, AppSizes.borderThick),
      disabledBorder: outline(palette.border, AppSizes.borderThin),
    );
  }
}

/// Shortcuts for reading theme tokens from a [BuildContext].
extension AppThemeContext on BuildContext {
  /// The active [AppPalette]; falls back to light if the theme lacks one.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// The active text theme.
  TextTheme get textStyles => Theme.of(this).textTheme;
}

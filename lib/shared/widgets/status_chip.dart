import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Colour tone of a [StatusChip] or banner.
enum StatusTone {
  /// Grey, informational-only state (e.g. "Not connected", "Coming soon").
  neutral,

  /// Violet in-progress / informational state (e.g. "Connecting…").
  info,

  /// Green positive state (e.g. "Connected").
  success,

  /// Amber attention state.
  warning,

  /// Red failure state.
  error,
}

/// Foreground / background colour pair for a [StatusTone].
typedef ToneColors = ({Color foreground, Color background});

/// Resolves the colours for a [StatusTone] from the palette.
extension StatusToneColors on StatusTone {
  /// Returns the foreground and background colours for this tone.
  ToneColors colorsFrom(AppPalette palette) => switch (this) {
    StatusTone.neutral => (
      foreground: palette.textSecondary,
      background: palette.background,
    ),
    StatusTone.info => (
      foreground: palette.violet,
      background: palette.violetContainer,
    ),
    StatusTone.success => (
      foreground: palette.success,
      background: palette.successContainer,
    ),
    StatusTone.warning => (
      foreground: palette.onHighlight,
      background: palette.highlight,
    ),
    StatusTone.error => (
      foreground: palette.error,
      background: palette.errorContainer,
    ),
  };
}

/// Small pill showing a status label with an optional leading icon.
class StatusChip extends StatelessWidget {
  /// Creates a status chip.
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  /// Text inside the chip.
  final String label;

  /// Colour tone.
  final StatusTone tone;

  /// Optional leading icon.
  final IconData? icon;

  /// Builds the pill.
  @override
  Widget build(BuildContext context) {
    final colors = tone.colorsFrom(context.palette);
    final chipIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chipIcon != null) ...[
            Icon(chipIcon, size: AppSizes.iconSm, color: colors.foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

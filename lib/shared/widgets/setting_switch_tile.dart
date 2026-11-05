import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Card-style row with a title, optional caption and a switch. A locked tile
/// shows a lock icon and cannot be changed (e.g. compliance settings).
class SettingSwitchTile extends StatelessWidget {
  /// Creates a switch tile.
  const SettingSwitchTile({
    super.key,
    required this.title,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.icon,
    this.isLocked = false,
  });

  /// Main label.
  final String title;

  /// Switch value.
  final bool value;

  /// Called with the new value; ignored when [isLocked].
  final ValueChanged<bool>? onChanged;

  /// Optional caption.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Shows a lock and disables the switch.
  final bool isLocked;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final tileIcon = isLocked ? LucideIcons.lock : icon;
    final caption = subtitle;
    return Semantics(
      toggled: value,
      enabled: !isLocked && onChanged != null,
      label: isLocked ? '$title, locked' : title,
      excludeSemantics: true,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: isLocked || onChanged == null
              ? null
              : () => onChanged?.call(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                if (tileIcon != null) ...[
                  Icon(
                    tileIcon,
                    size: AppSizes.iconMd,
                    color: palette.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleSmall),
                      if (caption != null) Text(caption, style: text.bodySmall),
                    ],
                  ),
                ),
                Switch(value: value, onChanged: isLocked ? null : onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

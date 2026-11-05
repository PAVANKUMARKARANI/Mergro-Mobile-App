import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'status_chip.dart';
import 'surface_card.dart';

/// A KPI: icon, big value, label and an optional caption such as a target.
class MetricTile extends StatelessWidget {
  /// Creates a tile.
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.tone = StatusTone.neutral,
    this.onTap,
    this.isDense = false,
  });

  /// What is measured, e.g. "New leads".
  final String label;

  /// The figure, e.g. "38" or "42 s".
  final String value;

  /// Leading icon.
  final IconData icon;

  /// Extra context, e.g. "Target 60 s".
  final String? caption;

  /// Colour of the icon and caption (success when on target, etc.).
  final StatusTone tone;

  /// Opens the related screen.
  final VoidCallback? onTap;

  /// Compact layout: tinted icon on the left, value and label on the right
  /// (dashboard grid). The default stacks them vertically.
  final bool isDense;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final colors = tone.colorsFrom(palette);
    // The warning foreground is meant for amber chips; on a dark card it
    // would vanish, so the icon uses the amber itself there.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = tone == StatusTone.warning && isDark
        ? palette.highlight
        : colors.foreground;
    final note = caption;
    return SurfaceCard(
      onTap: onTap,
      semanticLabel: '$label: $value${note == null ? '' : ', $note'}',
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: ExcludeSemantics(
        child: isDense
            // On its tinted circle the icon uses the tone's paired colour.
            ? _dense(context, colors.foreground, colors.background)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: AppSizes.iconMd, color: iconColor),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: text.titleLarge, maxLines: 1),
                  Text(
                    label,
                    style: text.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    StatusChip(label: note, tone: tone),
                  ],
                ],
              ),
      ),
    );
  }

  /// Icon in a tinted circle, then the value over the label.
  Widget _dense(BuildContext context, Color iconColor, Color tint) {
    final text = context.textStyles;
    return Row(
      children: [
        Container(
          width: AppSizes.cardIconTile,
          height: AppSizes.cardIconTile,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(icon, size: AppSizes.iconMd, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: text.titleLarge, maxLines: 1),
              Text(
                label,
                style: text.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

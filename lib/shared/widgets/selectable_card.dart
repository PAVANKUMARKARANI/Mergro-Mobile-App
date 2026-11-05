import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Tappable option card with an icon, title, subtitle and a check when
/// selected. Used for single-choice options such as provider or voice.
class SelectableCard extends StatelessWidget {
  /// Creates a selectable card.
  const SelectableCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.trailing,
  });

  /// Main label.
  final String title;

  /// Whether this option is currently chosen.
  final bool isSelected;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// Optional icon shown in a tinted tile.
  final IconData? icon;

  /// Optional supporting text.
  final String? subtitle;

  /// Optional extra control before the check (e.g. a play button).
  final Widget? trailing;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final cardIcon = icon;
    final cardSubtitle = subtitle;
    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(
            color: isSelected ? palette.accent : palette.border,
            width: isSelected ? AppSizes.borderThick : AppSizes.borderThin,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.controlHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  if (cardIcon != null) ...[
                    _IconTile(icon: cardIcon, isSelected: isSelected),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.titleSmall),
                        if (cardSubtitle != null)
                          Text(cardSubtitle, style: text.bodySmall),
                      ],
                    ),
                  ),
                  ?trailing,
                  _SelectedCheck(isSelected: isSelected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded square holding the option icon; teal-tinted when selected.
class _IconTile extends StatelessWidget {
  /// Creates the icon tile.
  const _IconTile({required this.icon, required this.isSelected});

  /// Option icon.
  final IconData icon;

  /// Whether the parent card is selected.
  final bool isSelected;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: AppSizes.cardIconTile,
      height: AppSizes.cardIconTile,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadius.inputAll,
      ),
      child: Icon(
        icon,
        size: AppSizes.iconMd,
        color: isSelected ? palette.accentText : palette.textSecondary,
      ),
    );
  }
}

/// Teal check circle that fades in when the card is selected.
class _SelectedCheck extends StatelessWidget {
  /// Creates the check indicator.
  const _SelectedCheck({required this.isSelected});

  /// Whether to show the check.
  final bool isSelected;

  /// Builds the indicator, reserving its space so layout does not shift.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: AnimatedOpacity(
        opacity: isSelected ? 1 : 0,
        duration: disableMotion ? Duration.zero : AppDurations.fast,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: palette.accent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.check,
            size: AppSizes.iconSm,
            color: palette.onAccent,
          ),
        ),
      ),
    );
  }
}

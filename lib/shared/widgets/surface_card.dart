import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// White (or dark surface) card with a hairline border. Tappable when
/// [onTap] is set; [accentColor] adds a coloured left edge.
class SurfaceCard extends StatelessWidget {
  /// Creates a card.
  const SurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.accentColor,
    this.semanticLabel,
  });

  /// Card content.
  final Widget child;

  /// Called on tap; null makes the card static.
  final VoidCallback? onTap;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Optional colour of a 4 px left edge (e.g. hot leads).
  final Color? accentColor;

  /// Screen-reader label for a tappable card.
  final String? semanticLabel;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = accentColor;
    Widget content = Padding(padding: padding, child: child);
    if (accent != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: accent, width: AppSpacing.xxs),
          ),
        ),
        child: content,
      );
    }
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

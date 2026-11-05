import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Centred icon, title and message for a list with nothing to show.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  /// Illustrative icon.
  final IconData icon;

  /// Short headline, e.g. "No hot leads waiting".
  final String title;

  /// Optional explanation.
  final String? message;

  /// Optional button, e.g. "Clear filters".
  final Widget? action;

  /// Builds the empty state.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final body = message;
    final button = action;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.logoMd, color: palette.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(title, textAlign: TextAlign.center, style: text.titleSmall),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(body, textAlign: TextAlign.center, style: text.bodySmall),
          ],
          if (button != null) ...[
            const SizedBox(height: AppSpacing.md),
            button,
          ],
        ],
      ),
    );
  }
}

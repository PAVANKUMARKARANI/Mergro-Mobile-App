import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Heading with an optional subtitle and trailing widget, used to title
/// screens and groups of fields.
class SectionHeader extends StatelessWidget {
  /// Creates a section header.
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isLarge = false,
  });

  /// Heading text.
  final String title;

  /// Optional supporting text under the heading.
  final String? subtitle;

  /// Optional widget at the end of the title row (e.g. a chip or button).
  final Widget? trailing;

  /// Uses the 22 px title size instead of the 18 px heading size.
  final bool isLarge;

  /// Builds the header.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final headerSubtitle = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: isLarge ? text.titleLarge : text.titleMedium,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        if (headerSubtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(headerSubtitle, style: text.bodySmall),
        ],
      ],
    );
  }
}

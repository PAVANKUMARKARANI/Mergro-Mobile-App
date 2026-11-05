import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'status_chip.dart';

/// Kind of message an [InfoBanner] shows.
enum InfoBannerType {
  /// Neutral guidance (violet).
  info,

  /// Confirmation (green).
  success,

  /// Failure (red); announced to screen readers.
  error,
}

/// Inline message box with an icon, optional title and body text.
class InfoBanner extends StatelessWidget {
  /// Creates a banner of the given [type].
  const InfoBanner({
    super.key,
    required this.message,
    this.type = InfoBannerType.info,
    this.title,
    this.icon,
  });

  /// Body text.
  final String message;

  /// Visual and semantic kind.
  final InfoBannerType type;

  /// Optional bold first line.
  final String? title;

  /// Overrides the default icon for [type].
  final IconData? icon;

  /// Builds the banner.
  @override
  Widget build(BuildContext context) {
    final colors = _tone.colorsFrom(context.palette);
    final text = context.textStyles;
    final bannerTitle = title;
    return Semantics(
      liveRegion: type == InfoBannerType.error,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppRadius.inputAll,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon ?? _defaultIcon,
              size: AppSizes.iconMd,
              color: colors.foreground,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bannerTitle != null)
                    Text(
                      bannerTitle,
                      style: text.labelMedium?.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                  Text(
                    message,
                    style: text.bodySmall?.copyWith(color: colors.foreground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Colour tone matching [type].
  StatusTone get _tone => switch (type) {
    InfoBannerType.info => StatusTone.info,
    InfoBannerType.success => StatusTone.success,
    InfoBannerType.error => StatusTone.error,
  };

  /// Default icon for [type].
  IconData get _defaultIcon => switch (type) {
    InfoBannerType.info => LucideIcons.info,
    InfoBannerType.success => LucideIcons.circleCheck,
    InfoBannerType.error => LucideIcons.circleAlert,
  };
}

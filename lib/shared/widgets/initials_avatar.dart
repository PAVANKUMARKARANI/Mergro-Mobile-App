import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'status_chip.dart';

/// Round avatar showing up to two initials of [name].
class InitialsAvatar extends StatelessWidget {
  /// Creates an avatar.
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = AppSizes.cardIconTile,
    this.tone = StatusTone.info,
  });

  /// Person's name.
  final String name;

  /// Diameter.
  final double size;

  /// Colour tone of the circle.
  final StatusTone tone;

  /// Up to two initials; "?" for an empty name.
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }

  /// Builds the avatar; screen readers read the name, not the initials.
  @override
  Widget build(BuildContext context) {
    final colors = tone.colorsFrom(context.palette);
    return Semantics(
      label: name,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: Text(
          initialsOf(name),
          style: context.textStyles.labelMedium?.copyWith(
            color: colors.foreground,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Paints "call ring" ripples around a logo: each ring scales from 1× to
/// 2.2× the logo radius while fading from 35 % teal to transparent.
///
/// Shared by the splash and the onboarding success screen.
class CallRingsPainter extends CustomPainter {
  /// Creates a painter; each value in [ringProgress] is one ring's 0–1 phase.
  const CallRingsPainter({required this.ringProgress, required this.color});

  /// Progress (0–1) of each ring; 0 means not started.
  final List<double> ringProgress;

  /// Ring colour before opacity is applied.
  final Color color;

  static const double _maxScale = 2.2;

  /// Draws each ring that has started.
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.shortestSide / 2;
    for (final progress in ringProgress) {
      if (progress <= 0 || progress >= 1) continue;
      final radius = baseRadius * (1 + (_maxScale - 1) * progress);
      final opacity = AppColors.splashRingOpacity * (1 - progress);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.splashRingStroke
          ..color = color.withValues(alpha: opacity),
      );
    }
  }

  /// Repaints when any ring moved.
  @override
  bool shouldRepaint(CallRingsPainter oldDelegate) {
    if (oldDelegate.color != color) return true;
    if (oldDelegate.ringProgress.length != ringProgress.length) return true;
    for (var index = 0; index < ringProgress.length; index++) {
      if (oldDelegate.ringProgress[index] != ringProgress[index]) return true;
    }
    return false;
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Mergro brand mark: a rounded navy tile holding five teal voice bars.
///
/// Drawn in code until an SVG asset exists; swap the painter for an SVG later
/// without changing call sites. [barFactors] lets the splash animate the bars.
class MergroLogoMark extends StatelessWidget {
  /// Creates the logo tile at the given [size].
  const MergroLogoMark({
    super.key,
    this.size = AppSizes.logoMd,
    this.barFactors = restingBarFactors,
  });

  /// Resting height of each bar as a fraction of the tallest bar.
  static const List<double> restingBarFactors = [0.38, 0.72, 1.0, 0.6, 0.32];

  /// Edge length of the square tile.
  final double size;

  /// Current height factor (0–1) of each bar.
  final List<double> barFactors;

  /// Paints the tile and bars.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mergro logo',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: MergroLogoPainter(barFactors: barFactors),
      ),
    );
  }
}

/// Paints the Mergro tile and voice bars; shared by the logo and splash.
class MergroLogoPainter extends CustomPainter {
  /// Creates a painter for the given bar height factors.
  const MergroLogoPainter({
    required this.barFactors,
    this.drawTile = true,
    this.barColor = AppColors.darkAccent,
  });

  /// Height factor (0–1) of each bar.
  final List<double> barFactors;

  /// Whether to draw the rounded navy tile. App-icon layers draw the bars
  /// only, because the OS supplies the background and the mask.
  final bool drawTile;

  /// Bar colour (white for Android's monochrome themed icon).
  final Color barColor;

  static const double _cornerRatio = 0.26;
  static const double _barWidthRatio = 0.09;
  static const double _barGapRatio = 0.07;
  static const double _maxBarHeightRatio = 0.52;
  static const double _minBarFactor = 0.12;

  /// Draws the rounded tile (optional), then centred vertical bars.
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (drawTile) {
      final tile = RRect.fromRectAndRadius(
        Offset.zero & Size.square(side),
        Radius.circular(side * _cornerRatio),
      );
      canvas.drawRRect(tile, Paint()..color = AppColors.lightBrandNavy);
    }

    final barWidth = side * _barWidthRatio;
    final gap = side * _barGapRatio;
    final count = barFactors.length;
    final totalWidth = count * barWidth + (count - 1) * gap;
    final barPaint = Paint()..color = barColor;
    var left = (side - totalWidth) / 2;
    for (final factor in barFactors) {
      final clamped = factor.clamp(_minBarFactor, 1.0);
      final height = side * _maxBarHeightRatio * clamped;
      final rect = Rect.fromLTWH(left, (side - height) / 2, barWidth, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        barPaint,
      );
      left += barWidth + gap;
    }
  }

  /// Repaints only when the bar heights change.
  @override
  bool shouldRepaint(MergroLogoPainter oldDelegate) {
    if (oldDelegate.drawTile != drawTile) return true;
    if (oldDelegate.barColor != barColor) return true;
    if (oldDelegate.barFactors.length != barFactors.length) return true;
    for (var i = 0; i < barFactors.length; i++) {
      if (oldDelegate.barFactors[i] != barFactors[i]) return true;
    }
    return false;
  }
}

/// Logo tile plus the "Mergro" wordmark in Sora 700.
class MergroLogo extends StatelessWidget {
  /// Creates the full logo lock-up.
  const MergroLogo({
    super.key,
    this.markSize = AppSizes.logoMd,
    this.showWordmark = true,
    this.wordmarkColor,
  });

  /// Product name rendered as the wordmark.
  static const String wordmarkText = 'Mergro';

  static const double _wordmarkRatio = 0.6;

  /// Edge length of the tile.
  final double markSize;

  /// Whether to show the wordmark next to the tile.
  final bool showWordmark;

  /// Wordmark colour; defaults to the theme's primary text colour.
  final Color? wordmarkColor;

  /// Builds the tile and optional wordmark in a row.
  @override
  Widget build(BuildContext context) {
    final mark = MergroLogoMark(size: markSize);
    if (!showWordmark) return mark;
    return Semantics(
      label: wordmarkText,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: AppSpacing.sm),
          Text(
            wordmarkText,
            style: AppTypography.wordmark(
              markSize * _wordmarkRatio,
              wordmarkColor ?? context.palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

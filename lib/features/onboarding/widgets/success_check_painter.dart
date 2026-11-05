import 'dart:ui' as ui;

import '../../../shared/ui.dart';

/// Teal circle that scales in ([circleProgress]) and a check mark that
/// draws itself ([checkProgress]), both 0 → 1.
class SuccessCheckPainter extends CustomPainter {
  /// Creates the painter.
  const SuccessCheckPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.circleColor,
    required this.checkColor,
  });

  /// Circle scale-in progress, 0–1.
  final double circleProgress;

  /// Check stroke progress, 0–1.
  final double checkProgress;

  /// Circle fill.
  final Color circleColor;

  /// Check stroke colour.
  final Color checkColor;

  // Check mark points as fractions of the circle's size.
  static const Offset _start = Offset(0.28, 0.52);
  static const Offset _corner = Offset(0.44, 0.67);
  static const Offset _end = Offset(0.73, 0.36);

  /// Draws the circle, then the partial check path.
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      center,
      size.shortestSide / 2 * circleProgress,
      Paint()..color = circleColor,
    );
    if (checkProgress <= 0) return;

    Offset scaled(Offset point) =>
        Offset(point.dx * size.width, point.dy * size.height);
    final path = Path()
      ..moveTo(scaled(_start).dx, scaled(_start).dy)
      ..lineTo(scaled(_corner).dx, scaled(_corner).dy)
      ..lineTo(scaled(_end).dx, scaled(_end).dy);
    final partial = Path();
    for (final ui.PathMetric metric in path.computeMetrics()) {
      partial.addPath(
        metric.extractPath(0, metric.length * checkProgress),
        Offset.zero,
      );
    }
    canvas.drawPath(
      partial,
      Paint()
        ..color = checkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.successCheckStroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Repaints when progress or colours change.
  @override
  bool shouldRepaint(SuccessCheckPainter oldDelegate) =>
      oldDelegate.circleProgress != circleProgress ||
      oldDelegate.checkProgress != checkProgress ||
      oldDelegate.circleColor != circleColor ||
      oldDelegate.checkColor != checkColor;
}

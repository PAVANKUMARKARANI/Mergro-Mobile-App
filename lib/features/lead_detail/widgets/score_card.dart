import 'dart:math' as math;

import '../../../shared/ui.dart';
import '../../leads/models/lead.dart';
import '../models/lead_profile.dart';

/// Screen 17: the 1–100 score as a half gauge, its Hot / Warm / Cold band,
/// and the reason codes that add up to it.
class ScoreCard extends StatelessWidget {
  /// Creates the card.
  const ScoreCard({super.key, required this.profile});

  /// The profile whose score is shown.
  final LeadProfile profile;

  /// Gauge size.
  static const Size gaugeSize = Size(160, 88);

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final lead = profile.lead;
    final score = lead.score;
    final band = lead.temperature;
    final text = context.textStyles;
    if (score == null || band == null) {
      return SurfaceCard(
        child: Text('Scored after the first AI call.', style: text.bodySmall),
      );
    }
    final color = _bandColor(context, band);
    return SurfaceCard(
      child: Column(
        children: [
          Semantics(
            label: 'Score $score out of 100, ${band.label}',
            excludeSemantics: true,
            child: SizedBox.fromSize(
              size: gaugeSize,
              child: CustomPaint(
                painter: _GaugePainter(
                  value: score / 100,
                  color: color,
                  track: context.palette.border,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$score', style: text.headlineSmall),
                      Text(
                        band.label,
                        style: text.labelMedium?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReasonRow(
            code: 'BASE',
            label: 'Starting score',
            points: LeadProfile.baseScore,
            isBase: true,
          ),
          for (final reason in profile.scoreReasons)
            _ReasonRow(
              code: reason.code,
              label: reason.label,
              points: reason.points,
            ),
        ],
      ),
    );
  }

  /// Red for hot, amber for warm, grey for cold.
  static Color _bandColor(BuildContext context, LeadTemperature band) {
    final palette = context.palette;
    return switch (band) {
      LeadTemperature.hot => palette.error,
      LeadTemperature.warm => palette.highlight,
      LeadTemperature.cold => palette.textSecondary,
    };
  }
}

/// One reason: code, explanation and signed points.
class _ReasonRow extends StatelessWidget {
  /// Creates the row.
  const _ReasonRow({
    required this.code,
    required this.label,
    required this.points,
    this.isBase = false,
  });

  /// Reason code.
  final String code;

  /// Explanation.
  final String label;

  /// Points (the base shows unsigned).
  final int points;

  /// True for the starting-score line.
  final bool isBase;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final tone = isBase
        ? StatusTone.neutral
        : points >= 0
        ? StatusTone.success
        : StatusTone.error;
    final sign = isBase ? '' : (points >= 0 ? '+' : '−');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium),
                Text(code, style: AppTypography.mono(palette.textSecondary)),
              ],
            ),
          ),
          StatusChip(label: '$sign${points.abs()}', tone: tone),
        ],
      ),
    );
  }
}

/// Half-circle track with the score's share filled in.
class _GaugePainter extends CustomPainter {
  /// Creates the painter.
  _GaugePainter({
    required this.value,
    required this.color,
    required this.track,
  });

  /// Filled share 0–1.
  final double value;

  /// Fill colour.
  final Color color;

  /// Track colour.
  final Color track;

  /// Stroke width of the arcs.
  static const double stroke = 12;

  /// Paints the track and the value arc.
  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2, size.height) - stroke / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height - stroke / 2),
      radius: radius,
    );
    Paint arc(Color paintColor) => Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawArc(rect, math.pi, math.pi, false, arc(track))
      ..drawArc(rect, math.pi, math.pi * value.clamp(0, 1), false, arc(color));
  }

  /// Repaints when the value or colours change.
  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color || old.track != track;
}

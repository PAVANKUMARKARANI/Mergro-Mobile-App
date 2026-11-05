import 'dart:math' as math;

import '../../../shared/ui.dart';

/// The splash choreography as curved sub-animations of one 2.4 s controller.
///
/// Each phase's millisecond window from the spec is converted to an
/// [Interval] of the controller's 0–1 value.
class SplashTimeline {
  /// Derives every phase from [controller].
  SplashTimeline(this.controller)
    : logoScale = Tween<double>(
        begin: 0.6,
        end: 1,
      ).animate(_phase(controller, 0, 500, Curves.easeOutBack)),
      logoOpacity = _phase(controller, 0, 500, Curves.easeOut),
      firstRing = _phase(controller, 300, 1300, Curves.easeOut),
      secondRing = _phase(controller, 550, 1550, Curves.easeOut),
      bars = _phase(controller, 600, 1800, Curves.linear),
      wordmark = _phase(controller, 1000, 1300, Curves.easeOut),
      tagline = _phase(controller, 1250, 1500, Curves.easeOut),
      progress = _phase(controller, 1500, 2400, Curves.easeInOut);

  /// The single driving controller.
  final AnimationController controller;

  /// Logo tile scale, 0.6 → 1.0 with overshoot.
  final Animation<double> logoScale;

  /// Logo tile fade-in.
  final Animation<double> logoOpacity;

  /// First call-ring ripple progress.
  final Animation<double> firstRing;

  /// Second call-ring ripple progress (starts 250 ms later).
  final Animation<double> secondRing;

  /// Voice-bar "speech" progress.
  final Animation<double> bars;

  /// Wordmark slide-up and fade.
  final Animation<double> wordmark;

  /// Tagline fade.
  final Animation<double> tagline;

  /// Bottom progress line fill.
  final Animation<double> progress;

  static const int _totalMs = 2400;
  static const int _speechCycles = 3;
  static const double _barPhaseOffset = 1.3;

  /// Builds a curved animation over the window [startMs]–[endMs].
  static Animation<double> _phase(
    AnimationController controller,
    int startMs,
    int endMs,
    Curve curve,
  ) {
    return CurvedAnimation(
      parent: controller,
      curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
    );
  }

  /// Current bar heights: staggered "speech" that eases back into the
  /// static logo shape as the phase ends.
  List<double> get barFactors {
    final progressValue = bars.value;
    final resting = MergroLogoMark.restingBarFactors;
    // The sine envelope is 0 at both ends, so motion starts from and settles
    // into the resting logo with no visible jump.
    final envelope = math.sin(math.pi * progressValue);
    return [
      for (var index = 0; index < resting.length; index++)
        resting[index] * (1 - envelope) +
            envelope *
                (0.5 +
                    0.5 *
                        math.sin(
                          2 * math.pi * _speechCycles * progressValue +
                              index * _barPhaseOffset,
                        )),
    ];
  }
}

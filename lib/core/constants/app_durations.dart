/// Animation and simulated-latency durations used across the app.
abstract final class AppDurations {
  /// Quick state changes (checks, chip toggles).
  static const Duration fast = Duration(milliseconds: 150);

  /// Step transitions and standard UI motion.
  static const Duration medium = Duration(milliseconds: 250);

  /// Fade between routes after the splash.
  static const Duration routeFade = Duration(milliseconds: 300);

  /// Full splash animation length.
  static const Duration splash = Duration(milliseconds: 2400);

  /// Hold time on the static splash frame when reduced motion is on.
  static const Duration reducedMotionSplashHold = Duration(milliseconds: 1500);

  /// One cycle of the voice preview waveform (repeats while speaking).
  static const Duration voiceWaveCycle = Duration(milliseconds: 900);

  /// Simulated backend latency until the real API is wired in.
  static const Duration simulatedNetwork = Duration(seconds: 1);

  /// Success screen check-draw and ring animation.
  static const Duration successCelebration = Duration(milliseconds: 1600);
}

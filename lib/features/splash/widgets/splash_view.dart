import '../../../shared/ui.dart';
import 'splash_timeline.dart';

/// Visual splash: glow, call rings, animated logo, wordmark, tagline and the
/// bottom progress line, all driven by one [SplashTimeline].
class SplashView extends StatelessWidget {
  /// Creates the view for the given [timeline].
  const SplashView({super.key, required this.timeline});

  /// Product tagline under the wordmark.
  static const String tagline = 'Every lead, called in 60 seconds.';

  /// The animation phases to render.
  final SplashTimeline timeline;

  /// Rebuilds on every animation tick.
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.splashNavy,
      child: AnimatedBuilder(
        animation: timeline.controller,
        builder: (context, _) => Stack(
          children: [
            Center(child: _buildBrand(context)),
            Align(
              alignment: Alignment.bottomLeft,
              child: _ProgressLine(value: timeline.progress.value),
            ),
          ],
        ),
      ),
    );
  }

  /// Logo with glow and rings, then wordmark and tagline.
  Widget _buildBrand(BuildContext context) {
    final text = context.textStyles;
    final slide = AppSizes.splashWordmarkSlide * (1 - timeline.wordmark.value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: AppSpacing.xxxl),
          Opacity(
            opacity: timeline.wordmark.value,
            child: Transform.translate(
              offset: Offset(0, slide),
              child: Text(
                MergroLogo.wordmarkText,
                style: AppTypography.wordmark(
                  AppTypography.display,
                  AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Opacity(
            opacity: timeline.tagline.value,
            child: Text(
              tagline,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: AppColors.splashTagline),
            ),
          ),
        ],
      ),
    );
  }

  /// Glow, ripple rings and the scaling logo tile.
  Widget _buildLogo() {
    // Only the tile takes layout space; glow and rings paint around it so
    // the wordmark sits close to the logo.
    return SizedBox.square(
      dimension: AppSizes.logoLg,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          OverflowBox(
            maxWidth: AppSizes.splashGlow,
            maxHeight: AppSizes.splashGlow,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Fading to transparent *teal* (not transparent black)
                // avoids a dark band at the glow's edge.
                gradient: RadialGradient(
                  colors: [_glowColor, _glowColor.withValues(alpha: 0)],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          CustomPaint(
            size: const Size.square(AppSizes.logoLg),
            painter: CallRingsPainter(
              color: AppColors.darkAccent,
              ringProgress: [
                timeline.firstRing.value,
                timeline.secondRing.value,
              ],
            ),
          ),
          Opacity(
            opacity: timeline.logoOpacity.value,
            child: Transform.scale(
              scale: timeline.logoScale.value,
              child: MergroLogoMark(
                size: AppSizes.logoLg,
                barFactors: timeline.barFactors,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final Color _glowColor = AppColors.darkAccent.withValues(
    alpha: AppColors.splashGlowOpacity,
  );
}

/// 2 px teal line that fills left to right along the bottom edge.
class _ProgressLine extends StatelessWidget {
  /// Creates the line at fill fraction [value].
  const _ProgressLine({required this.value});

  /// Fill fraction, 0–1.
  final double value;

  /// Builds the line inside the bottom safe area.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        widthFactor: value,
        child: const ColoredBox(
          color: AppColors.darkAccent,
          child: SizedBox(height: AppSizes.splashProgressHeight),
        ),
      ),
    );
  }
}

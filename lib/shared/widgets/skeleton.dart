import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'surface_card.dart';

/// Gently pulses its [child] skeleton while content loads (still when the
/// user has reduced motion on). Screen readers hear "Loading".
class SkeletonPulse extends StatefulWidget {
  /// Creates the pulse.
  const SkeletonPulse({super.key, required this.child});

  /// Skeleton shapes.
  final Widget child;

  /// Creates the state owning the animation.
  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

/// Owns the repeating fade.
class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  static const double _dimmest = 0.45;
  static const double _reducedMotionOpacity = 0.7;
  static const Duration _period = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );

  /// Starts or stops the pulse to match the reduced-motion setting.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  /// Releases the controller.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the fading skeleton.
  @override
  Widget build(BuildContext context) {
    final isStill = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: isStill
            ? Opacity(opacity: _reducedMotionOpacity, child: widget.child)
            : FadeTransition(
                opacity: Tween<double>(
                  begin: _dimmest,
                  end: 1,
                ).animate(_controller),
                child: widget.child,
              ),
      ),
    );
  }
}

/// A grey placeholder shape (put it inside a [SkeletonPulse]).
class SkeletonBox extends StatelessWidget {
  /// Creates a box; [width] null fills the available width.
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = AppRadius.inputAll,
    this.isCircle = false,
  });

  /// Height.
  final double height;

  /// Width, or null to stretch.
  final double? width;

  /// Corner radius (ignored for circles).
  final BorderRadius borderRadius;

  /// Draws a circle of diameter [height].
  final bool isCircle;

  /// Builds the box.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCircle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: context.palette.border,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadius,
      ),
    );
  }
}

/// Placeholder of a list row: circle, title line and a shorter line.
class SkeletonRow extends StatelessWidget {
  /// Creates the row.
  const SkeletonRow({super.key});

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SkeletonBox(height: AppSizes.cardIconTile, isCircle: true),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: SkeletonBox(height: AppSpacing.sm),
                ),
                SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: 0.85,
                  child: SkeletonBox(height: AppSpacing.sm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder of a card list (default loading state of list screens).
class SkeletonList extends StatelessWidget {
  /// Creates the list with [count] cards.
  const SkeletonList({super.key, this.count = 5});

  /// Number of placeholder cards.
  final int count;

  /// Builds the list.
  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (_, _) => const SurfaceCard(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: SkeletonRow(),
        ),
      ),
    );
  }
}

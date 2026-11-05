import '../../../shared/ui.dart';

/// Placeholder of the speed-to-lead card and the four tiles, shaped like
/// the loaded layout so nothing jumps when the numbers arrive.
class DashboardSummarySkeleton extends StatelessWidget {
  /// Creates the placeholder.
  const DashboardSummarySkeleton({super.key});

  /// Height of the speed-to-lead card placeholder.
  static const double speedCardHeight = 132;

  /// Height of a tile placeholder.
  static const double tileHeight = 72;

  /// Builds the placeholder.
  @override
  Widget build(BuildContext context) {
    Widget tile() => const Expanded(
      child: SkeletonBox(height: tileHeight, borderRadius: AppRadius.cardAll),
    );
    const gap = SizedBox(width: AppSpacing.xs);
    return SkeletonPulse(
      child: Column(
        children: [
          const SkeletonBox(
            height: speedCardHeight,
            borderRadius: AppRadius.cardAll,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [tile(), gap, tile()]),
          const SizedBox(height: AppSpacing.xs),
          Row(children: [tile(), gap, tile()]),
        ],
      ),
    );
  }
}

/// Placeholder of a grouped dashboard section: [rows] skeleton rows in one
/// card with dividers.
class SectionRowsSkeleton extends StatelessWidget {
  /// Creates the placeholder.
  const SectionRowsSkeleton({super.key, this.rows = 2});

  /// Number of rows.
  final int rows;

  /// Builds the placeholder.
  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: SurfaceCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < rows; index++) ...[
              if (index > 0) const Divider(height: AppSizes.borderThin),
              const SkeletonRow(),
            ],
          ],
        ),
      ),
    );
  }
}

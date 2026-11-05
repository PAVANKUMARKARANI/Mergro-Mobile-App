import '../../../shared/ui.dart';
import '../models/login_models.dart';

/// Small leading mark for a provider button. Placeholder drawings until the
/// official SVG logos are added.
class ProviderMark extends StatelessWidget {
  /// Creates the mark for [provider].
  const ProviderMark({super.key, required this.provider});

  /// Which provider to draw.
  final SsoProvider provider;

  static const String _googleLetter = 'G';
  static const List<Color> _microsoftSquares = [
    AppColors.microsoftRed,
    AppColors.microsoftGreen,
    AppColors.microsoftBlue,
    AppColors.microsoftYellow,
  ];

  /// Builds the provider-specific mark.
  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.iconMd,
        child: switch (provider) {
          SsoProvider.google => Center(
            child: Text(
              _googleLetter,
              style: AppTypography.sora(
                AppTypography.heading,
                FontWeight.w700,
                AppColors.googleBlue,
              ),
            ),
          ),
          SsoProvider.microsoft => _buildMicrosoftGrid(),
          SsoProvider.companySso => Icon(
            LucideIcons.building2,
            size: AppSizes.iconMd,
            color: context.palette.textPrimary,
          ),
        },
      ),
    );
  }

  /// Four coloured squares in a 2 × 2 grid.
  Widget _buildMicrosoftGrid() {
    // Plain rows, not GridView: a scroll view would add safe-area padding
    // and squeeze the squares out of the 20 px slot.
    Widget square(Color color) => Expanded(
      child: ColoredBox(color: color, child: const SizedBox.expand()),
    );
    Widget row(Color left, Color right) => Expanded(
      child: Row(
        children: [
          square(left),
          const SizedBox(width: AppSizes.borderThick),
          square(right),
        ],
      ),
    );
    return Column(
      children: [
        row(_microsoftSquares[0], _microsoftSquares[1]),
        const SizedBox(height: AppSizes.borderThick),
        row(_microsoftSquares[2], _microsoftSquares[3]),
      ],
    );
  }
}

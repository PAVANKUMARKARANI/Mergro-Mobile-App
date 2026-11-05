import '../../../shared/ui.dart';

/// Navy header (~30 % of the screen height) with the logo and greeting.
class LoginHeader extends StatelessWidget {
  /// Creates the header.
  const LoginHeader({super.key});

  /// Header title.
  static const String title = 'Welcome back';

  /// Header subtitle.
  static const String subtitle = 'Sign in to your brokerage workspace';

  static const double _heightFraction = 0.3;

  /// Builds the header; it grows with text scale instead of overflowing.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final minHeight = MediaQuery.sizeOf(context).height * _heightFraction;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: context.palette.brandNavy,
        borderRadius: AppRadius.headerBottom,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // Extra bottom padding leaves room for the overlapping form card.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxl + AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MergroLogo(
                markSize: AppSizes.logoSm,
                wordmarkColor: AppColors.white,
              ),
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.headlineSmall?.copyWith(color: AppColors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: text.bodyLarge?.copyWith(
                  color: AppColors.headerSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

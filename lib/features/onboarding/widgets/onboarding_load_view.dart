import '../../../shared/ui.dart';

/// Shown while saved onboarding progress loads, or when loading failed
/// (with Retry).
class OnboardingLoadView extends StatelessWidget {
  /// Creates the view; a null [error] means still loading.
  const OnboardingLoadView({super.key, this.error, required this.onRetry});

  /// Why loading failed, or null while loading.
  final String? error;

  /// Loads the progress again.
  final VoidCallback onRetry;

  /// Builds the spinner or the error with Retry.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final message = error;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Loading your setup…',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
            ] else ...[
              InfoBanner(
                type: InfoBannerType.error,
                title: "Couldn't load your setup",
                message: message,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Retry',
                variant: AppButtonVariant.secondary,
                leading: const Icon(
                  LucideIcons.rotateCw,
                  size: AppSizes.iconMd,
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

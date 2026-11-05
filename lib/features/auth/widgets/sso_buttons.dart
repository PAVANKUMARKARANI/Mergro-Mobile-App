import '../../../shared/ui.dart';
import '../models/login_models.dart';
import 'provider_mark.dart';

/// "or continue with" divider followed by one button per [SsoProvider].
class SsoButtons extends StatelessWidget {
  /// Creates the provider buttons.
  const SsoButtons({
    super.key,
    required this.activeProvider,
    required this.isBusy,
    required this.onSelected,
  });

  /// Divider caption.
  static const String dividerLabel = 'or continue with';

  /// Provider whose sign-in is running (shows the spinner), if any.
  final SsoProvider? activeProvider;

  /// Disables every button while any sign-in runs.
  final bool isBusy;

  /// Called with the tapped provider.
  final ValueChanged<SsoProvider> onSelected;

  /// Builds the divider and buttons.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  dividerLabel,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodySmall,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        for (final provider in SsoProvider.values) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: provider.buttonLabel,
            variant: AppButtonVariant.sso,
            leading: ProviderMark(provider: provider),
            isLoading: activeProvider == provider,
            onPressed: isBusy && activeProvider != provider
                ? null
                : () => onSelected(provider),
          ),
        ],
      ],
    );
  }
}

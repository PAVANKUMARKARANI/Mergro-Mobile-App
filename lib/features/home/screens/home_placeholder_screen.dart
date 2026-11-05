import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../auth/controllers/current_user_controller.dart';

/// Stand-in for the Home Dashboard (out of scope for this phase).
class HomePlaceholderScreen extends ConsumerWidget {
  /// Creates the placeholder with its sign-out callback.
  const HomePlaceholderScreen({super.key, required this.onSignOut});

  /// Ends the session and returns to Login; wired by AppRoutes.
  final VoidCallback onSignOut;

  /// Builds the greeting and the sign-out button.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final brokerageName = user?.brokerageName ?? '';
    final text = context.textStyles;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          brokerageName.isNotEmpty ? brokerageName : MergroLogo.wordmarkText,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MergroLogoMark(size: AppSizes.logoLg),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Hi ${user?.firstName ?? ''} · ${user?.role.label ?? ''}',
                  textAlign: TextAlign.center,
                  style: text.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'The Home Dashboard is coming next.',
                  textAlign: TextAlign.center,
                  style: text.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Sign out',
                  variant: AppButtonVariant.secondary,
                  leading: const Icon(
                    LucideIcons.logOut,
                    size: AppSizes.iconMd,
                  ),
                  onPressed: onSignOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_mode_controller.dart';
import '../../../shared/ui.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../controllers/profile_alerts_controller.dart';

/// Screen 10: account, role, alert preferences, appearance and sign-out.
class ProfileScreen extends ConsumerWidget {
  /// Creates the screen with its sign-out callback.
  const ProfileScreen({super.key, required this.onSignOut});

  /// Ends the session; wired by AppRoutes.
  final VoidCallback onSignOut;

  /// Labels of the appearance choices.
  static const Map<ThemeMode, String> themeLabels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  /// Asks for confirmation, then signs out.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          "You'll stop getting hot-lead alerts on this phone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onSignOut();
  }

  /// Builds the account card, alert settings and sign-out button.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final alerts = ref.watch(profileAlertsControllerProvider);
    final controller = ref.read(profileAlertsControllerProvider.notifier);
    final text = context.textStyles;
    final name = user == null || user.name.isEmpty
        ? user?.email ?? ''
        : user.name;
    final brokerage = user?.brokerageName ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          SurfaceCard(
            child: Row(
              children: [
                InitialsAvatar(name: name, size: AppSizes.controlHeight),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: text.titleMedium),
                      Text(user?.email ?? '', style: text.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          if (user != null)
                            StatusChip(
                              label: user.role.label,
                              tone: StatusTone.info,
                            ),
                          if (brokerage.isNotEmpty)
                            StatusChip(
                              label: brokerage,
                              icon: LucideIcons.building2,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Hot-lead alerts',
            subtitle: 'How Mergro reaches you when the AI hands over a lead.',
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingSwitchTile(
            title: 'Push notifications',
            icon: LucideIcons.bellRing,
            value: alerts.pushEnabled,
            onChanged: controller.setPush,
          ),
          SettingSwitchTile(
            title: 'SMS fallback',
            subtitle: 'Text me if a push alert is not opened in 60 seconds.',
            icon: LucideIcons.messageSquareText,
            value: alerts.smsFallbackEnabled,
            onChanged: controller.setSmsFallback,
          ),
          SettingSwitchTile(
            title: 'Alert sound',
            icon: LucideIcons.bell,
            value: alerts.soundEnabled,
            onChanged: controller.setSound,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Quiet hours ${alerts.quietStart.label24}–${alerts.quietEnd.label24}: '
            'only hot leads alert you.',
            style: text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'System follows your phone’s light or dark setting.',
          ),
          const SizedBox(height: AppSpacing.sm),
          ToggleChipGroup<ThemeMode>(
            options: ThemeMode.values,
            selected: {ref.watch(themeModeControllerProvider)},
            labelOf: (mode) => themeLabels[mode] ?? mode.name,
            onToggled: ref.read(themeModeControllerProvider.notifier).select,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.secondary,
            leading: const Icon(LucideIcons.logOut, size: AppSizes.iconMd),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }
}

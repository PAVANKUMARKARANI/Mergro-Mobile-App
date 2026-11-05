import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../auth/models/app_user.dart';
import '../models/app_tab.dart';

/// "More" tab: the role's destinations that don't fit in the bar.
class MoreScreen extends ConsumerWidget {
  /// Creates the screen with its navigation callback.
  const MoreScreen({super.key, required this.onOpenTab});

  /// Opens a destination as its own screen.
  final ValueChanged<AppTab> onOpenTab;

  /// One-line description per destination.
  static const Map<AppTab, String> descriptions = {
    AppTab.leads: 'All leads by source, status and score',
    AppTab.liveCalls: 'AI calls in progress and the dial queue',
    AppTab.hotLeads: 'Handoffs waiting, with SLA timers',
    AppTab.viewings: 'Booked viewings and your calendar',
    AppTab.nurture: 'Follow-ups by SMS, WhatsApp and email',
    AppTab.profile: 'Account, role and alert preferences',
  };

  /// Builds the destination list.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.salesAgent;
    final tabs = AppTab.moreTabsFor(role);
    final text = context.textStyles;
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return SurfaceCard(
            onTap: () => onOpenTab(tab),
            semanticLabel: tab.label,
            child: Row(
              children: [
                Icon(tab.icon, color: context.palette.violet),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tab.label, style: text.titleSmall),
                      Text(descriptions[tab] ?? '', style: text.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: context.palette.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

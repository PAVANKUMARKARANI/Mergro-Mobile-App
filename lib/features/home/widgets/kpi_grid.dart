import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../hot_leads/controllers/hot_leads_controller.dart';
import '../../hot_leads/models/handoff.dart';
import '../../shell/models/app_tab.dart';
import '../../viewings/controllers/viewings_controller.dart';
import '../../viewings/models/viewing.dart';

/// Two-by-two KPI tiles; each opens its screen.
class KpiGrid extends ConsumerWidget {
  /// Creates the grid.
  const KpiGrid({
    super.key,
    required this.newLeads,
    required this.qualified,
    required this.onOpenTab,
  });

  /// Leads captured today.
  final int newLeads;

  /// Leads qualified today.
  final int qualified;

  /// Opens a destination.
  final ValueChanged<AppTab> onOpenTab;

  /// Builds the grid.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotWaiting = ref.watch(
      hotLeadsControllerProvider.select(
        (items) =>
            items.value
                ?.where((item) => item.status == HandoffStatus.waiting)
                .length ??
            0,
      ),
    );
    final viewingsToday = ref.watch(
      viewingsControllerProvider.select(
        (items) =>
            items.value
                ?.where(
                  (v) =>
                      isInViewingRange(v, ViewingRange.today, DateTime.now()),
                )
                .length ??
            0,
      ),
    );
    Widget tile(
      String label,
      int value,
      IconData icon,
      AppTab tab,
      StatusTone tone,
    ) => Expanded(
      child: MetricTile(
        label: label,
        value: '$value',
        icon: icon,
        tone: tone,
        onTap: () => onOpenTab(tab),
      ),
    );
    const gap = SizedBox(width: AppSpacing.xs);
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tile(
                'New leads today',
                newLeads,
                LucideIcons.users,
                AppTab.leads,
                StatusTone.info,
              ),
              gap,
              tile(
                'Qualified today',
                qualified,
                LucideIcons.circleCheck,
                AppTab.leads,
                StatusTone.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tile(
                'Hot leads waiting',
                hotWaiting,
                LucideIcons.flame,
                AppTab.hotLeads,
                StatusTone.error,
              ),
              gap,
              tile(
                'Viewings today',
                viewingsToday,
                LucideIcons.calendarCheck,
                AppTab.viewings,
                StatusTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

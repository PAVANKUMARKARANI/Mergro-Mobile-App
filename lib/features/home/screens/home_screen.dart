import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../calls/controllers/live_calls_controller.dart';
import '../../hot_leads/controllers/hot_leads_controller.dart';
import '../../hot_leads/models/handoff.dart';
import '../../hot_leads/widgets/hot_lead_row.dart';
import '../../shell/models/app_tab.dart';
import '../../viewings/controllers/viewings_controller.dart';
import '../../viewings/models/viewing.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_rows.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/kpi_grid.dart';
import '../widgets/preview_section.dart';
import '../widgets/speed_to_lead_card.dart';

/// Screen 4: speed-to-lead, today's numbers, live calls, hot leads and
/// today's viewings.
class HomeScreen extends ConsumerWidget {
  /// Creates the dashboard with its navigation callback.
  const HomeScreen({
    super.key,
    required this.onOpenTab,
    required this.onOpenLead,
    required this.onOpenCall,
  });

  /// Opens another main destination ("See all", KPI taps, profile).
  final ValueChanged<AppTab> onOpenTab;

  /// Opens a lead's profile (screen 13) by id.
  final ValueChanged<String> onOpenLead;

  /// Opens a live call's monitor (screen 12) by id.
  final ValueChanged<String> onOpenCall;

  /// "Good morning" / "Good afternoon" / "Good evening".
  static String greetingFor(DateTime now) => now.hour < 12
      ? 'Good morning'
      : now.hour < 17
      ? 'Good afternoon'
      : 'Good evening';

  /// Builds the dashboard.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final summary = ref.watch(dashboardSummaryProvider);
    final text = context.textStyles;
    final brokerage = user?.brokerageName ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${greetingFor(DateTime.now())}, ${user?.firstName ?? ''}'),
            if (brokerage.isNotEmpty) Text(brokerage, style: text.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => onOpenTab(AppTab.profile),
            icon: InitialsAvatar(
              name: user == null || user.name.isEmpty
                  ? user?.email ?? ''
                  : user.name,
              size: AppSizes.logoSm,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshDashboard(ref),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            ...switch (summary) {
              AsyncData(:final value) => [
                SpeedToLeadCard(summary: value),
                const SizedBox(height: AppSpacing.sm),
                KpiGrid(
                  newLeads: value.newLeadsToday,
                  qualified: value.qualifiedToday,
                  onOpenTab: onOpenTab,
                ),
              ],
              AsyncError() => [
                InfoBanner(
                  type: InfoBannerType.error,
                  message: "Couldn't load today's numbers. Pull to refresh.",
                ),
              ],
              _ => [const DashboardSummarySkeleton()],
            },
            const SizedBox(height: AppSpacing.lg),
            PreviewSection<Handoff>(
              title: 'Hot leads waiting',
              value: ref.watch(
                hotLeadsControllerProvider.select(
                  (items) => items.whenData(
                    (all) => all
                        .where((item) => item.status == HandoffStatus.waiting)
                        .toList(),
                  ),
                ),
              ),
              emptyText: 'No hot leads waiting. Nice work.',
              isGrouped: true,
              limit: 3,
              itemBuilder: (handoff) => HotLeadRow(
                handoff: handoff,
                onOpen: () => onOpenLead(handoff.leadId),
                onAccept: () => ref
                    .read(hotLeadsControllerProvider.notifier)
                    .accept(handoff.id),
              ),
              onSeeAll: () => onOpenTab(AppTab.hotLeads),
              onRetry: ref.read(hotLeadsControllerProvider.notifier).refresh,
            ),
            const SizedBox(height: AppSpacing.lg),
            PreviewSection(
              title: 'Live now',
              value: ref.watch(
                liveCallsControllerProvider.select(
                  (calls) => calls.whenData((data) => data.active),
                ),
              ),
              emptyText: 'No AI calls in progress.',
              itemBuilder: (call) =>
                  LiveCallRow(call: call, onOpen: () => onOpenCall(call.id)),
              limit: 3,
              isGrouped: true,
              onSeeAll: () => onOpenTab(AppTab.liveCalls),
              onRetry: ref.read(liveCallsControllerProvider.notifier).refresh,
            ),
            const SizedBox(height: AppSpacing.lg),
            PreviewSection<Viewing>(
              title: "Today's viewings",
              limit: 3,
              value: ref.watch(
                viewingsControllerProvider.select(
                  (items) => items.whenData(
                    (all) => all
                        .where(
                          (viewing) => isInViewingRange(
                            viewing,
                            ViewingRange.today,
                            DateTime.now(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              emptyText: 'No viewings booked for today.',
              itemBuilder: (viewing) => ViewingRow(
                viewing: viewing,
                onOpen: () => onOpenLead(viewing.leadId),
              ),
              isGrouped: true,
              onSeeAll: () => onOpenTab(AppTab.viewings),
              onRetry: ref.read(viewingsControllerProvider.notifier).refresh,
            ),
          ],
        ),
      ),
    );
  }
}

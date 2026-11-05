import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/time_format.dart';
import '../../calls/controllers/live_calls_controller.dart';
import '../../hot_leads/controllers/hot_leads_controller.dart';
import '../../leads/controllers/leads_controller.dart';
import '../../leads/models/lead.dart';
import '../../viewings/controllers/viewings_controller.dart';
import '../models/dashboard_summary.dart';

/// Today's dashboard numbers, derived from the leads list so they always
/// agree with the Leads screen.
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((
  ref,
) async {
  final leads = await ref.watch(leadsControllerProvider.future);
  final now = DateTime.now();
  final today = leads
      .where((lead) => TimeFormat.isSameDay(lead.createdAt, now))
      .toList();
  const qualifiedStatuses = {
    LeadStatus.qualified,
    LeadStatus.viewingBooked,
    LeadStatus.withAgent,
  };
  final reached = today.where((lead) => lead.score != null).length;
  return DashboardSummary(
    // TODO(backend): GET /api/analytics/speed-to-lead?period=today (P95);
    // the analytics API is planned for W11–W12.
    speedToLeadSeconds: 42,
    newLeadsToday: today.length,
    qualifiedToday: today
        .where((lead) => qualifiedStatuses.contains(lead.status))
        .length,
    contactRatePercent: today.isEmpty
        ? 0
        : (reached * 100 / today.length).round(),
  );
});

/// Reloads everything the dashboard shows (pull to refresh, Retry).
Future<void> refreshDashboard(WidgetRef ref) async {
  await Future.wait([
    ref.read(leadsControllerProvider.notifier).refresh(),
    ref.read(liveCallsControllerProvider.notifier).refresh(),
    ref.read(hotLeadsControllerProvider.notifier).refresh(),
    ref.read(viewingsControllerProvider.notifier).refresh(),
  ]);
}

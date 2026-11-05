import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/no_automatic_retry.dart';

import '../../calls/controllers/live_calls_controller.dart';
import '../../hot_leads/controllers/hot_leads_controller.dart';
import '../../leads/controllers/leads_controller.dart';
import '../../leads/repositories/leads_repository.dart';
import '../../viewings/controllers/viewings_controller.dart';
import '../models/dashboard_summary.dart';

/// Today's dashboard numbers from `GET /api/leads/summary`. Reloads with
/// the leads list so both stay in step.
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((
  ref,
) async {
  await ref.watch(leadsControllerProvider.future);
  // Speed-to-lead stays null until AI calls exist (see the card).
  return ref.read(leadsRepositoryProvider).fetchSummary();
}, retry: noAutomaticRetry);

/// Reloads everything the dashboard shows (pull to refresh, Retry).
Future<void> refreshDashboard(WidgetRef ref) async {
  await Future.wait([
    ref.read(leadsControllerProvider.notifier).refresh(),
    ref.read(liveCallsControllerProvider.notifier).refresh(),
    ref.read(hotLeadsControllerProvider.notifier).refresh(),
    ref.read(viewingsControllerProvider.notifier).refresh(),
  ]);
}

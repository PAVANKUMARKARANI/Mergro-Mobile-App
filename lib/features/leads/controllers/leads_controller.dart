import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/utils/set_toggle.dart';
import '../leads_demo_data.dart';
import '../models/lead.dart';
import '../models/lead_filters.dart';

/// Every lead of the brokerage, newest first. Lives while the app shell is
/// open; also read by the Home dashboard.
final leadsControllerProvider =
    AsyncNotifierProvider.autoDispose<LeadsController, List<Lead>>(
      LeadsController.new,
    );

/// Loads leads (demo data until the leads API exists).
class LeadsController extends AsyncNotifier<List<Lead>> {
  /// Loads the leads.
  @override
  Future<List<Lead>> build() async {
    // TODO(backend): GET /api/leads?sort=-createdAt (paged); the list should
    // also update live from socket.io lead events.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    final leads = LeadsDemoData.leads(DateTime.now())
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return leads;
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Search text and filters of the Leads screen.
final leadFiltersProvider =
    NotifierProvider.autoDispose<LeadFiltersController, LeadFilters>(
      LeadFiltersController.new,
    );

/// Edits [LeadFilters].
class LeadFiltersController extends Notifier<LeadFilters> {
  /// Starts unfiltered.
  @override
  LeadFilters build() => const LeadFilters();

  /// Sets the search text.
  void setQuery(String query) => state = state.copyWith(query: query);

  /// Shows only [temperature], or all bands when it is null.
  void showOnly(LeadTemperature? temperature) => state = state.copyWith(
    temperatures: temperature == null ? const {} : {temperature},
  );

  /// Adds or removes a source.
  void toggleSource(LeadSource source) =>
      state = state.copyWith(sources: state.sources.toggled(source));

  /// Adds or removes a status.
  void toggleStatus(LeadStatus status) =>
      state = state.copyWith(statuses: state.statuses.toggled(status));

  /// Adds or removes an area.
  void toggleArea(String area) =>
      state = state.copyWith(areas: state.areas.toggled(area));

  /// Sets the capture-date window.
  void setDateRange(LeadDateRange range) =>
      state = state.copyWith(dateRange: range);

  /// Clears the sheet filters (source, status, area, date).
  void clearSheetFilters() =>
      state = LeadFilters(query: state.query, temperatures: state.temperatures);

  /// Clears everything, including search.
  void clearAll() => state = const LeadFilters();
}

/// Leads after search and filters, newest first.
final filteredLeadsProvider = Provider.autoDispose<AsyncValue<List<Lead>>>((
  ref,
) {
  final filters = ref.watch(leadFiltersProvider);
  final now = DateTime.now();
  return ref
      .watch(leadsControllerProvider)
      .whenData(
        (leads) => leads.where((lead) => filters.matches(lead, now)).toList(),
      );
});

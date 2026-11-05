import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/set_toggle.dart';
import '../../../core/utils/no_automatic_retry.dart';
import '../models/lead.dart';
import '../models/lead_filters.dart';
import '../repositories/leads_repository.dart';

/// Every lead of the brokerage, newest first. Lives while the app shell is
/// open; also read by the Home dashboard.
final leadsControllerProvider =
    AsyncNotifierProvider.autoDispose<LeadsController, List<Lead>>(
      LeadsController.new,
      retry: noAutomaticRetry,
    );

/// Loads the brokerage's leads from the API.
class LeadsController extends AsyncNotifier<List<Lead>> {
  /// Loads the leads, newest first.
  @override
  Future<List<Lead>> build() async {
    // TODO(backend): update live from socket.io lead events.
    final leads = await ref.read(leadsRepositoryProvider).fetchLeads();
    return leads..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Swaps in [lead] after a change made elsewhere (e.g. do-not-contact on
  /// the lead profile), keeping the list in step without a reload.
  void replaceLead(Lead lead) {
    final leads = state.value;
    if (leads == null) return;
    state = AsyncData([
      for (final item in leads) item.id == lead.id ? lead : item,
    ]);
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

/// Areas of the loaded leads, A–Z, for the Territory filter.
final leadAreasProvider = Provider.autoDispose<List<String>>((ref) {
  final leads = ref.watch(leadsControllerProvider).value ?? const <Lead>[];
  return {
    for (final lead in leads)
      if (lead.area.isNotEmpty) lead.area,
  }.toList()..sort();
});

import 'package:flutter/foundation.dart';

import 'lead.dart';

/// How far back the leads list looks.
enum LeadDateRange {
  /// Captured today.
  today('Today', 1),

  /// Captured in the last 7 days.
  week('Last 7 days', 7),

  /// Captured in the last 30 days.
  month('Last 30 days', 30),

  /// No date limit.
  all('All time', null);

  /// Creates a range.
  const LeadDateRange(this.label, this.days);

  /// Display label.
  final String label;

  /// Days covered, or null for no limit.
  final int? days;
}

/// Search text and filters of the Leads screen (screen 11).
@immutable
class LeadFilters {
  /// Creates filters; defaults show every lead.
  const LeadFilters({
    this.query = '',
    this.temperatures = const {},
    this.sources = const {},
    this.statuses = const {},
    this.areas = const {},
    this.dateRange = LeadDateRange.all,
  });

  /// Free-text search over name, phone and area.
  final String query;

  /// Selected score bands; empty means all.
  final Set<LeadTemperature> temperatures;

  /// Selected sources; empty means all.
  final Set<LeadSource> sources;

  /// Selected statuses; empty means all.
  final Set<LeadStatus> statuses;

  /// Selected areas (territories); empty means all.
  final Set<String> areas;

  /// Capture-date window.
  final LeadDateRange dateRange;

  /// Number of sheet filters in use (search and score chips not counted).
  int get sheetFilterCount =>
      sources.length +
      statuses.length +
      areas.length +
      (dateRange == LeadDateRange.all ? 0 : 1);

  /// True when anything narrows the list.
  bool get isFiltering =>
      query.trim().isNotEmpty ||
      temperatures.isNotEmpty ||
      sheetFilterCount > 0;

  /// Whether [lead] passes every filter, relative to [now].
  bool matches(Lead lead, DateTime now) {
    final days = dateRange.days;
    if (days != null &&
        lead.createdAt.isBefore(now.subtract(Duration(days: days)))) {
      return false;
    }
    final temperature = lead.temperature;
    if (temperatures.isNotEmpty &&
        (temperature == null || !temperatures.contains(temperature))) {
      return false;
    }
    if (sources.isNotEmpty && !sources.contains(lead.source)) return false;
    if (statuses.isNotEmpty && !statuses.contains(lead.status)) return false;
    if (areas.isNotEmpty && !areas.contains(lead.area)) return false;
    return _matchesQuery(lead);
  }

  /// Case-insensitive match on name and area, or digits in the phone.
  bool _matchesQuery(Lead lead) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return lead.name.toLowerCase().contains(text) ||
        lead.area.toLowerCase().contains(text) ||
        (digits.length >= 3 &&
            lead.phone.replaceAll(RegExp(r'\D'), '').contains(digits));
  }

  /// Copies with changes.
  LeadFilters copyWith({
    String? query,
    Set<LeadTemperature>? temperatures,
    Set<LeadSource>? sources,
    Set<LeadStatus>? statuses,
    Set<String>? areas,
    LeadDateRange? dateRange,
  }) {
    return LeadFilters(
      query: query ?? this.query,
      temperatures: temperatures ?? this.temperatures,
      sources: sources ?? this.sources,
      statuses: statuses ?? this.statuses,
      areas: areas ?? this.areas,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

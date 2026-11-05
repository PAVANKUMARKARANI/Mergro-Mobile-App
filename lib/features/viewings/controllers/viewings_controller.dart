import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/utils/time_format.dart';
import '../models/viewing.dart';
import '../viewings_demo_data.dart';

/// Upcoming and today's viewings, earliest first. Also read by the dashboard.
final viewingsControllerProvider =
    AsyncNotifierProvider.autoDispose<ViewingsController, List<Viewing>>(
      ViewingsController.new,
    );

/// Loads viewings (demo data until the viewings API exists).
class ViewingsController extends AsyncNotifier<List<Viewing>> {
  /// Loads the viewings.
  @override
  Future<List<Viewing>> build() async {
    // TODO(backend): GET /api/viewings?from=<today>&to=<+7 days>; for agents
    // only their own, for admins and team leads everyone's.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    return ViewingsDemoData.viewings(DateTime.now())
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Adds a viewing booked elsewhere (Book viewing), keeping time order.
  void addViewing(Viewing viewing) {
    final items = state.value;
    if (items == null) return;
    state = AsyncData(
      [...items, viewing]..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
    );
  }
}

/// Which day range the Viewings screen shows.
final viewingRangeProvider =
    NotifierProvider.autoDispose<ViewingRangeController, ViewingRange>(
      ViewingRangeController.new,
    );

/// Holds the selected [ViewingRange].
class ViewingRangeController extends Notifier<ViewingRange> {
  /// Starts on today.
  @override
  ViewingRange build() => ViewingRange.today;

  /// Selects [range].
  void select(ViewingRange range) => state = range;
}

/// Whether [viewing] falls in [range], relative to [now].
bool isInViewingRange(Viewing viewing, ViewingRange range, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(
    viewing.startsAt.year,
    viewing.startsAt.month,
    viewing.startsAt.day,
  );
  final offset = day.difference(today).inDays;
  return switch (range) {
    ViewingRange.today => TimeFormat.isSameDay(day, today),
    ViewingRange.tomorrow => offset == 1,
    ViewingRange.week => offset >= 0 && offset < 7,
  };
}

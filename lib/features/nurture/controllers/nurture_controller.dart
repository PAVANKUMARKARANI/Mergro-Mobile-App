import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../models/nurture_enrollment.dart';
import '../nurture_demo_data.dart';

/// Leads in nurture journeys, soonest next touch first.
final nurtureControllerProvider =
    AsyncNotifierProvider.autoDispose<
      NurtureController,
      List<NurtureEnrollment>
    >(NurtureController.new);

/// Loads enrollments (demo data until the nurture API exists).
class NurtureController extends AsyncNotifier<List<NurtureEnrollment>> {
  /// Loads the enrollments.
  @override
  Future<List<NurtureEnrollment>> build() async {
    // TODO(backend): GET /api/nurture/enrollments (cadence engine, W11–W12).
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    final items = NurtureDemoData.enrollments(DateTime.now());
    final far = DateTime(9999);
    return items
      ..sort((a, b) => (a.nextTouchAt ?? far).compareTo(b.nextTouchAt ?? far));
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Status filter of the Nurture screen; null shows every status.
final nurtureStatusFilterProvider =
    NotifierProvider.autoDispose<NurtureStatusFilter, NurtureStatus?>(
      NurtureStatusFilter.new,
    );

/// Holds the selected [NurtureStatus] filter.
class NurtureStatusFilter extends Notifier<NurtureStatus?> {
  /// Starts unfiltered.
  @override
  NurtureStatus? build() => null;

  /// Shows only [status]; selecting the active filter again clears it.
  void toggle(NurtureStatus status) => state = state == status ? null : status;
}

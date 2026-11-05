import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../calls_demo_data.dart';
import '../models/live_call.dart';

/// AI calls in progress and the dial queue. Also read by the dashboard.
final liveCallsControllerProvider =
    AsyncNotifierProvider.autoDispose<LiveCallsController, LiveCallsSnapshot>(
      LiveCallsController.new,
    );

/// Loads live calls (demo data until the calls API exists).
class LiveCallsController extends AsyncNotifier<LiveCallsSnapshot> {
  /// Loads the snapshot.
  @override
  Future<LiveCallsSnapshot> build() async {
    // TODO(backend): GET /api/calls/live (active calls + dial queue), then
    // keep it current from socket.io `call:*` events instead of polling.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    return CallsDemoData.snapshot(DateTime.now());
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

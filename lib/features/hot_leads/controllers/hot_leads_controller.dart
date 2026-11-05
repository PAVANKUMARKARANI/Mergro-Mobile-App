import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../hot_leads_demo_data.dart';
import '../models/handoff.dart';

/// Hot-lead handoffs: waiting ones first (soonest deadline first), then
/// accepted ones. Also read by the dashboard.
final hotLeadsControllerProvider =
    AsyncNotifierProvider.autoDispose<HotLeadsController, List<Handoff>>(
      HotLeadsController.new,
    );

/// Loads handoffs and accepts them (simulated until the handoff API exists).
class HotLeadsController extends AsyncNotifier<List<Handoff>> {
  /// Loads the inbox.
  @override
  Future<List<Handoff>> build() async {
    // TODO(backend): GET /api/handoffs?status=waiting,accepted; new ones
    // arrive by FCM push and socket.io `handoff:new`.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    return _sorted(HotLeadsDemoData.handoffs(DateTime.now()));
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Accepts the handoff [id] for the signed-in agent. Returns false when it
  /// is missing, already accepted or being accepted.
  Future<bool> accept(String id) async {
    final current = state.value;
    final handoff = current?.where((item) => item.id == id).firstOrNull;
    if (handoff == null ||
        handoff.status == HandoffStatus.accepted ||
        handoff.isAccepting) {
      return false;
    }
    _replace(handoff.copyWith(isAccepting: true));

    // TODO(backend): POST /api/handoffs/{id}/accept; on 409 another agent
    // took it first, so show who and remove it from this inbox.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return false;

    _replace(
      handoff.copyWith(
        status: HandoffStatus.accepted,
        acceptedAt: DateTime.now(),
        isAccepting: false,
      ),
    );
    return true;
  }

  /// Swaps in [updated] and keeps the order rules.
  void _replace(Handoff updated) {
    final items = state.value ?? const <Handoff>[];
    state = AsyncData(
      _sorted([
        for (final item in items) item.id == updated.id ? updated : item,
      ]),
    );
  }

  /// Waiting first by deadline, then accepted, newest first.
  static List<Handoff> _sorted(List<Handoff> items) {
    final waiting =
        items.where((item) => item.status == HandoffStatus.waiting).toList()
          ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final accepted =
        items.where((item) => item.status == HandoffStatus.accepted).toList()
          ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return [...waiting, ...accepted];
  }
}

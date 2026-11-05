import '../leads/models/lead.dart';
import 'models/live_call.dart';

/// Sample calls shown until `GET /api/calls/live` exists.
abstract final class CallsDemoData {
  /// AI replies faster than this sound natural.
  static const int naturalLatencyMs = 800;

  /// Builds the sample snapshot relative to [now].
  static LiveCallsSnapshot snapshot(DateTime now) {
    DateTime ago(int seconds) => now.subtract(Duration(seconds: seconds));
    DateTime later(int seconds) => now.add(Duration(seconds: seconds));
    return LiveCallsSnapshot(
      active: [
        LiveCall(
          id: 'call-01',
          leadId: 'lead-10',
          leadName: 'Priyanka Reddy',
          source: LeadSource.magicBricks,
          area: 'Hebbal',
          startedAt: ago(240),
          stage: CallStage.booking,
          lastLine: 'AI: "I have Saturday at 11 AM or 4 PM. Which suits you?"',
          replyLatencyMs: 610,
        ),
        LiveCall(
          id: 'call-02',
          leadId: 'lead-01',
          leadName: 'Rohan Desai',
          source: LeadSource.acres99,
          area: 'Whitefield',
          startedAt: ago(96),
          stage: CallStage.qualifying,
          lastLine: 'Lead: "Somewhere around 90 lakhs, ready in 3 months."',
          replyLatencyMs: 720,
        ),
        LiveCall(
          id: 'call-03',
          leadId: 'lead-13',
          leadName: 'Deepak Joshi',
          source: LeadSource.website,
          area: 'Koramangala',
          startedAt: ago(12),
          stage: CallStage.disclosure,
          lastLine:
              'AI: "Hi, this is Maya, an AI assistant from Skyline Realty."',
          replyLatencyMs: 940,
        ),
      ],
      queue: [
        QueuedCall(
          id: 'queue-01',
          leadName: 'Harini Subramaniam',
          source: LeadSource.facebook,
          reason: QueueReason.dialingNext,
          dueAt: later(25),
        ),
        QueuedCall(
          id: 'queue-02',
          leadName: 'Arnav Gupta',
          source: LeadSource.acres99,
          reason: QueueReason.retry,
          dueAt: later(55 * 60),
        ),
        QueuedCall(
          id: 'queue-03',
          leadName: 'Meera Nair',
          source: LeadSource.housing,
          reason: QueueReason.callingHours,
          dueAt: DateTime(now.year, now.month, now.day + 1, 9),
        ),
      ],
    );
  }
}

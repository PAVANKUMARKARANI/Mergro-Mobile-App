import 'package:flutter/foundation.dart';

import '../../leads/models/lead.dart';

/// Where an AI call is in its script.
enum CallStage {
  /// Ringing the lead.
  dialing('Dialing'),

  /// Saying it is an AI and that the call is recorded.
  disclosure('AI disclosure'),

  /// Asking budget, area, timeline, type and pre-approval.
  qualifying('Qualifying'),

  /// Offering viewing slots.
  booking('Booking viewing'),

  /// Summarising and saying goodbye.
  wrapUp('Wrapping up');

  /// Creates a stage with its label.
  const CallStage(this.label);

  /// Display label.
  final String label;
}

/// An AI call in progress.
@immutable
class LiveCall {
  /// Creates a call.
  const LiveCall({
    required this.id,
    required this.leadName,
    required this.source,
    required this.area,
    required this.startedAt,
    required this.stage,
    required this.lastLine,
    required this.replyLatencyMs,
  });

  /// Stable id.
  final String id;

  /// Who is being called.
  final String leadName;

  /// Lead source.
  final LeadSource source;

  /// Lead's preferred area.
  final String area;

  /// When the call connected (or started dialing).
  final DateTime startedAt;

  /// Current script stage.
  final CallStage stage;

  /// Latest transcript line, e.g. `Lead: "Around 90 lakhs"`.
  final String lastLine;

  /// How long the AI takes to answer, in milliseconds.
  final int replyLatencyMs;
}

/// Why a lead is waiting to be called.
enum QueueReason {
  /// Will be dialled within the 60-second target.
  dialingNext('Dialling within 60 s'),

  /// Captured outside calling hours; waits for the window to open.
  callingHours('Waiting for calling hours'),

  /// An earlier attempt went unanswered.
  retry('Retry scheduled');

  /// Creates a reason with its label.
  const QueueReason(this.label);

  /// Display label.
  final String label;
}

/// A lead waiting to be called.
@immutable
class QueuedCall {
  /// Creates a queue entry.
  const QueuedCall({
    required this.id,
    required this.leadName,
    required this.source,
    required this.reason,
    required this.dueAt,
  });

  /// Stable id.
  final String id;

  /// Who will be called.
  final String leadName;

  /// Lead source.
  final LeadSource source;

  /// Why it is waiting.
  final QueueReason reason;

  /// When the call is due.
  final DateTime dueAt;
}

/// Calls in progress plus the dial queue.
@immutable
class LiveCallsSnapshot {
  /// Creates a snapshot.
  const LiveCallsSnapshot({required this.active, required this.queue});

  /// Calls in progress, longest first.
  final List<LiveCall> active;

  /// Leads waiting, soonest first.
  final List<QueuedCall> queue;

  /// Average AI reply latency of the active calls, or null with none.
  int? get averageLatencyMs => active.isEmpty
      ? null
      : active.map((call) => call.replyLatencyMs).reduce((a, b) => a + b) ~/
            active.length;
}

import 'package:flutter/foundation.dart';

/// State of a hot-lead handoff.
enum HandoffStatus {
  /// Waiting for an agent to accept.
  waiting('Waiting'),

  /// Accepted by an agent.
  accepted('Accepted');

  /// Creates a status with its label.
  const HandoffStatus(this.label);

  /// Display label.
  final String label;
}

/// A hot lead the AI handed to the sales team.
@immutable
class Handoff {
  /// Creates a handoff.
  const Handoff({
    required this.id,
    required this.leadName,
    required this.score,
    required this.summary,
    required this.reasons,
    required this.nextAction,
    required this.area,
    required this.budget,
    required this.receivedAt,
    this.slaMinutes = 5,
    this.status = HandoffStatus.waiting,
    this.acceptedAt,
    this.isAccepting = false,
  });

  /// Stable id.
  final String id;

  /// Lead's name.
  final String leadName;

  /// AI score 1–100.
  final int score;

  /// One-paragraph AI call summary.
  final String summary;

  /// Why the lead scored high, e.g. "Pre-approved loan".
  final List<String> reasons;

  /// Suggested next step for the agent.
  final String nextAction;

  /// Preferred area.
  final String area;

  /// Budget label.
  final String budget;

  /// When the handoff arrived.
  final DateTime receivedAt;

  /// Minutes an agent has to accept.
  final int slaMinutes;

  /// Waiting or accepted.
  final HandoffStatus status;

  /// When it was accepted, if it was.
  final DateTime? acceptedAt;

  /// True while the accept request runs.
  final bool isAccepting;

  /// Deadline for accepting.
  DateTime get dueAt => receivedAt.add(Duration(minutes: slaMinutes));

  /// Copies with changes.
  Handoff copyWith({
    HandoffStatus? status,
    DateTime? acceptedAt,
    bool? isAccepting,
  }) {
    return Handoff(
      id: id,
      leadName: leadName,
      score: score,
      summary: summary,
      reasons: reasons,
      nextAction: nextAction,
      area: area,
      budget: budget,
      receivedAt: receivedAt,
      slaMinutes: slaMinutes,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      isAccepting: isAccepting ?? this.isAccepting,
    );
  }
}

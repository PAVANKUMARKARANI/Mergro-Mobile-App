import 'package:flutter/foundation.dart';

/// A qualification question the AI asks (screen 16, BANT-style).
enum QualificationKey {
  /// How much they can spend.
  budget('Budget'),

  /// Where they want to live.
  area('Preferred area'),

  /// When they want to move.
  timeline('Timeline'),

  /// What they want to buy.
  propertyType('Property type'),

  /// Whether a home loan is pre-approved.
  preApproval('Loan pre-approval');

  /// Creates a key with its label.
  const QualificationKey(this.label);

  /// Display label.
  final String label;
}

/// One answer captured on a call, with the AI's confidence in it.
@immutable
class QualificationField {
  /// Creates a field; [value] null means not asked or not answered yet.
  const QualificationField({
    required this.key,
    this.value,
    this.confidence = 0,
  });

  /// Which question.
  final QualificationKey key;

  /// The answer, e.g. "₹85 L – 1 Cr".
  final String? value;

  /// AI confidence 0–1 (0 when unanswered).
  final double confidence;

  /// True when the lead answered.
  bool get isAnswered => value != null;
}

/// Why the score moved (screen 17): a reason code and its points.
@immutable
class ScoreReason {
  /// Creates a reason.
  const ScoreReason({
    required this.code,
    required this.label,
    required this.points,
  });

  /// Stable reason code, e.g. "BUDGET_FIT".
  final String code;

  /// Human explanation, e.g. "Budget fits listed homes".
  final String label;

  /// Points added (positive) or removed (negative).
  final int points;
}

/// Kind of activity on the lead timeline (screen 19).
enum TimelineKind {
  /// Lead captured from a source.
  captured,

  /// AI or agent call.
  call,

  /// SMS, WhatsApp or email sent or received.
  message,

  /// Synced to the CRM.
  crmSync,

  /// Viewing booked, held or changed.
  viewing,

  /// Handed to an agent.
  handoff,

  /// Consent changed or lead suppressed.
  consent,
}

/// One event on the lead timeline, newest first in lists.
@immutable
class TimelineEvent {
  /// Creates an event.
  const TimelineEvent({
    required this.at,
    required this.kind,
    required this.title,
    this.detail,
  });

  /// When it happened.
  final DateTime at;

  /// What kind of event.
  final TimelineKind kind;

  /// Headline, e.g. "AI call · qualified".
  final String title;

  /// Extra context.
  final String? detail;
}

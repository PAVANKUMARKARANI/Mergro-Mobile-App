import 'package:flutter/foundation.dart';

import '../../leads/models/lead.dart';
import 'lead_insights.dart';

/// A contact channel that needs the lead's consent (screen 20).
enum ConsentChannel {
  /// Phone calls, including AI calls.
  call('Calls'),

  /// Text messages.
  sms('SMS'),

  /// WhatsApp messages.
  whatsapp('WhatsApp'),

  /// Email.
  email('Email');

  /// Creates a channel with its label.
  const ConsentChannel(this.label);

  /// Display label.
  final String label;
}

/// Consent for one channel, with the evidence for it.
@immutable
class ChannelConsent {
  /// Creates a consent record.
  const ChannelConsent({
    required this.channel,
    required this.isGranted,
    required this.evidence,
    required this.recordedAt,
  });

  /// The channel.
  final ConsentChannel channel;

  /// True when the lead may be contacted on it.
  final bool isGranted;

  /// Where it came from, e.g. "99acres enquiry form" or "Withdrawn by Priya".
  final String evidence;

  /// When it was recorded.
  final DateTime recordedAt;
}

/// How a call ended.
enum CallOutcome {
  /// The AI qualified the lead.
  qualified('Qualified'),

  /// Nobody answered.
  noAnswer('No answer'),

  /// The lead asked to be called later.
  callbackRequested('Call-back requested'),

  /// The lead opted out on the call.
  optedOut('Opted out');

  /// Creates an outcome with its label.
  const CallOutcome(this.label);

  /// Display label.
  final String label;
}

/// A past call with the lead.
@immutable
class CallSummary {
  /// Creates a summary.
  const CallSummary({
    required this.id,
    required this.startedAt,
    required this.duration,
    required this.outcome,
  });

  /// Stable id (opens call detail later).
  final String id;

  /// When it started.
  final DateTime startedAt;

  /// How long it lasted.
  final Duration duration;

  /// How it ended.
  final CallOutcome outcome;
}

/// Actions on the lead profile that run on the server.
enum LeadAction {
  /// AI calls the lead back.
  callBack,

  /// Send an SMS, WhatsApp or email.
  message,

  /// Withdraw consent on a channel.
  consent,

  /// Mark do-not-contact on every channel.
  doNotContact,
}

/// Everything the lead profile (screen 13) shows.
@immutable
class LeadProfile {
  /// Creates a profile.
  const LeadProfile({
    required this.lead,
    required this.email,
    required this.qualification,
    required this.scoreReasons,
    required this.timeline,
    required this.consents,
    required this.calls,
    this.busyAction,
  });

  /// The lead (name, source, status, score…).
  final Lead lead;

  /// Email address, if known.
  final String? email;

  /// Answers to the qualification questions (screen 16).
  final List<QualificationField> qualification;

  /// Reasons behind the score (screen 17).
  final List<ScoreReason> scoreReasons;

  /// Activity, newest first (screen 19).
  final List<TimelineEvent> timeline;

  /// Consent per channel (screen 20).
  final List<ChannelConsent> consents;

  /// Past calls, newest first.
  final List<CallSummary> calls;

  /// The action whose request is running, if any.
  final LeadAction? busyAction;

  /// Starting points before the reasons apply.
  static const int baseScore = 50;

  /// True when the lead must never be contacted again.
  bool get isDoNotContact => lead.status == LeadStatus.suppressed;

  /// Whether contact on [channel] is allowed now.
  bool canContact(ConsentChannel channel) =>
      !isDoNotContact &&
      consents.any((c) => c.channel == channel && c.isGranted);

  /// Copies with changes; [busyAction] takes a getter so it can be cleared.
  LeadProfile copyWith({
    Lead? lead,
    List<TimelineEvent>? timeline,
    List<ChannelConsent>? consents,
    ValueGetter<LeadAction?>? busyAction,
  }) {
    return LeadProfile(
      lead: lead ?? this.lead,
      email: email,
      qualification: qualification,
      scoreReasons: scoreReasons,
      timeline: timeline ?? this.timeline,
      consents: consents ?? this.consents,
      calls: calls,
      busyAction: busyAction != null ? busyAction() : this.busyAction,
    );
  }
}

/// Result of a lead action; the screen shows [message] either way.
sealed class LeadActionOutcome {
  /// Creates an outcome.
  const LeadActionOutcome(this.message);

  /// User-facing text.
  final String message;
}

/// The action was accepted.
class LeadActionSucceeded extends LeadActionOutcome {
  /// Creates a success.
  const LeadActionSucceeded(super.message);
}

/// The action was refused (no consent, busy, failed).
class LeadActionFailed extends LeadActionOutcome {
  /// Creates a failure.
  const LeadActionFailed(super.message);
}

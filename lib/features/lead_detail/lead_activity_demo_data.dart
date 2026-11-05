import '../leads/models/lead.dart';
import 'models/lead_insights.dart';
import 'models/lead_profile.dart';

/// Sample timeline and call history for a demo lead, derived from its
/// status, until `GET /api/leads/:id/timeline` exists.
abstract final class LeadActivityDemoData {
  /// Events up to [now], newest first.
  static List<TimelineEvent> timelineFor(Lead lead, DateTime now) {
    DateTime after(Duration delay) => lead.createdAt.add(delay);
    const callDelay = Duration(seconds: 45);
    final isScored = lead.score != null;
    final events = <TimelineEvent>[
      TimelineEvent(
        at: lead.createdAt,
        kind: TimelineKind.captured,
        title: 'Lead captured · ${lead.source.label}',
        detail: '${lead.propertyType} · ${lead.budget}',
      ),
      if (lead.status == LeadStatus.calling)
        TimelineEvent(
          at: after(const Duration(seconds: 40)),
          kind: TimelineKind.call,
          title: 'AI call started',
          detail: 'Dialled 40 s after capture',
        ),
      if (lead.status == LeadStatus.newLead)
        TimelineEvent(
          at: after(const Duration(seconds: 5)),
          kind: TimelineKind.call,
          title: 'Call scheduled',
          detail: 'Captured outside calling hours',
        ),
      if (isScored) ...[
        TimelineEvent(
          at: after(callDelay),
          kind: TimelineKind.call,
          title: 'AI call · ${_outcomeOf(lead).label.toLowerCase()}',
          detail: 'Score ${lead.score} · ${lead.temperature?.label}',
        ),
        TimelineEvent(
          at: after(const Duration(minutes: 6)),
          kind: TimelineKind.crmSync,
          title: 'Synced to Zoho CRM',
          detail: 'Contact, score and call summary',
        ),
      ],
      ..._statusEvents(lead, after),
    ];
    return events.where((event) => !event.at.isAfter(now)).toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  /// Past calls, newest first; none before the first call ends.
  static List<CallSummary> callsFor(Lead lead) {
    final band = lead.temperature;
    if (band == null) return const [];
    final duration = switch (band) {
      LeadTemperature.hot => const Duration(minutes: 4, seconds: 12),
      LeadTemperature.warm => const Duration(minutes: 3, seconds: 5),
      LeadTemperature.cold => const Duration(minutes: 1, seconds: 40),
    };
    final outcome = _outcomeOf(lead);
    return [
      CallSummary(
        id: 'call-${lead.id}-1',
        startedAt: lead.createdAt.add(const Duration(seconds: 45)),
        duration: outcome == CallOutcome.noAnswer ? Duration.zero : duration,
        outcome: outcome,
      ),
    ];
  }

  /// How the first call ended, from the lead's status.
  static CallOutcome _outcomeOf(Lead lead) => switch (lead.status) {
    LeadStatus.suppressed => CallOutcome.optedOut,
    LeadStatus.nurturing when lead.lastActivity.startsWith('No answer') =>
      CallOutcome.noAnswer,
    LeadStatus.nurturing => CallOutcome.callbackRequested,
    _ => CallOutcome.qualified,
  };

  /// Events specific to the lead's current status.
  static List<TimelineEvent> _statusEvents(
    Lead lead,
    DateTime Function(Duration delay) after,
  ) => switch (lead.status) {
    LeadStatus.viewingBooked => [
      TimelineEvent(
        at: after(const Duration(minutes: 7)),
        kind: TimelineKind.viewing,
        title: 'Viewing booked by the AI',
        detail: 'Confirmation sent by SMS',
      ),
    ],
    LeadStatus.withAgent => [
      TimelineEvent(
        at: after(const Duration(minutes: 7)),
        kind: TimelineKind.handoff,
        title: 'Handed to ${lead.ownerName ?? 'an agent'}',
        detail: 'Hot lead · accepted within SLA',
      ),
    ],
    LeadStatus.nurturing => [
      TimelineEvent(
        at: after(const Duration(hours: 2)),
        kind: TimelineKind.message,
        title: lead.lastActivity,
        detail: 'Follow-up journey · step 1',
      ),
    ],
    LeadStatus.suppressed => [
      TimelineEvent(
        at: after(const Duration(minutes: 3)),
        kind: TimelineKind.consent,
        title: 'Opted out on the AI call',
        detail: 'All channels stopped',
      ),
    ],
    _ => const [],
  };
}

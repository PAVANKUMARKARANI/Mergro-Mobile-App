import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/core/utils/time_format.dart';
import 'package:mergro_ai_voice_assistant/features/home/models/dashboard_summary.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/lead_profile_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_insights.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_profile.dart';
import 'package:mergro_ai_voice_assistant/features/leads/leads_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead.dart';
import 'package:mergro_ai_voice_assistant/features/leads/repositories/leads_repository.dart';

/// In-memory [LeadsRepository] over the demo leads (ids `lead-01`…). Actions
/// change the stored profiles the way the server does.
class FakeLeadsRepository implements LeadsRepository {
  /// Creates the fake; [failWith] makes every call fail with that error.
  FakeLeadsRepository({this.failWith});

  /// Error every call throws, when set.
  ApiException? failWith;

  /// Error the next action throws (then cleared).
  ApiException? failNextAction;

  /// Actions received, e.g. `callBack lead-02`.
  final List<String> actions = [];

  final Map<String, LeadProfile> _profiles = {
    for (final lead in LeadsDemoData.leads(DateTime.now()))
      lead.id: LeadProfileDemoData.profileFor(lead, DateTime.now()),
  };

  static const Duration _latency = Duration(milliseconds: 10);

  @override
  Future<List<Lead>> fetchLeads() async {
    await _respond();
    return [for (final profile in _profiles.values) profile.lead];
  }

  @override
  Future<DashboardSummary> fetchSummary() async {
    await _respond();
    final now = DateTime.now();
    final today = [
      for (final profile in _profiles.values)
        if (TimeFormat.isSameDay(profile.lead.createdAt, now)) profile.lead,
    ];
    return DashboardSummary(
      speedToLeadSeconds: null,
      newLeadsToday: today.length,
      qualifiedToday: today
          .where((lead) => lead.status == LeadStatus.qualified)
          .length,
      contactRatePercent: 0,
    );
  }

  @override
  Future<LeadProfile> fetchProfile(String id) async {
    await _respond();
    return _profile(id);
  }

  @override
  Future<void> withdrawConsent(String id, ConsentChannel channel) =>
      _act('consent', id, (profile) {
        return profile.copyWith(
          consents: [
            for (final consent in profile.consents)
              consent.channel == channel ? _withdrawn(consent) : consent,
          ],
          timeline: _withEvent(profile, TimelineKind.consent, 'Withdrawn'),
        );
      });

  @override
  Future<void> suppress(String id) => _act(
    'suppress',
    id,
    (profile) => profile.copyWith(
      lead: profile.lead.copyWith(
        status: LeadStatus.suppressed,
        lastActivity: 'Marked do-not-contact',
      ),
      consents: [for (final consent in profile.consents) _withdrawn(consent)],
      timeline: _withEvent(profile, TimelineKind.consent, 'Do not contact'),
    ),
  );

  @override
  Future<void> requestCallBack(String id) => _act(
    'callBack',
    id,
    (profile) => profile.copyWith(
      timeline: _withEvent(profile, TimelineKind.call, 'Call-back requested'),
    ),
  );

  @override
  Future<void> sendMessage(String id, ConsentChannel channel, String text) =>
      _act(
        'message',
        id,
        (profile) => profile.copyWith(
          timeline: _withEvent(
            profile,
            TimelineKind.message,
            '${channel.label} queued',
            text,
          ),
        ),
      );

  Future<void> _act(
    String name,
    String id,
    LeadProfile Function(LeadProfile profile) apply,
  ) async {
    await _respond();
    final failure = failNextAction;
    if (failure != null) {
      failNextAction = null;
      throw failure;
    }
    actions.add('$name $id');
    _profiles[id] = apply(_profile(id));
  }

  Future<void> _respond() async {
    await Future<void>.delayed(_latency);
    final failure = failWith;
    if (failure != null) throw failure;
  }

  LeadProfile _profile(String id) =>
      _profiles[id] ??
      (throw ApiException(
        ApiErrorKind.notFound,
        message: 'This lead no longer exists.',
      ));

  static ChannelConsent _withdrawn(ChannelConsent consent) => ChannelConsent(
    channel: consent.channel,
    isGranted: false,
    evidence: 'Withdrawn',
    recordedAt: DateTime.now(),
  );

  static List<TimelineEvent> _withEvent(
    LeadProfile profile,
    TimelineKind kind,
    String title, [
    String? detail,
  ]) => [
    TimelineEvent(at: DateTime.now(), kind: kind, title: title, detail: detail),
    ...profile.timeline,
  ];
}

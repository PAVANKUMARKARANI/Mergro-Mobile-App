import '../../../core/network/api_response_mapper.dart';
import '../../leads/models/lead.dart';
import 'lead_insights.dart';
import 'lead_profile.dart';

// Parsing of `GET /api/leads/:id` (profile) and `/timeline` (events). Names
// of enums travel as their Dart names; unknown entries are skipped rather
// than failing the whole profile.

/// The profile from the lead JSON and its timeline events.
LeadProfile leadProfileFromJson(JsonMap lead, List<dynamic> events) {
  final email = lead['email'];
  return LeadProfile(
    lead: Lead.fromJson(lead),
    email: email is String && email.isNotEmpty ? email : null,
    qualification: _qualification(lead['qualification']),
    scoreReasons: [
      for (final item in _maps(lead['scoreReasons']))
        if (item['code'] is String && item['points'] is num)
          ScoreReason(
            code: item['code'] as String,
            label: item['label'] as String? ?? '',
            points: (item['points'] as num).round(),
          ),
    ],
    timeline: [for (final item in _maps(events)) ?_event(item)],
    consents: [
      for (final item in _maps(lead['consents']))
        if (ConsentChannel.values.asNameMap()[item['channel']]
            case final channel?)
          ChannelConsent(
            channel: channel,
            isGranted: item['isGranted'] == true,
            evidence: item['evidence'] as String? ?? '',
            recordedAt: _date(item['recordedAt']) ?? DateTime.now(),
          ),
    ],
    // TODO(backend): GET /api/calls?leadId= once call records exist.
    calls: const [],
  );
}

/// Every question, answered where the API has a value.
List<QualificationField> _qualification(Object? json) {
  final answers = <QualificationKey, QualificationField>{};
  for (final item in _maps(json)) {
    final key = QualificationKey.values.asNameMap()[item['key']];
    if (key == null) continue;
    answers[key] = QualificationField(
      key: key,
      value: item['value'] as String?,
      confidence: (item['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
  return [
    for (final key in QualificationKey.values)
      answers[key] ?? QualificationField(key: key),
  ];
}

/// One timeline event, or null when its kind or time is unknown.
TimelineEvent? _event(JsonMap json) {
  final kind = TimelineKind.values.asNameMap()[json['kind']];
  final at = _date(json['at']);
  final title = json['title'];
  if (kind == null || at == null || title is! String) return null;
  return TimelineEvent(
    at: at,
    kind: kind,
    title: title,
    detail: json['detail'] as String?,
  );
}

/// The JSON objects in [json] when it is a list.
List<JsonMap> _maps(Object? json) =>
    json is List ? json.whereType<JsonMap>().toList() : const [];

/// A local time from an ISO string.
DateTime? _date(Object? json) =>
    json is String ? DateTime.tryParse(json)?.toLocal() : null;

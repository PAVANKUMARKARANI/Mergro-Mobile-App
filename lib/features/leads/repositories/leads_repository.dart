import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/models/dashboard_summary.dart';
import '../../lead_detail/models/lead_profile.dart';
import '../../lead_detail/models/lead_profile_json.dart';
import '../models/lead.dart';
import '../services/leads_api_service.dart';

/// Leads data for the app; overridden with a fake in tests.
final leadsRepositoryProvider = Provider<LeadsRepository>(
  (ref) => LeadsRepository(ref.watch(leadsApiServiceProvider)),
);

/// Loads leads and runs lead actions. Throws [ApiException] on failure.
class LeadsRepository {
  /// Creates the repository on top of [_api].
  LeadsRepository(this._api);

  final LeadsApiService _api;

  /// Most leads the list loads at once; filtering happens on the device.
  static const int pageSize = 100;

  /// The newest leads the user may see.
  Future<List<Lead>> fetchLeads() async {
    // TODO(backend): page beyond 100 and pass filters to the server
    // (`q`, `temperature`, `source`, `status`, `area`, `days`) once lead
    // volumes need it; the endpoint already supports them.
    final details = await _api.fetchLeads({'limit': pageSize});
    final items = details['items'];
    if (items is! List) throw ApiException(ApiErrorKind.unexpected);
    return _parse(
      () => items.whereType<Map<String, dynamic>>().map(Lead.fromJson).toList(),
    );
  }

  /// Today's dashboard numbers.
  Future<DashboardSummary> fetchSummary() async {
    final json = await _api.fetchSummary();
    int count(String key) => (json[key] as num?)?.round() ?? 0;
    return DashboardSummary(
      speedToLeadSeconds: (json['speedToLeadSeconds'] as num?)?.round(),
      newLeadsToday: count('newLeadsToday'),
      qualifiedToday: count('qualifiedToday'),
      contactRatePercent: count('contactRatePercent'),
    );
  }

  /// The full profile of lead [id] with its timeline.
  Future<LeadProfile> fetchProfile(String id) async {
    final results = await Future.wait<Object>([
      _api.fetchLead(id),
      _api.fetchTimeline(id),
    ]);
    return _parse(
      () => leadProfileFromJson(
        results[0] as Map<String, dynamic>,
        results[1] as List<dynamic>,
      ),
    );
  }

  /// Records that the lead withdrew consent on [channel].
  Future<void> withdrawConsent(String id, ConsentChannel channel) =>
      _api.withdrawConsent(id, channel.name);

  /// Marks the lead do-not-contact.
  Future<void> suppress(String id) => _api.suppress(id);

  /// Asks for an AI call-back (recorded until the dialler exists).
  Future<void> requestCallBack(String id) => _api.requestCallBack(id);

  /// Sends [text] on [channel] (recorded until messaging exists).
  Future<void> sendMessage(String id, ConsentChannel channel, String text) =>
      _api.sendMessage(id, channel.name, text);

  /// Runs [parse], turning malformed data into an unexpected error.
  static T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException catch (error) {
      AppLogger.error('Unreadable lead data from the API', error);
      throw ApiException(ApiErrorKind.unexpected);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Leads endpoints of the Mergro API.
final leadsApiServiceProvider = Provider<LeadsApiService>(
  (ref) => LeadsApiService(ref.watch(apiClientProvider)),
);

/// Raw calls to `/api/leads/*`. Returns each response's `details`.
class LeadsApiService {
  /// Creates the service on top of [_client].
  LeadsApiService(this._client);

  final ApiClient _client;

  /// `GET /leads` with [query] (`limit`, `page`, filters).
  Future<JsonMap> fetchLeads(Map<String, Object?> query) async =>
      _details(await _client.get('/leads', query: query));

  /// `GET /leads/summary`.
  Future<JsonMap> fetchSummary() async =>
      _details(await _client.get('/leads/summary'));

  /// `GET /leads/{id}`.
  Future<JsonMap> fetchLead(String id) async =>
      _details(await _client.get('/leads/$id'));

  /// `GET /leads/{id}/timeline` → the `events` list.
  Future<List<dynamic>> fetchTimeline(String id) async {
    final events = _details(await _client.get('/leads/$id/timeline'))['events'];
    if (events is! List) throw ApiException(ApiErrorKind.unexpected);
    return events;
  }

  /// `PUT /leads/{id}/consent` withdrawing [channel].
  Future<void> withdrawConsent(String id, String channel) => _client.put(
    '/leads/$id/consent',
    body: {'channel': channel, 'granted': false},
  );

  /// `POST /leads/{id}/suppress`.
  Future<void> suppress(String id) => _client.post('/leads/$id/suppress');

  /// `POST /leads/{id}/call-back`.
  Future<void> requestCallBack(String id) =>
      _client.post('/leads/$id/call-back');

  /// `POST /leads/{id}/messages`.
  Future<void> sendMessage(String id, String channel, String text) => _client
      .post('/leads/$id/messages', body: {'channel': channel, 'text': text});

  /// The `details` object of a response.
  static JsonMap _details(JsonMap json) {
    final details = json['details'];
    if (details is! Map<String, dynamic>) {
      throw ApiException(ApiErrorKind.unexpected);
    }
    return details;
  }
}

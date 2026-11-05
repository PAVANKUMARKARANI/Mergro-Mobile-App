import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

/// Onboarding and team endpoints of the Mergro API.
final onboardingApiServiceProvider = Provider<OnboardingApiService>(
  (ref) => OnboardingApiService(ref.watch(apiClientProvider)),
);

/// Raw calls to `/api/onboarding/*` and `/api/team/*`. Returns the
/// response's `details`.
class OnboardingApiService {
  /// Creates the service on top of [_client].
  OnboardingApiService(this._client);

  final ApiClient _client;

  /// `GET /onboarding`: role, steps, completed/skipped steps and drafts.
  Future<JsonMap> fetchProgress() async =>
      _details(await _client.get('/onboarding'));

  /// `PUT /onboarding/steps/{stepName}` with the step's [data].
  Future<JsonMap> saveStep(String stepName, JsonMap data) async => _details(
    await _client.put('/onboarding/steps/$stepName', body: {'data': data}),
  );

  /// `PUT /onboarding/steps/{stepName}` marking an optional step skipped.
  Future<JsonMap> skipStep(String stepName) async => _details(
    await _client.put('/onboarding/steps/$stepName', body: {'skipped': true}),
  );

  /// `POST /onboarding/complete`.
  Future<JsonMap> complete() async =>
      _details(await _client.post('/onboarding/complete'));

  /// `POST /team/invites` with `[{email, role}]`.
  Future<JsonMap> sendInvites(List<JsonMap> invites) async =>
      _details(await _client.post('/team/invites', body: {'invites': invites}));

  /// The `details` object of a response.
  static JsonMap _details(JsonMap json) {
    final details = json['details'];
    if (details is! Map<String, dynamic>) {
      throw ApiException(ApiErrorKind.unexpected);
    }
    return details;
  }
}

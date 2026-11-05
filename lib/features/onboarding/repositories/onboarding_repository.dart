import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/agent_setup_drafts.dart';
import '../models/onboarding_flow_models.dart';
import '../models/onboarding_progress.dart';
import '../services/onboarding_api_service.dart';

/// Onboarding persistence; overridden with a fake in tests.
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(onboardingApiServiceProvider)),
);

/// Loads and saves onboarding progress and sends team invites. Throws
/// `ApiException` on failure.
class OnboardingRepository {
  /// Creates the repository on top of [_api].
  OnboardingRepository(this._api);

  final OnboardingApiService _api;

  /// Saved progress, for resuming where the user left off.
  Future<OnboardingProgress> fetchProgress() async =>
      OnboardingProgress.fromJson(await _api.fetchProgress());

  /// Saves [step] with [data] (see `draft_json.dart` for the shapes).
  Future<void> saveStep(OnboardingStepId step, JsonMap data) =>
      _api.saveStep(step.name, data);

  /// Records that the optional [step] was skipped.
  Future<void> skipStep(OnboardingStepId step) => _api.skipStep(step.name);

  /// Marks onboarding complete; for admins this activates the brokerage.
  Future<void> complete() => _api.complete();

  /// Invites [invites] by email and reports each one's outcome.
  Future<InviteResult> sendInvites(List<TeamInvite> invites) async {
    final details = await _api.sendInvites([
      for (final invite in invites)
        {'email': invite.email, 'role': invite.role.name},
    ]);
    return InviteResult.fromJson(details);
  }
}

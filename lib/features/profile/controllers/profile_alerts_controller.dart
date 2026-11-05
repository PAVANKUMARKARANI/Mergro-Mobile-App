import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/models/agent_profile_drafts.dart';

/// The signed-in user's hot-lead alert settings on the Profile screen.
final profileAlertsControllerProvider =
    NotifierProvider.autoDispose<ProfileAlertsController, HotLeadAlertsDraft>(
      ProfileAlertsController.new,
    );

/// Edits alert settings locally (saved once the profile API exists).
class ProfileAlertsController extends Notifier<HotLeadAlertsDraft> {
  /// Starts from the defaults.
  @override
  HotLeadAlertsDraft build() {
    // TODO(backend): GET /api/profile/alerts — the onboarding step already
    // stores these on the employee (`alertPreferences`); expose and load them.
    return const HotLeadAlertsDraft();
  }

  // TODO(backend): each setter below should PUT /api/profile/alerts and roll
  // back with a message when it fails.

  /// Turns push alerts on or off.
  void setPush(bool enabled) => state = state.copyWith(pushEnabled: enabled);

  /// Turns the SMS fallback on or off.
  void setSmsFallback(bool enabled) =>
      state = state.copyWith(smsFallbackEnabled: enabled);

  /// Turns the alert sound on or off.
  void setSound(bool enabled) => state = state.copyWith(soundEnabled: enabled);
}

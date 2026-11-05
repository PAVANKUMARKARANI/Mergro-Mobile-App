import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/set_toggle.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../models/agent_profile_drafts.dart';

/// Agent step 1 draft; kept alive so values survive Back / Next.
final agentProfileControllerProvider =
    NotifierProvider<AgentProfileController, AgentProfileDraft>(
      AgentProfileController.new,
    );

/// Agent step 2 draft; kept alive so values survive Back / Next.
final hotLeadAlertsControllerProvider =
    NotifierProvider<HotLeadAlertsController, HotLeadAlertsDraft>(
      HotLeadAlertsController.new,
    );

/// Edits the agent's personal profile.
class AgentProfileController extends Notifier<AgentProfileDraft> {
  /// Pre-fills the name from the signed-in user.
  @override
  AgentProfileDraft build() {
    // read, not watch: later user changes must not wipe the typed draft.
    final name = ref.read(currentUserProvider)?.name ?? '';
    return AgentProfileDraft(fullName: name);
  }

  /// Updates the full name.
  void updateName(String name) => state = state.copyWith(fullName: name);

  /// Updates the mobile number.
  void updateMobile(String mobile) =>
      state = state.copyWith(mobileNumber: mobile);

  /// Shows or removes the placeholder photo (no picker in this phase).
  void setHasPhoto(bool hasPhoto) => state = state.copyWith(hasPhoto: hasPhoto);

  /// Toggles a spoken language.
  void toggleLanguage(String language) =>
      state = state.copyWith(languages: state.languages.toggled(language));
}

/// Edits hot-lead alert preferences.
class HotLeadAlertsController extends Notifier<HotLeadAlertsDraft> {
  /// Starts with every alert on.
  @override
  HotLeadAlertsDraft build() => const HotLeadAlertsDraft();

  /// Turns push notifications on or off.
  void setPush(bool enabled) => state = state.copyWith(pushEnabled: enabled);

  /// Turns the SMS fallback on or off.
  void setSmsFallback(bool enabled) =>
      state = state.copyWith(smsFallbackEnabled: enabled);

  /// Turns the alert sound on or off.
  void setSound(bool enabled) => state = state.copyWith(soundEnabled: enabled);

  /// Sets the start of quiet hours.
  void setQuietStart(TimeOfDay time) =>
      state = state.copyWith(quietStart: time);

  /// Sets the end of quiet hours.
  void setQuietEnd(TimeOfDay time) => state = state.copyWith(quietEnd: time);
}

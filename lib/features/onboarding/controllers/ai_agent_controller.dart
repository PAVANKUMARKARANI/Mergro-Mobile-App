import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/set_toggle.dart';
import '../models/agent_setup_drafts.dart';
import '../models/onboarding_options.dart';

/// Admin step 5 draft; kept alive so values survive Back / Next.
final aiAgentControllerProvider =
    NotifierProvider<AiAgentController, AiAgentDraft>(AiAgentController.new);

/// Edits the AI voice agent persona.
class AiAgentController extends Notifier<AiAgentDraft> {
  /// Starts with "Maya", warm female voice, English.
  @override
  AiAgentDraft build() => const AiAgentDraft();

  /// Updates the agent name.
  void updateName(String name) => state = state.copyWith(agentName: name);

  /// Selects a voice.
  void selectVoice(AgentVoice voice) => state = state.copyWith(voice: voice);

  /// Toggles a language.
  void toggleLanguage(String language) =>
      state = state.copyWith(languages: state.languages.toggled(language));
}

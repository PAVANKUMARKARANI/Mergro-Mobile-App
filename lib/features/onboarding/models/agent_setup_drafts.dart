import 'package:flutter/foundation.dart';

import '../../auth/models/app_user.dart';
import '../onboarding_demo_data.dart';
import 'onboarding_options.dart';

/// Draft for admin step 5: AI voice agent persona.
@immutable
class AiAgentDraft {
  /// Creates a draft with the default name, warm female voice and English.
  const AiAgentDraft({
    this.agentName = OnboardingDemoData.defaultAgentName,
    this.voice = AgentVoice.warmFemale,
    this.languages = const {'English'},
  });

  /// Agent name used in the greeting.
  final String agentName;

  /// Selected voice.
  final AgentVoice voice;

  /// Languages the agent speaks.
  final Set<String> languages;

  /// The AI disclosure is always on; it is not user-editable.
  bool get disclosesAi => true;

  /// A name and at least one language are set.
  bool get isValid => agentName.trim().isNotEmpty && languages.isNotEmpty;

  /// Copies with changes.
  AiAgentDraft copyWith({
    String? agentName,
    AgentVoice? voice,
    Set<String>? languages,
  }) {
    return AiAgentDraft(
      agentName: agentName ?? this.agentName,
      voice: voice ?? this.voice,
      languages: languages ?? this.languages,
    );
  }
}

/// One pending team invite.
@immutable
class TeamInvite {
  /// Creates an invite.
  const TeamInvite({required this.email, this.role = UserRole.salesAgent});

  /// Invitee email.
  final String email;

  /// Role the invitee will get.
  final UserRole role;

  /// Copies with a new [role].
  TeamInvite copyWith({UserRole? role}) =>
      TeamInvite(email: email, role: role ?? this.role);
}

/// Draft for admin step 6: team invites.
@immutable
class InviteTeamDraft {
  /// Creates a draft with no invites.
  const InviteTeamDraft({
    this.invites = const [],
    this.isSending = false,
    this.sentCount = 0,
  });

  /// Pending invites in the order they were added.
  final List<TeamInvite> invites;

  /// True while invites are being sent.
  final bool isSending;

  /// How many invites have been sent so far.
  final int sentCount;

  /// Continue needs at least one invite; otherwise use "Skip for now".
  bool get isValid => invites.isNotEmpty;

  /// Copies with changes.
  InviteTeamDraft copyWith({
    List<TeamInvite>? invites,
    bool? isSending,
    int? sentCount,
  }) {
    return InviteTeamDraft(
      invites: invites ?? this.invites,
      isSending: isSending ?? this.isSending,
      sentCount: sentCount ?? this.sentCount,
    );
  }
}

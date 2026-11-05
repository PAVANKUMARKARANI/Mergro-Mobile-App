import 'package:flutter/foundation.dart';

import '../../auth/models/app_user.dart';

/// Every onboarding step across all roles.
enum OnboardingStepId {
  /// Admin 1: brokerage details.
  brokerageProfile('Brokerage profile', 'Tell us about your brokerage.'),

  /// Admin 2: CRM and lead sources.
  crmLeadSources('CRM & lead sources', 'Connect where your leads live.'),

  /// Admin 3 (optional): calendar for viewings.
  viewingCalendar(
    'Calendar for viewings',
    'Let the AI book viewings into real calendars.',
    isOptional: true,
  ),

  /// Admin 4: phone line and calling rules.
  phoneLine('Phone line & calling rules', 'Choose how Mergro calls leads.'),

  /// Admin 5: AI voice agent persona.
  aiAgent('AI voice agent', 'Give your agent a name, voice and greeting.'),

  /// Admin 6 (optional): invite the team.
  inviteTeam(
    'Invite your team',
    'Add agents and leads so hot leads reach a human fast.',
    isOptional: true,
  ),

  /// Agent / team lead 1: personal profile.
  agentProfile('Your profile', 'How leads and teammates will see you.'),

  /// Agent / team lead 2: hot-lead alerts.
  hotLeadAlerts('Hot-lead alerts', 'Never miss a qualified lead.'),

  /// Agent 3 (optional): calendar and availability.
  agentCalendar(
    'Calendar & availability',
    'When can the AI book viewings for you?',
    isOptional: true,
  );

  /// Creates a step with its header copy.
  const OnboardingStepId(this.title, this.subtitle, {this.isOptional = false});

  /// Step heading.
  final String title;

  /// Step subheading.
  final String subtitle;

  /// Optional steps show "Skip for now".
  final bool isOptional;

  /// Ordered steps for [role].
  static List<OnboardingStepId> stepsFor(UserRole role) => switch (role) {
    UserRole.brokerageAdmin => const [
      brokerageProfile,
      crmLeadSources,
      viewingCalendar,
      phoneLine,
      aiAgent,
      inviteTeam,
    ],
    UserRole.salesAgent => const [agentProfile, hotLeadAlerts, agentCalendar],
    // Team leads and other staff get the agent essentials only.
    UserRole.teamLead ||
    UserRole.operations ||
    UserRole.complianceReviewer => const [agentProfile, hotLeadAlerts],
  };
}

/// Result of finishing onboarding.
sealed class OnboardingFinishOutcome {
  /// Base constructor.
  const OnboardingFinishOutcome();
}

/// Onboarding was saved; show the success screen.
class OnboardingFinished extends OnboardingFinishOutcome {
  /// Creates a success outcome for [role].
  const OnboardingFinished(this.role);

  /// Role that finished, to pick the success copy.
  final UserRole role;
}

/// Finishing failed or was already running; [message] is user-facing.
class OnboardingFinishFailed extends OnboardingFinishOutcome {
  /// Creates a failure outcome.
  const OnboardingFinishFailed(this.message);

  /// Why it failed.
  final String message;
}

/// Immutable position within the onboarding flow.
@immutable
class OnboardingFlowState {
  /// Creates a flow state.
  const OnboardingFlowState({
    required this.role,
    required this.steps,
    this.currentIndex = 0,
    this.completedSteps = const {},
    this.skippedSteps = const {},
    this.isFinishing = false,
  });

  /// Role of the signed-in user.
  final UserRole role;

  /// Ordered steps for [role].
  final List<OnboardingStepId> steps;

  /// Index into [steps]; equals `steps.length` on the Review page.
  final int currentIndex;

  /// Steps finished with Continue.
  final Set<OnboardingStepId> completedSteps;

  /// Optional steps skipped with "Skip for now".
  final Set<OnboardingStepId> skippedSteps;

  /// True while finish() runs.
  final bool isFinishing;

  /// Admins end with a Review page before launching.
  bool get hasReview => role == UserRole.brokerageAdmin;

  /// True on the admin Review page.
  bool get isReview => currentIndex >= steps.length;

  /// The active step, or null on Review.
  OnboardingStepId? get currentStep => isReview ? null : steps[currentIndex];

  /// True on the final step (Continue finishes or opens Review).
  bool get isLastStep => currentIndex == steps.length - 1;

  /// 1-based step number for the header, capped at the step count.
  int get stepNumber => (currentIndex + 1).clamp(1, steps.length);

  /// Copies with changes.
  OnboardingFlowState copyWith({
    int? currentIndex,
    Set<OnboardingStepId>? completedSteps,
    Set<OnboardingStepId>? skippedSteps,
    bool? isFinishing,
  }) {
    return OnboardingFlowState(
      role: role,
      steps: steps,
      currentIndex: currentIndex ?? this.currentIndex,
      completedSteps: completedSteps ?? this.completedSteps,
      skippedSteps: skippedSteps ?? this.skippedSteps,
      isFinishing: isFinishing ?? this.isFinishing,
    );
  }
}

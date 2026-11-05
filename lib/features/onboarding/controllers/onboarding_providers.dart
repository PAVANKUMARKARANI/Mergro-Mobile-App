import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../models/onboarding_flow_models.dart';
import 'agent_profile_controllers.dart';
import 'ai_agent_controller.dart';
import 'brokerage_profile_controller.dart';
import 'calendar_controller.dart';
import 'crm_controller.dart';
import 'invite_team_controller.dart';
import 'onboarding_flow_controller.dart';
import 'phone_line_controller.dart';

/// Whether [OnboardingStepId]'s draft is complete enough to enable Continue.
final stepValidProvider = Provider.family<bool, OnboardingStepId>(
  (ref, step) => switch (step) {
    OnboardingStepId.brokerageProfile => ref.watch(
      brokerageProfileControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.crmLeadSources => ref.watch(
      crmControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.viewingCalendar => ref.watch(
      viewingCalendarControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.phoneLine => ref.watch(
      phoneLineControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.aiAgent => ref.watch(
      aiAgentControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.inviteTeam => ref.watch(
      inviteTeamControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.agentProfile => ref.watch(
      agentProfileControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.hotLeadAlerts => ref.watch(
      hotLeadAlertsControllerProvider.select((draft) => draft.isValid),
    ),
    OnboardingStepId.agentCalendar => ref.watch(
      agentCalendarControllerProvider.select((draft) => draft.isValid),
    ),
  },
);

/// Every provider holding onboarding state, for [resetOnboarding].
final List<ProviderOrFamily> onboardingProviders = [
  onboardingFlowControllerProvider,
  brokerageProfileControllerProvider,
  crmControllerProvider,
  viewingCalendarControllerProvider,
  phoneLineControllerProvider,
  aiAgentControllerProvider,
  inviteTeamControllerProvider,
  agentProfileControllerProvider,
  hotLeadAlertsControllerProvider,
  agentCalendarControllerProvider,
  stepValidProvider,
];

/// Clears all onboarding drafts and the flow position. Called when the flow
/// finishes and when the preview restarts.
void resetOnboarding(ProviderContainer container) {
  for (final provider in onboardingProviders) {
    container.invalidate(provider);
  }
}

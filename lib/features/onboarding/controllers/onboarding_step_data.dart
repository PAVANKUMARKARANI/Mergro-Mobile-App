import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_response_mapper.dart';
import '../models/draft_json.dart';
import '../models/onboarding_flow_models.dart';
import 'agent_profile_controllers.dart';
import 'ai_agent_controller.dart';
import 'brokerage_profile_controller.dart';
import 'calendar_controller.dart';
import 'crm_controller.dart';
import 'phone_line_controller.dart';

/// The data `PUT /onboarding/steps/{step}` saves for [step], read from that
/// step's draft controller.
JsonMap stepPayload(Ref ref, OnboardingStepId step) => switch (step) {
  OnboardingStepId.brokerageProfile =>
    ref.read(brokerageProfileControllerProvider).toJson(),
  OnboardingStepId.crmLeadSources => ref.read(crmControllerProvider).toJson(),
  OnboardingStepId.viewingCalendar =>
    ref.read(viewingCalendarControllerProvider).toJson(),
  OnboardingStepId.phoneLine => ref.read(phoneLineControllerProvider).toJson(),
  OnboardingStepId.aiAgent => ref.read(aiAgentControllerProvider).toJson(),
  // Invites are sent on their own (POST /team/invites) before this save.
  OnboardingStepId.inviteTeam => const {},
  OnboardingStepId.agentProfile =>
    ref.read(agentProfileControllerProvider).toJson(),
  OnboardingStepId.hotLeadAlerts =>
    ref.read(hotLeadAlertsControllerProvider).toJson(),
  OnboardingStepId.agentCalendar =>
    ref.read(agentCalendarControllerProvider).toJson(),
};

/// Puts a draft saved on the server back into [step]'s controller.
void restoreStep(Ref ref, OnboardingStepId step, JsonMap json) {
  switch (step) {
    case OnboardingStepId.brokerageProfile:
      ref
          .read(brokerageProfileControllerProvider.notifier)
          .restore(BrokerageProfileJson.fromJson(json));
    case OnboardingStepId.crmLeadSources:
      ref.read(crmControllerProvider.notifier).restore(CrmJson.fromJson(json));
    case OnboardingStepId.viewingCalendar:
      ref
          .read(viewingCalendarControllerProvider.notifier)
          .restore(CalendarJson.fromJson(json));
    case OnboardingStepId.phoneLine:
      ref
          .read(phoneLineControllerProvider.notifier)
          .restore(PhoneLineJson.fromJson(json));
    case OnboardingStepId.aiAgent:
      ref
          .read(aiAgentControllerProvider.notifier)
          .restore(AiAgentJson.fromJson(json));
    case OnboardingStepId.inviteTeam:
      // Sent invites live on the server; there is no draft to restore.
      break;
    case OnboardingStepId.agentProfile:
      ref
          .read(agentProfileControllerProvider.notifier)
          .restore(AgentProfileJson.fromJson(json));
    case OnboardingStepId.hotLeadAlerts:
      ref
          .read(hotLeadAlertsControllerProvider.notifier)
          .restore(HotLeadAlertsJson.fromJson(json));
    case OnboardingStepId.agentCalendar:
      ref
          .read(agentCalendarControllerProvider.notifier)
          .restore(CalendarJson.fromJson(json));
  }
}

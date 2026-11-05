import '../../../shared/ui.dart';
import '../models/onboarding_flow_models.dart';
import 'steps/agent_profile_step.dart';
import 'steps/ai_agent_step.dart';
import 'steps/brokerage_profile_step.dart';
import 'steps/calendar_step.dart';
import 'steps/crm_lead_sources_step.dart';
import 'steps/hot_lead_alerts_step.dart';
import 'steps/invite_team_step.dart';
import 'steps/phone_line_step.dart';

/// Scrollable body of one step: title, subtitle and the step's form.
class StepContent extends StatelessWidget {
  /// Creates the content for [step].
  const StepContent({super.key, required this.step});

  /// The step to render.
  final OnboardingStepId step;

  /// Builds the header and form.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: step.title,
            subtitle: step.isOptional
                ? '${step.subtitle} Optional — you can finish this later.'
                : step.subtitle,
            isLarge: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildForm(),
        ],
      ),
    );
  }

  /// The form widget for [step].
  Widget _buildForm() => switch (step) {
    OnboardingStepId.brokerageProfile => const BrokerageProfileStep(),
    OnboardingStepId.crmLeadSources => const CrmLeadSourcesStep(),
    OnboardingStepId.viewingCalendar => CalendarStep.viewings(),
    OnboardingStepId.phoneLine => const PhoneLineStep(),
    OnboardingStepId.aiAgent => const AiAgentStep(),
    OnboardingStepId.inviteTeam => const InviteTeamStep(),
    OnboardingStepId.agentProfile => const AgentProfileStep(),
    OnboardingStepId.hotLeadAlerts => const HotLeadAlertsStep(),
    OnboardingStepId.agentCalendar => CalendarStep.availability(),
  };
}

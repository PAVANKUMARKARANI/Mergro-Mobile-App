import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/auth_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/brokerage_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/onboarding_providers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';

/// Creates a container with a signed-in dummy user of [role].
ProviderContainer _containerFor(UserRole role) {
  final container = ProviderContainer.test();
  container
      .read(currentUserProvider.notifier)
      .setUser(AuthDemoData.userFor(role, 'test@skyline.in'));
  return container;
}

void main() {
  test('each role gets its own ordered step list', () {
    expect(
      _containerFor(UserRole.brokerageAdmin)
          .read(onboardingFlowControllerProvider)
          .steps,
      [
        OnboardingStepId.brokerageProfile,
        OnboardingStepId.crmLeadSources,
        OnboardingStepId.viewingCalendar,
        OnboardingStepId.phoneLine,
        OnboardingStepId.aiAgent,
        OnboardingStepId.inviteTeam,
      ],
    );
    expect(
      _containerFor(UserRole.salesAgent)
          .read(onboardingFlowControllerProvider)
          .steps,
      [
        OnboardingStepId.agentProfile,
        OnboardingStepId.hotLeadAlerts,
        OnboardingStepId.agentCalendar,
      ],
    );
    expect(
      _containerFor(UserRole.teamLead)
          .read(onboardingFlowControllerProvider)
          .steps,
      [OnboardingStepId.agentProfile, OnboardingStepId.hotLeadAlerts],
    );
  });

  test('next / back move through steps and record completion', () {
    final container = _containerFor(UserRole.brokerageAdmin);
    final flow = container.read(onboardingFlowControllerProvider.notifier);

    flow.next();
    var state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.crmLeadSources);
    expect(state.completedSteps, {OnboardingStepId.brokerageProfile});

    flow.back();
    state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.brokerageProfile);
    flow.back();
    expect(container.read(onboardingFlowControllerProvider).currentIndex, 0);
  });

  test('skip only works on optional steps', () {
    final container = _containerFor(UserRole.brokerageAdmin);
    final flow = container.read(onboardingFlowControllerProvider.notifier);

    flow.skip();
    expect(
      container.read(onboardingFlowControllerProvider).currentIndex,
      0,
      reason: 'brokerage profile is required',
    );

    flow
      ..next()
      ..next()
      ..skip();
    final state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.phoneLine);
    expect(state.skippedSteps, {OnboardingStepId.viewingCalendar});
  });

  test('admin reaches Review after the last step; agents stop there', () {
    final admin = _containerFor(UserRole.brokerageAdmin);
    final adminFlow = admin.read(onboardingFlowControllerProvider.notifier);
    for (var i = 0; i < 6; i++) {
      adminFlow.next();
    }
    expect(admin.read(onboardingFlowControllerProvider).isReview, isTrue);
    adminFlow.back();
    expect(
      admin.read(onboardingFlowControllerProvider).currentStep,
      OnboardingStepId.inviteTeam,
    );

    final lead = _containerFor(UserRole.teamLead);
    final leadFlow = lead.read(onboardingFlowControllerProvider.notifier);
    leadFlow
      ..next()
      ..next();
    final leadState = lead.read(onboardingFlowControllerProvider);
    expect(leadState.isLastStep, isTrue);
    expect(leadState.isReview, isFalse);
  });

  test('Continue stays disabled until the step is valid', () {
    final container = _containerFor(UserRole.brokerageAdmin);
    final profile = container.read(brokerageProfileControllerProvider.notifier);
    bool isValid() =>
        container.read(stepValidProvider(OnboardingStepId.brokerageProfile));

    expect(isValid(), isFalse);
    profile.updateName('Skyline Realty');
    expect(isValid(), isFalse, reason: 'country and time zone missing');
    profile.setCountry(Country.india);
    expect(isValid(), isTrue, reason: 'India auto-selects its only zone');
  });

  test('step values survive Back / Next', () {
    final container = _containerFor(UserRole.brokerageAdmin);
    final flow = container.read(onboardingFlowControllerProvider.notifier);
    container
        .read(brokerageProfileControllerProvider.notifier)
        .updateName('Skyline Realty');

    flow
      ..next()
      ..back();

    expect(
      container.read(brokerageProfileControllerProvider).brokerageName,
      'Skyline Realty',
    );
  });

  test('finish returns the role, and reset clears every draft', () async {
    final container = _containerFor(UserRole.brokerageAdmin);
    final flow = container.read(onboardingFlowControllerProvider.notifier);
    container
        .read(brokerageProfileControllerProvider.notifier)
        .updateName('Skyline Realty');
    flow.next();

    final future = flow.finish();
    expect(container.read(onboardingFlowControllerProvider).isFinishing, true);
    final outcome = await future;
    expect((outcome as OnboardingFinished).role, UserRole.brokerageAdmin);

    resetOnboarding(container);
    expect(container.read(onboardingFlowControllerProvider).currentIndex, 0);
    expect(
      container.read(brokerageProfileControllerProvider).brokerageName,
      '',
    );
  });
}

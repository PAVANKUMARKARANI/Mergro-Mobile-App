import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/ai_agent_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/brokerage_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/onboarding_flow_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/onboarding_providers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_progress.dart';

import '../../helpers/fakes.dart';

/// A container with a signed-in user of [role] and the [server] fake.
ProviderContainer _containerFor(
  UserRole role, [
  FakeOnboardingRepository? server,
]) {
  final container = fakeContainer(onboarding: server);
  container.read(currentUserProvider.notifier).setUser(testUser(role));
  return container;
}

/// The flow controller of [container], with progress loaded.
Future<OnboardingFlowController> _loadedFlow(
  ProviderContainer container,
) async {
  final flow = container.read(onboardingFlowControllerProvider.notifier);
  expect(await flow.loadProgress(), isA<StepActionSucceeded>());
  return flow;
}

void main() {
  test('each role gets its own ordered step list', () {
    List<OnboardingStepId> stepsOf(UserRole role) =>
        _containerFor(role).read(onboardingFlowControllerProvider).steps;

    expect(stepsOf(UserRole.brokerageAdmin), [
      OnboardingStepId.brokerageProfile,
      OnboardingStepId.crmLeadSources,
      OnboardingStepId.viewingCalendar,
      OnboardingStepId.phoneLine,
      OnboardingStepId.aiAgent,
      OnboardingStepId.inviteTeam,
    ]);
    expect(stepsOf(UserRole.salesAgent), [
      OnboardingStepId.agentProfile,
      OnboardingStepId.hotLeadAlerts,
      OnboardingStepId.agentCalendar,
    ]);
    expect(stepsOf(UserRole.teamLead), [
      OnboardingStepId.agentProfile,
      OnboardingStepId.hotLeadAlerts,
    ]);
  });

  test('starts loading, then resumes at the first open step', () async {
    final server = FakeOnboardingRepository()
      ..progress = const OnboardingProgress(
        completedSteps: {OnboardingStepId.brokerageProfile},
        skippedSteps: {OnboardingStepId.viewingCalendar},
        drafts: {
          OnboardingStepId.brokerageProfile: {
            'brokerageName': 'Skyline Realty',
            'country': 'india',
            'timeZone': 'Asia/Kolkata',
            'opensAt': '08:30',
            'closesAt': '18:00',
          },
        },
      );
    final container = _containerFor(UserRole.brokerageAdmin, server);
    expect(container.read(onboardingFlowControllerProvider).isLoading, isTrue);

    await _loadedFlow(container);

    final state = container.read(onboardingFlowControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.currentStep, OnboardingStepId.crmLeadSources);
    final profile = container.read(brokerageProfileControllerProvider);
    expect(profile.brokerageName, 'Skyline Realty');
    expect(profile.country, Country.india);
  });

  test('a failed load keeps the error for Retry', () async {
    final server = FakeOnboardingRepository()
      ..error = ApiException(ApiErrorKind.network);
    final container = _containerFor(UserRole.salesAgent, server);
    final flow = container.read(onboardingFlowControllerProvider.notifier);

    final outcome = await flow.loadProgress();

    expect(outcome, isA<StepActionFailed>());
    final state = container.read(onboardingFlowControllerProvider);
    expect(state.loadError, ApiException.defaultMessages[ApiErrorKind.network]);
    expect(state.isLoading, isFalse);

    server.error = null;
    expect(await flow.loadProgress(), isA<StepActionSucceeded>());
    expect(container.read(onboardingFlowControllerProvider).loadError, isNull);
  });

  test('next saves the step draft, then advances; back keeps it', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.brokerageAdmin, server);
    final flow = await _loadedFlow(container);
    container.read(brokerageProfileControllerProvider.notifier)
      ..updateName(' Skyline Realty ')
      ..setCountry(Country.india);

    final future = flow.next();
    expect(container.read(onboardingFlowControllerProvider).isSaving, isTrue);
    expect(await future, isA<StepActionSucceeded>());

    var state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.crmLeadSources);
    expect(state.completedSteps, {OnboardingStepId.brokerageProfile});
    expect(
      server.saved[OnboardingStepId.brokerageProfile]?['brokerageName'],
      'Skyline Realty',
    );

    flow.back();
    state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.brokerageProfile);
    expect(
      container.read(brokerageProfileControllerProvider).brokerageName,
      ' Skyline Realty ',
    );
  });

  test('a failed save stays on the step and reports why', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.brokerageAdmin, server);
    final flow = await _loadedFlow(container);
    server.error = ApiException(
      ApiErrorKind.validation,
      message: '"brokerageName" is not allowed to be empty',
    );

    final outcome = await flow.next();

    expect((outcome as StepActionFailed).message, contains('brokerageName'));
    final state = container.read(onboardingFlowControllerProvider);
    expect(state.currentIndex, 0);
    expect(state.isSaving, isFalse);
  });

  test('an expired session is flagged for sign-in', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.teamLead, server);
    final flow = await _loadedFlow(container);
    server.error = ApiException(ApiErrorKind.unauthorized);

    final outcome = await flow.next();

    expect((outcome as StepActionFailed).isSessionExpired, isTrue);
  });

  test('skip only works on optional steps and is saved', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.brokerageAdmin, server);
    final flow = await _loadedFlow(container);

    expect(await flow.skip(), isA<StepActionFailed>());
    expect(container.read(onboardingFlowControllerProvider).currentIndex, 0);

    await flow.next();
    await flow.next();
    expect(await flow.skip(), isA<StepActionSucceeded>());
    final state = container.read(onboardingFlowControllerProvider);
    expect(state.currentStep, OnboardingStepId.phoneLine);
    expect(state.skippedSteps, {OnboardingStepId.viewingCalendar});
    expect(server.skipped, [OnboardingStepId.viewingCalendar]);
  });

  test('admin reaches Review after the last step; agents stop there', () async {
    final admin = _containerFor(UserRole.brokerageAdmin);
    final adminFlow = await _loadedFlow(admin);
    for (var i = 0; i < 6; i++) {
      await adminFlow.next();
    }
    expect(admin.read(onboardingFlowControllerProvider).isReview, isTrue);
    adminFlow.back();
    expect(
      admin.read(onboardingFlowControllerProvider).currentStep,
      OnboardingStepId.inviteTeam,
    );

    final lead = _containerFor(UserRole.teamLead);
    final leadFlow = await _loadedFlow(lead);
    await leadFlow.next();
    await leadFlow.next();
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

  test('finish completes on the server; reset clears every draft', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.brokerageAdmin, server);
    final flow = await _loadedFlow(container);
    container.read(aiAgentControllerProvider.notifier).updateName('Asha');

    final future = flow.finish();
    expect(container.read(onboardingFlowControllerProvider).isFinishing, true);
    final outcome = await future;
    expect((outcome as OnboardingFinished).role, UserRole.brokerageAdmin);
    expect(server.completeCount, 1);

    resetOnboarding(container);
    expect(container.read(onboardingFlowControllerProvider).currentIndex, 0);
    expect(container.read(aiAgentControllerProvider).agentName, isNot('Asha'));
  });

  test('a failed finish reports the server message', () async {
    final server = FakeOnboardingRepository();
    final container = _containerFor(UserRole.salesAgent, server);
    final flow = await _loadedFlow(container);
    server.error = ApiException(
      ApiErrorKind.validation,
      message: 'Finish these steps first: agentProfile.',
    );

    final outcome = await flow.finish();

    expect(
      (outcome as OnboardingFinishFailed).message,
      contains('agentProfile'),
    );
    expect(container.read(onboardingFlowControllerProvider).isFinishing, false);
  });
}

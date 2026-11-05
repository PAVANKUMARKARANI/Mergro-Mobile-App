import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/agent_profile_controllers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_progress.dart';

import '../../helpers/fakes.dart';
import '../../helpers/onboarding_screen_utils.dart';

/// Onboarding screen behaviour that depends on server responses.
void main() {
  testWidgets('resumes at the first step not yet saved', (tester) async {
    final server = FakeOnboardingRepository()
      ..progress = const OnboardingProgress(
        completedSteps: {OnboardingStepId.agentProfile},
      );
    await pumpOnboarding(tester, UserRole.teamLead, [], server: server);
    expectStep(tester, 2, 2);
  });

  testWidgets('load failure offers Retry', (tester) async {
    final server = FakeOnboardingRepository()
      ..error = ApiException(ApiErrorKind.network);
    await pumpOnboarding(tester, UserRole.salesAgent, [], server: server);
    expect(find.text("Couldn't load your setup"), findsOneWidget);
    expect(tester.takeException(), isNull);

    server.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pump(fakeLatency);
    await tester.pump(stepTransition);
    expectStep(tester, 1, 3);
  });

  testWidgets('a failed save shows a snack bar and stays', (tester) async {
    final server = FakeOnboardingRepository();
    final container = await pumpOnboarding(
      tester,
      UserRole.teamLead,
      [],
      server: server,
    );
    container
        .read(agentProfileControllerProvider.notifier)
        .updateMobile('+91 98765 43210');
    await tester.pump();
    server.error = ApiException(ApiErrorKind.server);

    await tapBar(tester, 'Continue');

    expect(
      find.text(ApiException.defaultMessages[ApiErrorKind.server]!),
      findsOneWidget,
    );
    expectStep(tester, 1, 2);
  });

  testWidgets('an expired session hands back to sign-in', (tester) async {
    final server = FakeOnboardingRepository()
      ..error = ApiException(ApiErrorKind.unauthorized);
    final expired = <void>[];
    await pumpOnboarding(
      tester,
      UserRole.salesAgent,
      [],
      server: server,
      expired: expired,
    );
    expect(expired, hasLength(1));
  });
}

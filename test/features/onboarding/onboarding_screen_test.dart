import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/agent_profile_controllers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/brokerage_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/crm_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/invite_team_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/phone_line_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/onboarding_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/screens/onboarding_success_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/onboarding_screen_utils.dart';
import '../../helpers/test_app.dart';

void main() {
  for (final isDark in [false, true]) {
    testWidgets('admin taps through all 6 steps, review and launch '
        '(360 px, 1.3x, dark=$isDark)', (tester) async {
      final finished = <UserRole>[];
      final container = await pumpOnboarding(
        tester,
        UserRole.brokerageAdmin,
        finished,
        isDark: isDark,
      );

      expectStep(tester, 1, 6);
      container.read(brokerageProfileControllerProvider.notifier)
        ..updateName('Skyline Realty')
        ..setCountry(Country.india);
      await tester.pump();
      await tapBar(tester, 'Continue');

      expectStep(tester, 2, 6);
      container.read(crmControllerProvider.notifier).connectZoho();
      await tester.pump(simulatedCall);
      await tapBar(tester, 'Continue');

      expectStep(tester, 3, 6);
      await tester.tap(find.text('Skip for now'));
      await tester.pump(fakeLatency);
      await tester.pump(stepTransition);

      expectStep(tester, 4, 6);
      container.read(phoneLineControllerProvider.notifier)
        ..selectProvider(TelephonyProvider.exotel)
        ..selectNumber(OnboardingDemoData.sampleNumbers[Country.india]!.first)
        ..setConsent(true);
      await tester.pump();
      await tapBar(tester, 'Continue');

      expectStep(tester, 5, 6);
      expect(
        find.textContaining('calling from Skyline Realty'),
        findsOneWidget,
      );
      await tapBar(tester, 'Continue');

      expectStep(tester, 6, 6);
      container
          .read(inviteTeamControllerProvider.notifier)
          .addInvite('arjun@skyline.in');
      await tester.pump();
      await tapBar(tester, 'Continue');
      await tester.pump(simulatedCall);

      expect(find.text('Review & launch'), findsOneWidget);
      expect(find.text('Finish later'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tapBar(tester, 'Launch Mergro');
      await tester.pump(simulatedCall);
      expect(finished, [UserRole.brokerageAdmin]);
    });
  }

  testWidgets('Continue is disabled until the step is valid', (tester) async {
    await pumpOnboarding(tester, UserRole.brokerageAdmin, []);
    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
  });

  testWidgets('sales agent: 3 steps then finish', (tester) async {
    final finished = <UserRole>[];
    final container = await pumpOnboarding(
      tester,
      UserRole.salesAgent,
      finished,
    );

    expectStep(tester, 1, 3);
    container
        .read(agentProfileControllerProvider.notifier)
        .updateMobile('+91 98765 43210');
    await tester.pump();
    await tapBar(tester, 'Continue');
    expectStep(tester, 2, 3);
    await tapBar(tester, 'Continue');
    expectStep(tester, 3, 3);
    await tapBar(tester, 'Finish');
    await tester.pump(simulatedCall);
    expect(finished, [UserRole.salesAgent]);
  });

  testWidgets('team lead: 2 steps, values kept after Back', (tester) async {
    final container = await pumpOnboarding(tester, UserRole.teamLead, []);

    expectStep(tester, 1, 2);
    await tester.enterText(
      find.widgetWithText(TextField, testNamesByRole[UserRole.teamLead]!),
      'Neha K',
    );
    container
        .read(agentProfileControllerProvider.notifier)
        .updateMobile('+91 98765 43210');
    await tester.pump();
    await tapBar(tester, 'Continue');
    expectStep(tester, 2, 2);
    expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(stepTransition);
    expectStep(tester, 1, 2);
    expect(find.text('Neha K'), findsOneWidget);
  });

  testWidgets('wide layout shows the step rail', (tester) async {
    await pumpOnboarding(
      tester,
      UserRole.brokerageAdmin,
      [],
      size: const Size(1100, 800),
    );
    expect(find.text('Review & launch'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('success screen has no button and opens the dashboard by '
      'itself 2 s after the animation', (tester) async {
    var continued = 0;
    await pumpTestApp(
      tester,
      OnboardingSuccessScreen.forRole(
        role: UserRole.brokerageAdmin,
        onContinue: () => continued++,
      ),
    );
    expect(find.byType(FilledButton), findsNothing);

    // 1.6 s animation + 2 s hold = 3.6 s. Frames every 100 ms, like a device.
    await _pumpFrames(tester, const Duration(milliseconds: 3400));
    expect(find.text('Mergro is live'), findsOneWidget);
    expect(continued, 0);
    expect(tester.takeException(), isNull);

    await _pumpFrames(tester, const Duration(milliseconds: 400));
    expect(continued, 1);
    await _pumpFrames(tester, const Duration(seconds: 3));
    expect(continued, 1, reason: 'continues only once');
  });

  testWidgets('with reduced motion it still waits 2 s, then continues', (
    tester,
  ) async {
    var continued = 0;
    await pumpTestApp(
      tester,
      OnboardingSuccessScreen.forRole(
        role: UserRole.salesAgent,
        onContinue: () => continued++,
      ),
      disableAnimations: true,
    );
    await tester.pump(const Duration(milliseconds: 1900));
    expect(continued, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(continued, 1);
  });
}

/// Advances [duration] drawing a frame every 100 ms.
Future<void> _pumpFrames(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += frame) {
    await tester.pump(frame);
  }
}

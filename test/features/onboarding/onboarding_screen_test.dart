import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/auth_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/agent_profile_controllers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/brokerage_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/crm_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/invite_team_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/phone_line_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/onboarding_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/screens/onboarding_screen.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/screens/onboarding_success_screen.dart';

import '../../helpers/test_app.dart';

/// Step transition plus a frame.
const Duration _transition = Duration(milliseconds: 300);

/// Simulated backend call plus a frame.
const Duration _network = Duration(milliseconds: 1100);

/// Pumps onboarding for [role]; finished roles are recorded in [finished].
Future<ProviderContainer> _pumpOnboarding(
  WidgetTester tester,
  UserRole role,
  List<UserRole> finished, {
  bool isDark = false,
  Size size = smallPhone,
}) async {
  final container = ProviderContainer.test();
  container
      .read(currentUserProvider.notifier)
      .setUser(AuthDemoData.userFor(role, 'test@skyline.in'));
  await pumpTestApp(
    tester,
    OnboardingScreen(onFinished: finished.add),
    container: container,
    isDark: isDark,
    size: size,
  );
  return container;
}

/// Taps the bottom-bar button labelled [label] and lets the step settle.
Future<void> _tapBar(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label).last);
  await tester.pump(_transition);
}

/// Asserts the step header and that nothing overflowed.
void _expectStep(WidgetTester tester, int step, int total) {
  expect(find.text('Step $step of $total'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  for (final isDark in [false, true]) {
    testWidgets('admin taps through all 6 steps, review and launch '
        '(360 px, 1.3x, dark=$isDark)', (tester) async {
      final finished = <UserRole>[];
      final container = await _pumpOnboarding(
        tester,
        UserRole.brokerageAdmin,
        finished,
        isDark: isDark,
      );

      _expectStep(tester, 1, 6);
      container.read(brokerageProfileControllerProvider.notifier)
        ..updateName('Skyline Realty')
        ..setCountry(Country.india);
      await tester.pump();
      await _tapBar(tester, 'Continue');

      _expectStep(tester, 2, 6);
      container.read(crmControllerProvider.notifier).connectZoho();
      await tester.pump(_network);
      await _tapBar(tester, 'Continue');

      _expectStep(tester, 3, 6);
      await tester.tap(find.text('Skip for now'));
      await tester.pump(_transition);

      _expectStep(tester, 4, 6);
      container.read(phoneLineControllerProvider.notifier)
        ..selectProvider(TelephonyProvider.exotel)
        ..selectNumber(OnboardingDemoData.sampleNumbers[Country.india]!.first)
        ..setConsent(true);
      await tester.pump();
      await _tapBar(tester, 'Continue');

      _expectStep(tester, 5, 6);
      expect(
        find.textContaining('calling from Skyline Realty'),
        findsOneWidget,
      );
      await _tapBar(tester, 'Continue');

      _expectStep(tester, 6, 6);
      container
          .read(inviteTeamControllerProvider.notifier)
          .addInvite('arjun@skyline.in');
      await tester.pump();
      await _tapBar(tester, 'Continue');
      await tester.pump(_network);

      expect(find.text('Review & launch'), findsOneWidget);
      expect(find.text('Finish later'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tapBar(tester, 'Launch Mergro');
      await tester.pump(_network);
      expect(finished, [UserRole.brokerageAdmin]);
    });
  }

  testWidgets('Continue is disabled until the step is valid', (tester) async {
    await _pumpOnboarding(tester, UserRole.brokerageAdmin, []);
    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
  });

  testWidgets('sales agent: 3 steps then finish', (tester) async {
    final finished = <UserRole>[];
    final container = await _pumpOnboarding(
      tester,
      UserRole.salesAgent,
      finished,
    );

    _expectStep(tester, 1, 3);
    container
        .read(agentProfileControllerProvider.notifier)
        .updateMobile('+91 98765 43210');
    await tester.pump();
    await _tapBar(tester, 'Continue');
    _expectStep(tester, 2, 3);
    await _tapBar(tester, 'Continue');
    _expectStep(tester, 3, 3);
    await _tapBar(tester, 'Finish');
    await tester.pump(_network);
    expect(finished, [UserRole.salesAgent]);
  });

  testWidgets('team lead: 2 steps, values kept after Back', (tester) async {
    final container = await _pumpOnboarding(tester, UserRole.teamLead, []);

    _expectStep(tester, 1, 2);
    await tester.enterText(
      find.widgetWithText(
        TextField,
        AuthDemoData.namesByRole[UserRole.teamLead]!,
      ),
      'Neha K',
    );
    container
        .read(agentProfileControllerProvider.notifier)
        .updateMobile('+91 98765 43210');
    await tester.pump();
    await _tapBar(tester, 'Continue');
    _expectStep(tester, 2, 2);
    expect(find.widgetWithText(FilledButton, 'Finish'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(_transition);
    _expectStep(tester, 1, 2);
    expect(find.text('Neha K'), findsOneWidget);
  });

  testWidgets('wide layout shows the step rail', (tester) async {
    await _pumpOnboarding(
      tester,
      UserRole.brokerageAdmin,
      [],
      size: const Size(1100, 800),
    );
    expect(find.text('Review & launch'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('success screen draws without overflow', (tester) async {
    await pumpTestApp(
      tester,
      OnboardingSuccessScreen.forRole(
        role: UserRole.brokerageAdmin,
        onContinue: () {},
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Mergro is live'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

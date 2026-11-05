import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/screens/onboarding_screen.dart';

import 'fakes.dart';
import 'test_app.dart';

/// Step transition plus a frame.
const Duration stepTransition = Duration(milliseconds: 300);

/// Simulated Zoho / server call plus a frame.
const Duration simulatedCall = Duration(milliseconds: 1100);

/// Pumps onboarding for [role] against [server] and waits for saved progress
/// to load. Finished roles are recorded in [finished]; session expiries
/// increment [expired].
Future<ProviderContainer> pumpOnboarding(
  WidgetTester tester,
  UserRole role,
  List<UserRole> finished, {
  bool isDark = false,
  Size size = smallPhone,
  FakeOnboardingRepository? server,
  List<void>? expired,
}) async {
  final container = fakeContainer(onboarding: server);
  container.read(currentUserProvider.notifier).setUser(testUser(role));
  await pumpTestApp(
    tester,
    OnboardingScreen(
      onFinished: finished.add,
      onSessionExpired: () => expired?.add(null),
    ),
    container: container,
    isDark: isDark,
    size: size,
  );
  await tester.pump(stepTransition);
  return container;
}

/// Taps the bottom-bar button labelled [label], lets the save finish and the
/// step settle.
Future<void> tapBar(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label).last);
  await tester.pump(fakeLatency);
  await tester.pump(stepTransition);
}

/// Asserts the step header and that nothing overflowed.
void expectStep(WidgetTester tester, int step, int total) {
  expect(find.text('Step $step of $total'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

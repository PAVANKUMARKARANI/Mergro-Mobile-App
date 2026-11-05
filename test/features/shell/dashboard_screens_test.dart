import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/calls/screens/live_calls_screen.dart';
import 'package:mergro_ai_voice_assistant/features/home/screens/home_screen.dart';
import 'package:mergro_ai_voice_assistant/features/hot_leads/screens/hot_leads_screen.dart';
import 'package:mergro_ai_voice_assistant/features/leads/screens/leads_screen.dart';
import 'package:mergro_ai_voice_assistant/features/nurture/screens/nurture_screen.dart';
import 'package:mergro_ai_voice_assistant/features/profile/screens/profile_screen.dart';
import 'package:mergro_ai_voice_assistant/features/shell/screens/more_screen.dart';
import 'package:mergro_ai_voice_assistant/features/viewings/screens/viewings_screen.dart';
import 'package:mergro_ai_voice_assistant/shared/widgets/skeleton.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// Demo data delay plus a frame.
const Duration loaded = Duration(milliseconds: 1100);

/// Screens of the shell, with text that proves their data rendered.
final Map<String, (Widget, String)> screens = {
  'Home': (
    HomeScreen(onOpenTab: (_) {}, onOpenLead: (_) {}, onOpenCall: (_) {}),
    'Speed to lead · today (P95)',
  ),
  'Leads': (
    LeadsScreen(onOpenFilters: () {}, onOpenLead: (_) {}),
    'Rohan Desai',
  ),
  'Live calls': (LiveCallsScreen(onOpenCall: (_) {}), 'Priyanka Reddy'),
  'Hot leads': (HotLeadsScreen(onOpenLead: (_) {}), 'Ananya Iyer'),
  'Viewings': (ViewingsScreen(onOpenLead: (_) {}), 'Today'),
  'Nurture': (const NurtureScreen(), 'Karthik Rao'),
  'Profile': (ProfileScreen(onSignOut: () {}), 'Hot-lead alerts'),
  'More': (MoreScreen(onOpenTab: (_) {}), 'Viewings'),
};

/// Pumps [screen] for a signed-in admin.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  bool isDark = false,
}) async {
  final container = fakeContainer();
  container
      .read(currentUserProvider.notifier)
      .setUser(testUser(UserRole.brokerageAdmin));
  await pumpTestApp(tester, screen, container: container, isDark: isDark);
}

void main() {
  for (final isDark in [false, true]) {
    for (final MapEntry(key: name, value: (screen, proof)) in screens.entries) {
      testWidgets('$name renders its data at 360 px, 1.3x, dark=$isDark', (
        tester,
      ) async {
        await pumpScreen(tester, screen, isDark: isDark);
        await tester.pump(loaded);
        expect(find.textContaining(proof), findsWidgets);
        expect(tester.takeException(), isNull);

        // Scroll to the end so every card is laid out at least once.
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.last, const Offset(0, -3000));
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('lists show a skeleton, not a spinner, while loading', (
    tester,
  ) async {
    await pumpScreen(tester, HotLeadsScreen(onOpenLead: (_) {}));
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    await tester.pump(loaded);
    expect(find.byType(SkeletonList), findsNothing);
  });

  testWidgets('the dashboard loads with placeholders in its own layout', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      HomeScreen(onOpenTab: (_) {}, onOpenLead: (_) {}, onOpenCall: (_) {}),
    );
    expect(find.byType(SkeletonPulse), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Hot leads waiting'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(loaded);
    expect(find.byType(SkeletonPulse), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/app/app_routes.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/screens/lead_profile_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../shell/dashboard_screens_test.dart' show loaded, pumpScreen;

/// Pumps the profile of [leadId] and waits for it to load.
Future<void> _pumpProfile(
  WidgetTester tester,
  String leadId, {
  bool isDark = false,
}) async {
  await pumpScreen(
    tester,
    LeadProfileScreen(
      leadId: leadId,
      onComposeMessage: () {},
      onBookViewing: () {},
      onOpenCall: (_) {},
    ),
    isDark: isDark,
  );
  await tester.pump(loaded);
}

/// Scrolls the profile to the bottom, checking nothing overflows.
Future<void> _scrollThrough(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }
}

/// Taps [text], scrolling it into view first.
Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}

void main() {
  for (final isDark in [false, true]) {
    for (final (id, proof) in [
      ('lead-02', 'Budget fits homes in the area'), // hot, with agent
      ('lead-01', 'The AI asks these on the first call.'), // not scored
      ('lead-09', 'This lead opted out'), // suppressed
    ]) {
      testWidgets('$id renders at 360 px, 1.3x, dark=$isDark', (tester) async {
        await _pumpProfile(tester, id, isDark: isDark);
        await tester.scrollUntilVisible(
          find.textContaining(proof),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        await _scrollThrough(tester);
      });
    }
  }

  testWidgets('do-not-contact asks first, then locks the profile', (
    tester,
  ) async {
    await _pumpProfile(tester, 'lead-03');

    await _tapText(tester, 'Do not contact');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('This lead opted out.'), findsNothing);

    await _tapText(tester, 'Do not contact');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Do not contact'));
    await tester.pump();
    await tester.pump(loaded);

    expect(find.textContaining("won't be contacted again"), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.textContaining('This lead opted out'), findsOneWidget);
  });

  testWidgets('a lead opens from the Leads tab and can be messaged', (
    tester,
  ) async {
    final container = fakeContainer();
    container
        .read(currentUserProvider.notifier)
        .setUser(testUser(UserRole.brokerageAdmin));
    await pumpTestApp(tester, AppRoutes.home(), container: container);
    await tester.pump(loaded);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Leads'),
      ),
    );
    await tester.pump(loaded);
    await tester.enterText(find.byType(TextField), 'Ananya');
    await tester.pump();

    await _tapText(tester, 'Ananya Iyer');
    await tester.pumpAndSettle();
    await tester.pump(loaded);
    expect(find.byType(LeadProfileScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await _tapText(tester, 'Message');
    await tester.pumpAndSettle();
    expect(find.text('Message Ananya'), findsOneWidget);
    await _tapText(tester, 'Follow-up');
    await _tapText(tester, 'Send WhatsApp');
    await tester.pump(loaded);
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp sent to Ananya.'), findsOneWidget);
    expect(find.text('Message Ananya'), findsNothing, reason: 'sheet closed');
  });
}

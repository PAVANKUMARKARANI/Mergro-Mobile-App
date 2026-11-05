import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/app/app_routes.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/calls/screens/call_detail_screen.dart';
import 'package:mergro_ai_voice_assistant/features/calls/screens/live_call_monitor_screen.dart';
import 'package:mergro_ai_voice_assistant/features/calls/screens/transcript_screen.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/screens/lead_profile_screen.dart';
import 'package:mergro_ai_voice_assistant/features/viewings/screens/book_viewing_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../shell/dashboard_screens_test.dart' show loaded, pumpScreen;

/// Scrolls the first scrollable to the end, checking nothing overflows.
Future<void> _scrollThrough(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pump();
    expect(tester.takeException(), isNull);
  }
}

/// Taps [finder], scrolling it fully into view first.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  final screens = <String, (Widget Function(), String)>{
    'monitor': (
      () => LiveCallMonitorScreen(callId: 'call-01', onOpenLead: (_) {}),
      'Captured so far',
    ),
    'call detail': (
      () => CallDetailScreen(callId: 'call-lead-02-1', onOpenTranscript: () {}),
      'AI summary',
    ),
    'transcript': (
      () => const TranscriptScreen(callId: 'call-lead-02-1'),
      'masked',
    ),
    'book viewing': (
      () => BookViewingScreen(leadId: 'lead-02', onBooked: (_) {}),
      'Listing',
    ),
  };
  for (final isDark in [false, true]) {
    for (final MapEntry(key: name, value: (build, proof)) in screens.entries) {
      testWidgets('$name renders at 360 px, 1.3x, dark=$isDark', (
        tester,
      ) async {
        await pumpScreen(tester, build(), isDark: isDark);
        await tester.pump(loaded);
        expect(find.textContaining(proof), findsWidgets);
        expect(tester.takeException(), isNull);
        await _scrollThrough(tester);
      });
    }
  }

  testWidgets('transcript masks the phone number and email', (tester) async {
    await pumpScreen(tester, const TranscriptScreen(callId: 'call-lead-02-1'));
    await tester.pump(loaded);
    await tester.scrollUntilVisible(
      find.textContaining('a•••@gmail.com'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('99001 44871'), findsNothing);
  });

  testWidgets('Live calls → monitor; profile → book viewing → confirmed', (
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
        matching: find.text('Live calls'),
      ),
    );
    await tester.pump(loaded);

    await _tap(tester, find.text('Priyanka Reddy'));
    await tester.pumpAndSettle();
    expect(find.byType(LiveCallMonitorScreen), findsOneWidget);

    await _tap(tester, find.text('Open lead profile'));
    await tester.pumpAndSettle();
    await tester.pump(loaded);
    expect(find.byType(LeadProfileScreen), findsOneWidget);

    await _tap(tester, find.text('Book viewing'));
    await tester.pumpAndSettle();
    expect(find.byType(BookViewingScreen), findsOneWidget);
    await _tap(tester, find.text('Tomorrow'));
    final freeSlot = find.byWidgetPredicate(
      (widget) => widget is OutlinedButton && widget.onPressed != null,
    );
    await _tap(tester, freeSlot.first);
    await tester.pump(loaded);
    expect(find.textContaining('held for you'), findsOneWidget);

    await tester.tap(find.text('Confirm viewing'));
    await tester.pump(loaded);
    await tester.pumpAndSettle();

    expect(find.byType(BookViewingScreen), findsNothing);
    expect(find.textContaining('Viewing booked for Tomorrow'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/hot_leads/screens/hot_leads_screen.dart';
import 'package:mergro_ai_voice_assistant/features/leads/screens/leads_screen.dart';
import 'package:mergro_ai_voice_assistant/features/profile/screens/profile_screen.dart';

import 'dashboard_screens_test.dart' show loaded, pumpScreen;

void main() {
  testWidgets('lead search with no match offers Clear filters', (tester) async {
    var filterTaps = 0;
    await pumpScreen(tester, LeadsScreen(onOpenFilters: () => filterTaps++));
    await tester.pump(loaded);

    await tester.enterText(find.byType(TextField), 'Fatima');
    await tester.pump();
    expect(find.text('1 lead · newest first'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nobody-here');
    await tester.pump();
    expect(find.text('No leads match'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(find.text('Rohan Desai'), findsOneWidget);

    await tester.tap(find.byTooltip('Filters'));
    expect(filterTaps, 1);
  });

  testWidgets('accepting a hot lead updates the inbox', (tester) async {
    await pumpScreen(tester, const HotLeadsScreen());
    await tester.pump(loaded);
    expect(find.text('2 waiting · accept within 5 minutes'), findsOneWidget);

    final accept = find.text('Accept handoff').first;
    await tester.ensureVisible(accept);
    await tester.pumpAndSettle();
    await tester.tap(accept);
    await tester.pump();
    await tester.pump(loaded);
    // The count header is the first list item; scroll back up to it.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pumpAndSettle();

    expect(find.text('1 waiting · accept within 5 minutes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign out asks first, then calls back', (tester) async {
    var signOuts = 0;
    await pumpScreen(tester, ProfileScreen(onSignOut: () => signOuts++));
    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(signOuts, 0);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(signOuts, 1);
  });
}

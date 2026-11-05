import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/app/app_routes.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// Demo data delay plus a frame.
const Duration _loaded = Duration(milliseconds: 1100);

/// Pumps the signed-in app for [role].
Future<void> _pumpShell(
  WidgetTester tester,
  UserRole role, {
  Size size = smallPhone,
}) async {
  final container = fakeContainer();
  container.read(currentUserProvider.notifier).setUser(testUser(role));
  await pumpTestApp(tester, AppRoutes.home(), container: container, size: size);
  await tester.pump(_loaded);
}

/// Labels of the bottom-bar destinations.
List<String> _barLabels(WidgetTester tester) => tester
    .widgetList<NavigationDestination>(find.byType(NavigationDestination))
    .map((destination) => destination.label)
    .toList();

/// Taps the bottom-bar destination labelled [label].
Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
  );
  await tester.pump();
  await tester.pump(_loaded);
}

void main() {
  testWidgets('admin: dashboard, then Leads, Live calls, Hot leads, More', (
    tester,
  ) async {
    await _pumpShell(tester, UserRole.brokerageAdmin);

    expect(_barLabels(tester), [
      'Home',
      'Leads',
      'Live calls',
      'Hot leads',
      'More',
    ]);
    expect(find.text('Speed to lead · today (P95)'), findsOneWidget);
    expect(find.text('Hot leads waiting'), findsWidgets);

    await _tapTab(tester, 'Leads');
    expect(find.text('Search leads'), findsOneWidget);

    await _tapTab(tester, 'Live calls');
    expect(find.text('In progress (3)'), findsOneWidget);

    await _tapTab(tester, 'Hot leads');
    expect(find.text('Hot lead inbox'), findsOneWidget);

    await _tapTab(tester, 'More');
    expect(find.text('Nurture'), findsOneWidget);
    await tester.tap(find.text('Viewings'));
    await tester.pumpAndSettle(_loaded);
    expect(find.byType(BackButton), findsOneWidget, reason: 'pushed screen');
    expect(tester.takeException(), isNull);
  });

  testWidgets('agent: hot leads and viewings in the bar, calls under More', (
    tester,
  ) async {
    await _pumpShell(tester, UserRole.salesAgent);
    expect(_barLabels(tester), [
      'Home',
      'Hot leads',
      'Leads',
      'Viewings',
      'More',
    ]);
    await _tapTab(tester, 'More');
    expect(find.text('Live calls'), findsOneWidget);
  });

  testWidgets('"See all" on the dashboard switches tabs', (tester) async {
    await _pumpShell(tester, UserRole.brokerageAdmin);
    final seeAll = find.bySemanticsLabel('See all: Live now');
    await tester.scrollUntilVisible(
      seeAll,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(seeAll);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pump(_loaded);
    expect(find.text('In progress (3)'), findsOneWidget);
  });

  testWidgets('tablets get a side rail instead of a bottom bar', (
    tester,
  ) async {
    await _pumpShell(tester, UserRole.teamLead, size: const Size(1000, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

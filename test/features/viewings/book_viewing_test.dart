import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/utils/clock.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/controllers/lead_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_insights.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_profile.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead.dart';
import 'package:mergro_ai_voice_assistant/features/viewings/controllers/book_viewing_controller.dart';
import 'package:mergro_ai_voice_assistant/features/viewings/controllers/viewings_controller.dart';
import 'package:mergro_ai_voice_assistant/features/viewings/widgets/slot_picker.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// A signed-in container with lead-02's profile loaded (booking starts
/// there) and its booking kept alive.
Future<ProviderContainer> _container() async {
  final container = fakeContainer();
  container
      .read(currentUserProvider.notifier)
      .setUser(testUser(UserRole.salesAgent));
  container.listen(leadProfileControllerProvider('lead-02'), (_, _) {});
  await container.read(leadProfileControllerProvider('lead-02').future);
  container.listen(bookViewingControllerProvider('lead-02'), (_, _) {});
  return container;
}

void main() {
  test('starts on today with listings for the lead and 7 days', () async {
    final container = await _container();
    final state = container.read(bookViewingControllerProvider('lead-02'));
    expect(state.properties, hasLength(3));
    expect(state.properties.first.address, contains('Koramangala'));
    expect(state.propertyId, state.properties.first.id);
    expect(state.days, hasLength(7));
    expect(state.heldSlot, isNull);
  });

  test(
    'taken slots cannot be held; free ones are held for 5 minutes',
    () async {
      final container = await _container();
      final controller = container.read(
        bookViewingControllerProvider('lead-02').notifier,
      );
      controller.selectDay(
        container.read(bookViewingControllerProvider('lead-02')).days[2],
      );
      final slots = container
          .read(bookViewingControllerProvider('lead-02'))
          .slots;

      final taken = slots.firstWhere((slot) => !slot.isAvailable);
      expect(await controller.holdSlot(taken.start), isFalse);

      final free = slots.firstWhere((slot) => slot.isAvailable);
      final before = DateTime.now();
      expect(await controller.holdSlot(free.start), isTrue);
      final state = container.read(bookViewingControllerProvider('lead-02'));
      expect(state.heldSlot, free.start);
      expect(
        state.holdUntil!.difference(before).inMinutes,
        inInclusiveRange(4, 5),
      );
    },
  );

  test(
    'confirm needs a hold, then books and updates profile and Viewings',
    () async {
      final container = await _container();
      container.listen(viewingsControllerProvider, (_, _) {});
      final viewingsBefore = (await container.read(
        viewingsControllerProvider.future,
      )).length;
      final controller = container.read(
        bookViewingControllerProvider('lead-02').notifier,
      );

      expect(await controller.confirm(), isA<LeadActionFailed>());

      controller.selectDay(
        container.read(bookViewingControllerProvider('lead-02')).days[1],
      );
      final free = container
          .read(bookViewingControllerProvider('lead-02'))
          .slots
          .firstWhere((slot) => slot.isAvailable);
      await controller.holdSlot(free.start);
      final outcome = await controller.confirm();

      expect(outcome, isA<LeadActionSucceeded>());
      expect(outcome.message, contains('Tomorrow'));
      final profile = container
          .read(leadProfileControllerProvider('lead-02'))
          .value!;
      expect(profile.lead.status, LeadStatus.viewingBooked);
      expect(profile.timeline.first.kind, TimelineKind.viewing);
      expect(
        container.read(viewingsControllerProvider).value!.length,
        viewingsBefore + 1,
      );
    },
  );

  /// Pumps a hold banner for a hold made at 16:00, viewed at [clock].
  Future<void> pumpHoldBanner(WidgetTester tester, DateTime clock) async {
    final heldAt = DateTime(2026, 11, 5, 16);
    await pumpTestApp(
      tester,
      Scaffold(
        body: HoldBanner(
          slot: DateTime(2026, 11, 7, 11),
          holdUntil: heldAt.add(const Duration(minutes: 5)),
        ),
      ),
      container: ProviderContainer.test(
        overrides: [clockProvider.overrideWith((ref) => Stream.value(clock))],
      ),
    );
    await tester.pump();
  }

  testWidgets('hold banner counts down', (tester) async {
    await pumpHoldBanner(tester, DateTime(2026, 11, 5, 16, 0, 30));
    expect(find.textContaining('4:30 left'), findsOneWidget);
  });

  testWidgets('hold banner says when the hold expired', (tester) async {
    await pumpHoldBanner(tester, DateTime(2026, 11, 5, 16, 6));
    expect(find.text('Hold expired'), findsOneWidget);
  });
}

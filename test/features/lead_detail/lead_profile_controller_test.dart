import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/controllers/lead_profile_controller.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_insights.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_profile.dart';
import 'package:mergro_ai_voice_assistant/features/leads/controllers/leads_controller.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead.dart';

import '../../helpers/fakes.dart';

/// A container with a signed-in admin and the profile of [leadId] loaded.
Future<ProviderContainer> _loaded(String leadId) async {
  final container = fakeContainer();
  container
      .read(currentUserProvider.notifier)
      .setUser(testUser(UserRole.brokerageAdmin));
  container.listen(leadProfileControllerProvider(leadId), (_, _) {});
  await container.read(leadProfileControllerProvider(leadId).future);
  return container;
}

void main() {
  LeadProfile profile(ProviderContainer c, String id) =>
      c.read(leadProfileControllerProvider(id)).value!;
  LeadProfileController controller(ProviderContainer c, String id) =>
      c.read(leadProfileControllerProvider(id).notifier);

  test('an unknown lead is a not-found error', () async {
    final container = fakeContainer();
    container.listen(leadProfileControllerProvider('nope'), (_, _) {});
    await expectLater(
      container.read(leadProfileControllerProvider('nope').future),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.notFound,
        ),
      ),
    );
  });

  test('call back runs once at a time and lands on the timeline', () async {
    final container = await _loaded('lead-02');
    final before = profile(container, 'lead-02').timeline.length;

    final future = controller(container, 'lead-02').requestCallBack();
    expect(profile(container, 'lead-02').busyAction, LeadAction.callBack);
    expect(
      await controller(container, 'lead-02').requestCallBack(),
      isA<LeadActionFailed>(),
      reason: 'busy',
    );
    final outcome = await future;

    expect(outcome, isA<LeadActionSucceeded>());
    expect(outcome.message, contains('Ananya'));
    final after = profile(container, 'lead-02');
    expect(after.timeline.length, before + 1);
    expect(after.timeline.first.kind, TimelineKind.call);
    expect(after.busyAction, isNull);
  });

  test('messages need text and consent on the channel', () async {
    final container = await _loaded('lead-04'); // MagicBricks: no WhatsApp
    final leadCtl = controller(container, 'lead-04');

    expect(
      await leadCtl.sendMessage(ConsentChannel.sms, '  '),
      isA<LeadActionFailed>(),
    );
    final refused = await leadCtl.sendMessage(ConsentChannel.whatsapp, 'Hi');
    expect(refused, isA<LeadActionFailed>());
    expect(refused.message, contains('WhatsApp'));

    final sent = await leadCtl.sendMessage(ConsentChannel.sms, 'Hi Fatima');
    expect(sent, isA<LeadActionSucceeded>());
    expect(profile(container, 'lead-04').timeline.first.detail, 'Hi Fatima');
    expect(sent.message, contains('recorded'));
  });

  test('withdrawing consent blocks that channel only', () async {
    final container = await _loaded('lead-02');
    await controller(container, 'lead-02').withdrawConsent(ConsentChannel.sms);
    final after = profile(container, 'lead-02');
    expect(after.canContact(ConsentChannel.sms), isFalse);
    expect(after.canContact(ConsentChannel.call), isTrue);
    expect(after.timeline.first.kind, TimelineKind.consent);
  });

  test('do-not-contact stops everything and updates the Leads list', () async {
    final container = await _loaded('lead-03');
    container.listen(leadsControllerProvider, (_, _) {});
    await container.read(leadsControllerProvider.future);

    final outcome = await controller(container, 'lead-03').markDoNotContact();

    expect(outcome, isA<LeadActionSucceeded>());
    final after = profile(container, 'lead-03');
    expect(after.isDoNotContact, isTrue);
    expect(after.consents.every((c) => !c.isGranted), isTrue);
    final listed = container
        .read(leadsControllerProvider)
        .value!
        .firstWhere((lead) => lead.id == 'lead-03');
    expect(listed.status, LeadStatus.suppressed);
    expect(
      await controller(container, 'lead-03').requestCallBack(),
      isA<LeadActionFailed>(),
    );
  });

  test(
    'a refused action keeps the profile and shows the server message',
    () async {
      final leads = FakeLeadsRepository();
      final container = fakeContainer(leads: leads);
      container.listen(leadProfileControllerProvider('lead-02'), (_, _) {});
      await container.read(leadProfileControllerProvider('lead-02').future);
      final before = profile(container, 'lead-02').timeline.length;
      leads.failNextAction = ApiException(
        ApiErrorKind.validation,
        message: "This lead hasn't agreed to calls.",
      );

      final outcome = await controller(container, 'lead-02').requestCallBack();

      expect(outcome, isA<LeadActionFailed>());
      expect(outcome.message, "This lead hasn't agreed to calls.");
      expect(profile(container, 'lead-02').timeline.length, before);
      expect(profile(container, 'lead-02').busyAction, isNull);
      expect(leads.actions, isEmpty);
    },
  );
}

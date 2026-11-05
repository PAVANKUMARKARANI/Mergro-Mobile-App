import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/validation/form_validators.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/crm_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/invite_team_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/onboarding_providers.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/controllers/phone_line_controller.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/shared/widgets/integration_card.dart';

import '../../helpers/fakes.dart';

void main() {
  test('CRM step is valid only once Zoho is connected', () async {
    final container = ProviderContainer.test();
    final crm = container.read(crmControllerProvider.notifier);
    bool isValid() =>
        container.read(stepValidProvider(OnboardingStepId.crmLeadSources));

    expect(isValid(), isFalse);
    final future = crm.connectZoho();
    expect(
      container.read(crmControllerProvider).zohoStatus,
      IntegrationStatus.connecting,
    );
    await future;
    expect(
      container.read(crmControllerProvider).zohoStatus,
      IntegrationStatus.connected,
    );
    expect(isValid(), isTrue);
  });

  test('phone line needs provider, verified number and consent', () async {
    final container = ProviderContainer.test();
    final phone = container.read(phoneLineControllerProvider.notifier)
      ..selectProvider(TelephonyProvider.exotel)
      ..setNumberSource(NumberSource.existing)
      ..setConsent(true);
    bool isValid() =>
        container.read(stepValidProvider(OnboardingStepId.phoneLine));

    expect(isValid(), isFalse);
    phone.updateExistingNumber('123');
    expect(await phone.sendVerificationCode(), isFalse);
    expect(
      container.read(phoneLineControllerProvider).existingNumberError,
      ValidationMessages.phoneInvalid,
    );

    phone.updateExistingNumber('+91 98765 43210');
    expect(await phone.sendVerificationCode(), isTrue);
    expect(await phone.verifyCode('12'), ValidationMessages.otpInvalid);
    expect(await phone.verifyCode('482913'), isNull);
    expect(isValid(), isTrue);

    phone.updateExistingNumber('+91 98765 43211');
    expect(isValid(), isFalse, reason: 'editing the number un-verifies it');
  });

  test('invites reject bad and duplicate emails, then send', () async {
    final server = FakeOnboardingRepository();
    final container = fakeContainer(onboarding: server);
    final invites = container.read(inviteTeamControllerProvider.notifier);

    expect(invites.addInvite('nope'), ValidationMessages.emailInvalid);
    expect(invites.addInvite('Arjun@Skyline.in'), isNull);
    expect(
      invites.addInvite('arjun@skyline.in'),
      InviteTeamController.duplicateMessage,
    );
    expect(await invites.sendInvites(), isA<StepActionSucceeded>());
    final draft = container.read(inviteTeamControllerProvider);
    expect(draft.sentCount, 1);
    expect(draft.invites, isEmpty, reason: 'sent invites leave the list');
    expect(draft.isValid, isTrue, reason: 'Continue still works after sending');
    expect(server.sentInvites.single.role, UserRole.salesAgent);
  });

  test('failed invites stay listed with the server reason', () async {
    final server = FakeOnboardingRepository()
      ..inviteFailures = {
        'neha@skyline.in': 'This email already has an account.',
      };
    final container = fakeContainer(onboarding: server);
    final invites = container.read(inviteTeamControllerProvider.notifier)
      ..addInvite('arjun@skyline.in')
      ..addInvite('neha@skyline.in');

    final outcome = await invites.sendInvites();

    expect(outcome, isA<StepActionFailed>());
    final draft = container.read(inviteTeamControllerProvider);
    expect(draft.sentCount, 1);
    expect(draft.invites.single.email, 'neha@skyline.in');
    expect(draft.errorMessage, contains('already has an account'));

    invites.removeInvite('neha@skyline.in');
    expect(container.read(inviteTeamControllerProvider).errorMessage, isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/agent_profile_drafts.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/agent_setup_drafts.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/draft_json.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_options.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_progress.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/phone_line_draft.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/setup_drafts.dart';

void main() {
  test('brokerage profile uses enum names and HH:mm, and round-trips', () {
    const draft = BrokerageProfileDraft(
      brokerageName: ' Skyline Realty ',
      country: Country.india,
      timeZone: 'Asia/Kolkata',
      opensAt: TimeOfDay(hour: 9, minute: 5),
      closesAt: TimeOfDay(hour: 19, minute: 0),
    );
    final json = draft.toJson();
    expect(json['brokerageName'], 'Skyline Realty');
    expect(json['country'], 'india');
    expect(json['opensAt'], '09:05');

    final restored = BrokerageProfileJson.fromJson(json);
    expect(restored.country, Country.india);
    expect(restored.opensAt, const TimeOfDay(hour: 9, minute: 5));
    expect(restored.isValid, isTrue);
  });

  test('calendar sends sorted days and restores them', () {
    const draft = CalendarDraft(days: {5, 1, 3});
    final json = draft.toJson();
    expect(json['days'], [1, 3, 5]);
    expect(CalendarJson.fromJson(json).days, {1, 3, 5});
  });

  test('phone line sends whichever number is in use', () {
    const fresh = PhoneLineDraft(
      provider: TelephonyProvider.twilio,
      selectedNumber: '+91 80 4567 8901',
      consentConfirmed: true,
    );
    expect(fresh.toJson()['number'], '+91 80 4567 8901');

    const existing = PhoneLineDraft(
      provider: TelephonyProvider.exotel,
      numberSource: NumberSource.existing,
      existingNumber: ' +91 98765 43210 ',
      isVerified: true,
      consentConfirmed: true,
    );
    final json = existing.toJson();
    expect(json['number'], '+91 98765 43210');
    final restored = PhoneLineJson.fromJson(json);
    expect(restored.isValid, isTrue, reason: 'saved numbers were verified');
  });

  test('agent steps and AI agent round-trip', () {
    const profile = AgentProfileDraft(
      fullName: 'Arjun Mehta',
      mobileNumber: '+91 98765 43210',
      languages: {'English', 'Hindi'},
    );
    expect(AgentProfileJson.fromJson(profile.toJson()).languages, {
      'English',
      'Hindi',
    });

    const alerts = HotLeadAlertsDraft(pushEnabled: false);
    final restoredAlerts = HotLeadAlertsJson.fromJson(alerts.toJson());
    expect(restoredAlerts.pushEnabled, isFalse);
    expect(restoredAlerts.quietStart, alerts.quietStart);

    const agent = AiAgentDraft(agentName: 'Asha', voice: AgentVoice.calmMale);
    final restoredAgent = AiAgentJson.fromJson(agent.toJson());
    expect(restoredAgent.voice, AgentVoice.calmMale);
    expect(restoredAgent.agentName, 'Asha');
  });

  test('malformed saved values fall back to defaults', () {
    final restored = BrokerageProfileJson.fromJson({
      'country': 'atlantis',
      'opensAt': '25:99',
    });
    expect(restored.country, isNull);
    expect(restored.opensAt, const BrokerageProfileDraft().opensAt);
  });

  test('progress and invite results parse the API responses', () {
    final progress = OnboardingProgress.fromJson({
      'completedSteps': ['agentProfile', 'notAStep'],
      'skippedSteps': ['agentCalendar'],
      'drafts': {
        'agentProfile': {'fullName': 'Arjun'},
      },
      'onboardingCompleted': false,
    });
    expect(progress.completedSteps, {OnboardingStepId.agentProfile});
    expect(progress.skippedSteps, {OnboardingStepId.agentCalendar});
    expect(progress.drafts.keys, [OnboardingStepId.agentProfile]);

    final invites = InviteResult.fromJson({
      'results': [
        {'email': 'a@x.in', 'status': 'invited'},
        {'email': 'b@x.in', 'status': 'failed', 'reason': 'Exists.'},
      ],
    });
    expect(invites.sentEmails, {'a@x.in'});
    expect(invites.failures, {'b@x.in': 'Exists.'});
  });
}

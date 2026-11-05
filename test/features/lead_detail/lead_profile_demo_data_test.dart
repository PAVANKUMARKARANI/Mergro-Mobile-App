import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/lead_profile_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/lead_detail/models/lead_profile.dart';
import 'package:mergro_ai_voice_assistant/features/leads/leads_demo_data.dart';
import 'package:mergro_ai_voice_assistant/features/leads/models/lead.dart';

void main() {
  final now = DateTime(2026, 11, 5, 16);
  final leads = LeadsDemoData.leads(now);
  LeadProfile profileOf(String id) => LeadProfileDemoData.profileFor(
    leads.firstWhere((lead) => lead.id == id),
    now,
  );

  test('score reasons always add up to the lead score', () {
    for (final lead in leads.where((lead) => lead.score != null)) {
      final profile = LeadProfileDemoData.profileFor(lead, now);
      final total = profile.scoreReasons.fold<int>(
        LeadProfile.baseScore,
        (sum, reason) => sum + reason.points,
      );
      expect(total, lead.score, reason: lead.name);
    }
  });

  test('before the first call: no reasons, nothing answered, no calls', () {
    final profile = profileOf('lead-01');
    expect(profile.lead.score, isNull);
    expect(profile.scoreReasons, isEmpty);
    expect(profile.qualification.every((f) => !f.isAnswered), isTrue);
    expect(profile.calls, isEmpty);
  });

  test('a hot lead has confident answers and a qualified call', () {
    final profile = profileOf('lead-02');
    expect(profile.qualification.every((f) => f.isAnswered), isTrue);
    expect(profile.qualification.first.confidence, greaterThan(0.75));
    expect(profile.calls.single.outcome, CallOutcome.qualified);
  });

  test('a suppressed lead has every channel withdrawn', () {
    final profile = profileOf('lead-09');
    expect(profile.lead.status, LeadStatus.suppressed);
    expect(profile.isDoNotContact, isTrue);
    expect(profile.consents.every((c) => !c.isGranted), isTrue);
    expect(profile.canContact(ConsentChannel.call), isFalse);
    expect(profile.calls.single.outcome, CallOutcome.optedOut);
  });

  test('consent follows the source', () {
    final portal = profileOf('lead-04'); // MagicBricks
    expect(portal.canContact(ConsentChannel.sms), isTrue);
    expect(portal.canContact(ConsentChannel.whatsapp), isFalse);
    final social = profileOf('lead-02'); // Facebook
    expect(social.canContact(ConsentChannel.whatsapp), isTrue);
  });

  test('timeline is newest first and never in the future', () {
    for (final lead in leads) {
      final events = LeadProfileDemoData.profileFor(lead, now).timeline;
      for (var i = 1; i < events.length; i++) {
        expect(events[i - 1].at.isBefore(events[i].at), isFalse);
      }
      expect(events.every((event) => !event.at.isAfter(now)), isTrue);
    }
  });
}

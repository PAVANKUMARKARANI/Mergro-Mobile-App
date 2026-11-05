import '../leads/models/lead.dart';
import 'lead_activity_demo_data.dart';
import 'models/lead_insights.dart';
import 'models/lead_profile.dart';

/// Builds a sample profile for any demo lead until `GET /api/leads/:id`
/// exists. Everything derives from the lead, so it matches the Leads list.
abstract final class LeadProfileDemoData {
  /// Score reasons per band (before the balancing "other signals" line).
  static const Map<LeadTemperature, List<ScoreReason>> _reasons = {
    LeadTemperature.hot: [
      ScoreReason(
        code: 'BUDGET_FIT',
        label: 'Budget fits homes in the area',
        points: 15,
      ),
      ScoreReason(
        code: 'TIMELINE_SOON',
        label: 'Wants to move within 90 days',
        points: 12,
      ),
      ScoreReason(
        code: 'PRE_APPROVED',
        label: 'Home loan pre-approved',
        points: 10,
      ),
    ],
    LeadTemperature.warm: [
      ScoreReason(
        code: 'BUDGET_FIT',
        label: 'Budget fits homes in the area',
        points: 10,
      ),
      ScoreReason(
        code: 'TIMELINE_LATER',
        label: 'Moving in 6–12 months',
        points: -5,
      ),
      ScoreReason(
        code: 'NO_PRE_APPROVAL',
        label: 'Loan not pre-approved yet',
        points: -4,
      ),
    ],
    LeadTemperature.cold: [
      ScoreReason(
        code: 'BUDGET_LOW',
        label: 'Budget below listings in the area',
        points: -10,
      ),
      ScoreReason(
        code: 'TIMELINE_UNSURE',
        label: 'No moving date yet',
        points: -8,
      ),
      ScoreReason(
        code: 'LOW_ENGAGEMENT',
        label: 'Short answers on the call',
        points: -6,
      ),
    ],
  };

  /// Timeline, pre-approval and confidence per band.
  static const Map<LeadTemperature, (String, String, double)> _answers = {
    LeadTemperature.hot: ('Within 3 months', 'Pre-approved', 0.9),
    LeadTemperature.warm: ('6–12 months', 'Applying', 0.72),
    LeadTemperature.cold: ('Not sure yet', 'Not started', 0.5),
  };

  /// The full profile of [lead] as of [now].
  static LeadProfile profileFor(Lead lead, DateTime now) {
    return LeadProfile(
      lead: lead,
      email: _emailOf(lead.name),
      qualification: qualificationFor(lead),
      scoreReasons: scoreReasonsFor(lead),
      timeline: LeadActivityDemoData.timelineFor(lead, now),
      consents: consentsFor(lead),
      calls: LeadActivityDemoData.callsFor(lead),
    );
  }

  /// Answers captured on the AI call; all unanswered before the first call.
  static List<QualificationField> qualificationFor(Lead lead) {
    final band = lead.temperature;
    if (band == null) {
      return [
        for (final key in QualificationKey.values) QualificationField(key: key),
      ];
    }
    final (timeline, preApproval, confidence) = _answers[band]!;
    return [
      QualificationField(
        key: QualificationKey.budget,
        value: lead.budget,
        confidence: confidence,
      ),
      QualificationField(
        key: QualificationKey.area,
        value: lead.area,
        confidence: 0.95,
      ),
      QualificationField(
        key: QualificationKey.timeline,
        value: timeline,
        confidence: confidence - 0.05,
      ),
      QualificationField(
        key: QualificationKey.propertyType,
        value: lead.propertyType,
        confidence: 0.9,
      ),
      QualificationField(
        key: QualificationKey.preApproval,
        value: preApproval,
        confidence: confidence - 0.1,
      ),
    ];
  }

  /// Reasons whose points plus [LeadProfile.baseScore] equal the score.
  static List<ScoreReason> scoreReasonsFor(Lead lead) {
    final score = lead.score;
    final band = lead.temperature;
    if (score == null || band == null) return const [];
    final reasons = _reasons[band]!;
    final total =
        LeadProfile.baseScore +
        reasons.fold<int>(0, (sum, reason) => sum + reason.points);
    final rest = score - total;
    return [
      ...reasons,
      if (rest != 0)
        ScoreReason(
          code: 'OTHER_SIGNALS',
          label: 'Other call signals',
          points: rest,
        ),
    ];
  }

  /// Consent per channel, with evidence; all withdrawn for suppressed leads.
  static List<ChannelConsent> consentsFor(Lead lead) {
    final form = '${lead.source.label} enquiry form';
    if (lead.status == LeadStatus.suppressed) {
      final at = lead.createdAt.add(const Duration(minutes: 3));
      return [
        for (final channel in ConsentChannel.values)
          ChannelConsent(
            channel: channel,
            isGranted: false,
            evidence: 'Opted out on the AI call',
            recordedAt: at,
          ),
      ];
    }
    const chatSources = {
      LeadSource.facebook,
      LeadSource.website,
      LeadSource.googleAds,
    };
    const emailSources = {
      LeadSource.website,
      LeadSource.googleAds,
      LeadSource.housing,
    };
    ChannelConsent consent(ConsentChannel channel, bool granted) =>
        ChannelConsent(
          channel: channel,
          isGranted: granted,
          evidence: granted ? form : 'Not asked on the form',
          recordedAt: lead.createdAt,
        );
    return [
      consent(ConsentChannel.call, true),
      consent(ConsentChannel.sms, true),
      consent(ConsentChannel.whatsapp, chatSources.contains(lead.source)),
      consent(ConsentChannel.email, emailSources.contains(lead.source)),
    ];
  }

  /// "first.last@gmail.com" from the lead's name.
  static String _emailOf(String name) =>
      '${name.toLowerCase().trim().split(RegExp(r'\s+')).join('.')}@gmail.com';
}

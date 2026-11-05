import '../lead_detail/models/lead_insights.dart';
import '../lead_detail/models/lead_profile.dart';
import '../leads/models/lead.dart';
import 'models/call_transcript.dart';
import 'models/live_call.dart';

/// A sample AI call script for any lead, until call transcripts come from
/// `GET /api/calls/:id/transcript` and socket.io `call:transcript` events.
abstract final class CallScriptDemoData {
  /// Time after the last line at which the call ends.
  static const Duration endsAt = Duration(seconds: 290);

  /// The full call, line by line, built from the lead's details.
  static List<TranscriptLine> scriptFor(Lead lead) {
    final first = lead.name.split(' ').first;
    // "Row house" reads as "a row house" mid-sentence; "3 BHK …" stays.
    final type = RegExp(r'^[A-Z][a-z]').hasMatch(lead.propertyType)
        ? lead.propertyType[0].toLowerCase() + lead.propertyType.substring(1)
        : lead.propertyType;
    final email = '${lead.name.toLowerCase().split(' ').join('.')}@gmail.com';
    TranscriptLine line(
      int seconds,
      Speaker speaker,
      String text,
      CallStage stage, [
      QualificationKey? key,
      String? value,
    ]) => TranscriptLine(
      offset: Duration(seconds: seconds),
      speaker: speaker,
      text: text,
      stage: stage,
      captured: key == null
          ? null
          : QualificationField(key: key, value: value, confidence: 0.9),
    );
    const ai = Speaker.ai;
    const you = Speaker.lead;
    const intro = CallStage.disclosure;
    const ask = CallStage.qualifying;
    return [
      line(
        0,
        ai,
        'Hi $first, this is Maya, an AI assistant from Skyline Realty, '
        'calling about your ${lead.source.label} enquiry. This call is '
        'recorded. Is now a good time?',
        intro,
      ),
      line(10, you, 'Yes, go ahead.', intro),
      line(20, ai, 'Great. What budget do you have in mind?', ask),
      line(
        35,
        you,
        'Around ${lead.budget}.',
        ask,
        QualificationKey.budget,
        lead.budget,
      ),
      line(50, ai, 'And which area are you looking at?', ask),
      line(
        62,
        you,
        '${lead.area}, ideally close to work.',
        ask,
        QualificationKey.area,
        lead.area,
      ),
      line(80, ai, 'When are you hoping to move?', ask),
      line(
        95,
        you,
        'Within three months.',
        ask,
        QualificationKey.timeline,
        'Within 3 months',
      ),
      line(110, ai, 'Are you looking for a $type?', ask),
      line(
        125,
        you,
        'Yes, a $type.',
        ask,
        QualificationKey.propertyType,
        lead.propertyType,
      ),
      line(145, ai, 'Is your home loan pre-approved?', ask),
      line(
        165,
        you,
        'Yes, from HDFC. Call me on ${lead.phone} or mail $email.',
        ask,
        QualificationKey.preApproval,
        'Pre-approved',
      ),
      line(
        235,
        ai,
        'I have Saturday at 11 AM or 4 PM for a viewing. Which suits you?',
        CallStage.booking,
      ),
      line(250, you, 'Saturday at 11 works.', CallStage.booking),
      line(
        270,
        ai,
        'Booked for Saturday at 11 AM. You will get an SMS confirmation. '
        'Thank you, $first!',
        CallStage.wrapUp,
      ),
    ];
  }

  /// The part of the script a finished call with [outcome] reached.
  static List<TranscriptLine> transcriptFor(Lead lead, CallOutcome outcome) {
    final script = scriptFor(lead);
    return switch (outcome) {
      CallOutcome.qualified => script,
      CallOutcome.noAnswer => const [],
      CallOutcome.callbackRequested => [
        script.first,
        const TranscriptLine(
          offset: Duration(seconds: 10),
          speaker: Speaker.lead,
          text: "I'm driving. Can you call me back this evening?",
          stage: CallStage.disclosure,
        ),
      ],
      CallOutcome.optedOut => [
        script.first,
        const TranscriptLine(
          offset: Duration(seconds: 10),
          speaker: Speaker.lead,
          text: "Please don't call me again.",
          stage: CallStage.disclosure,
        ),
      ],
    };
  }

  /// The AI's summary and next step for a call with [outcome].
  static (String, String) summaryFor(Lead lead, CallOutcome outcome) {
    final first = lead.name.split(' ').first;
    return switch (outcome) {
      CallOutcome.qualified => (
        '$first wants a ${lead.propertyType} in ${lead.area} for '
            '${lead.budget}, plans to move within three months and has a '
            'pre-approved loan.',
        'Confirm the viewing and share two similar listings.',
      ),
      CallOutcome.noAnswer => (
        'No one answered. An SMS with a call-back link was sent.',
        'The AI tries again in the next calling window.',
      ),
      CallOutcome.callbackRequested => (
        '$first was busy and asked to be called back in the evening.',
        'The AI calls back after 6 PM today.',
      ),
      CallOutcome.optedOut => (
        '$first asked not to be contacted again. All channels were stopped.',
        'None. The lead is on the suppression list.',
      ),
    };
  }
}

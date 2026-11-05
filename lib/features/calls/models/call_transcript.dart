import 'package:flutter/foundation.dart';

import '../../lead_detail/models/lead_insights.dart';
import '../../lead_detail/models/lead_profile.dart';
import 'live_call.dart';

/// Who said a transcript line.
enum Speaker {
  /// The AI voice agent.
  ai('AI'),

  /// The lead.
  lead('Lead');

  /// Creates a speaker with its label.
  const Speaker(this.label);

  /// Display label.
  final String label;
}

/// One line of a call transcript, at [offset] from the start of the call.
@immutable
class TranscriptLine {
  /// Creates a line.
  const TranscriptLine({
    required this.offset,
    required this.speaker,
    required this.text,
    required this.stage,
    this.captured,
  });

  /// Time from call start.
  final Duration offset;

  /// Who spoke.
  final Speaker speaker;

  /// What was said (unmasked; screens mask personal data).
  final String text;

  /// Script stage this line belongs to.
  final CallStage stage;

  /// Answer the AI captured from this line, if any.
  final QualificationField? captured;
}

/// A finished call (screen 14) with its transcript (screen 15).
@immutable
class CallDetail {
  /// Creates a call detail.
  const CallDetail({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.startedAt,
    required this.duration,
    required this.outcome,
    required this.summary,
    required this.nextStep,
    required this.qualification,
    required this.transcript,
    this.score,
  });

  /// Call id.
  final String id;

  /// The lead called.
  final String leadId;

  /// The lead's name.
  final String leadName;

  /// When it started.
  final DateTime startedAt;

  /// How long it lasted (zero when unanswered).
  final Duration duration;

  /// How it ended.
  final CallOutcome outcome;

  /// AI summary of the call.
  final String summary;

  /// Suggested next step.
  final String nextStep;

  /// Answers captured on this call.
  final List<QualificationField> qualification;

  /// Score after the call, if one was given.
  final int? score;

  /// Lines in order; empty when nobody answered.
  final List<TranscriptLine> transcript;
}

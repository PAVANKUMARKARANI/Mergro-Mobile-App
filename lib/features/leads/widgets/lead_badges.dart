import '../../../shared/ui.dart';
import '../models/lead.dart';

/// Colour tone per score band (red hot, amber warm, grey cold).
extension LeadTemperatureTone on LeadTemperature {
  /// Tone for chips and accents.
  StatusTone get tone => switch (this) {
    LeadTemperature.hot => StatusTone.error,
    LeadTemperature.warm => StatusTone.warning,
    LeadTemperature.cold => StatusTone.neutral,
  };
}

/// Colour tone per pipeline status.
extension LeadStatusTone on LeadStatus {
  /// Tone for the status chip.
  StatusTone get tone => switch (this) {
    LeadStatus.newLead || LeadStatus.calling => StatusTone.info,
    LeadStatus.qualified ||
    LeadStatus.viewingBooked ||
    LeadStatus.withAgent => StatusTone.success,
    LeadStatus.nurturing => StatusTone.neutral,
    LeadStatus.suppressed => StatusTone.error,
  };
}

/// "Hot · 91" chip, or "Not scored" before the first call ends.
class LeadScoreChip extends StatelessWidget {
  /// Creates the chip for [lead].
  const LeadScoreChip({super.key, required this.lead});

  /// The lead whose score is shown.
  final Lead lead;

  /// Builds the chip.
  @override
  Widget build(BuildContext context) {
    final temperature = lead.temperature;
    if (temperature == null) {
      return const StatusChip(label: 'Not scored', tone: StatusTone.info);
    }
    return StatusChip(
      label: '${temperature.label} · ${lead.score}',
      tone: temperature.tone,
      icon: temperature == LeadTemperature.hot ? LucideIcons.flame : null,
    );
  }
}

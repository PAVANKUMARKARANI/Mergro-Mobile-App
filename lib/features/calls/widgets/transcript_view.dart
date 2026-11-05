import '../../../core/utils/pii_mask.dart';
import '../../../shared/ui.dart';
import '../models/call_transcript.dart';
import '../models/live_call.dart';

/// Transcript lines as chat bubbles: AI on the left, the lead on the right.
/// Phone numbers and emails are masked.
class TranscriptView extends StatelessWidget {
  /// Creates the view.
  const TranscriptView({super.key, required this.lines});

  /// Lines, oldest first.
  final List<TranscriptLine> lines;

  /// Builds the bubbles.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in lines) ...[
          _Bubble(line: line),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

/// One line: speaker, time and masked text.
class _Bubble extends StatelessWidget {
  /// Creates the bubble.
  const _Bubble({required this.line});

  /// The line shown.
  final TranscriptLine line;

  /// Widest a bubble may be, as a share of the row.
  static const double widthFactor = 0.85;

  /// Builds the bubble.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final isAi = line.speaker == Speaker.ai;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isAi ? palette.violetContainer : palette.surface,
            borderRadius: AppRadius.cardAll,
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${line.speaker.label} · ${TimeFormat.stopwatch(line.offset)}',
                style: text.labelSmall?.copyWith(
                  color: isAi ? palette.violet : palette.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(PiiMask.mask(line.text), style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// The call's script stages with the current one highlighted.
class CallStageTracker extends StatelessWidget {
  /// Creates the tracker.
  const CallStageTracker({
    super.key,
    required this.stage,
    this.isEnded = false,
  });

  /// Current stage.
  final CallStage stage;

  /// Marks every stage done.
  final bool isEnded;

  /// Builds the tracker.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isEnded ? 'Call ended' : 'Stage: ${stage.label}',
      excludeSemantics: true,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final item in CallStage.values)
            StatusChip(
              label: item.label,
              tone: isEnded || item.index < stage.index
                  ? StatusTone.success
                  : item == stage
                  ? StatusTone.info
                  : StatusTone.neutral,
              icon: isEnded || item.index < stage.index
                  ? LucideIcons.check
                  : null,
            ),
        ],
      ),
    );
  }
}

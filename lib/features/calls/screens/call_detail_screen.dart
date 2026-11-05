import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../lead_detail/widgets/call_history_card.dart';
import '../../lead_detail/widgets/qualification_card.dart';
import '../../leads/models/lead.dart';
import '../../leads/widgets/lead_badges.dart';
import '../controllers/call_providers.dart';
import '../models/call_transcript.dart';

/// Screen 14: a finished call — outcome, AI summary, next step, answers,
/// score — with a link to its transcript (screen 15).
class CallDetailScreen extends ConsumerWidget {
  /// Creates the screen for [callId].
  const CallDetailScreen({
    super.key,
    required this.callId,
    required this.onOpenTranscript,
  });

  /// The call shown.
  final String callId;

  /// Opens the transcript (wired by AppRoutes).
  final VoidCallback onOpenTranscript;

  /// Builds the screen.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(callDetailProvider(callId));
    return Scaffold(
      appBar: AppBar(title: const Text('Call detail')),
      body: AsyncValueView<CallDetail>(
        value: detail,
        onRetry: () => ref.invalidate(callDetailProvider(callId)),
        builder: (data) =>
            _DetailBody(detail: data, onOpenTranscript: onOpenTranscript),
      ),
    );
  }
}

/// The loaded call's sections.
class _DetailBody extends StatelessWidget {
  /// Creates the body.
  const _DetailBody({required this.detail, required this.onOpenTranscript});

  /// The call.
  final CallDetail detail;

  /// Opens the transcript.
  final VoidCallback onOpenTranscript;

  /// Builds the sections.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final now = DateTime.now();
    final score = detail.score;
    final hasTranscript = detail.transcript.isNotEmpty;
    final when =
        '${TimeFormat.day(detail.startedAt, now)}, '
        '${TimeFormat.clock(detail.startedAt)}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI call with ${detail.leadName}', style: text.titleMedium),
              Text(
                detail.duration == Duration.zero
                    ? when
                    : '$when · ${TimeFormat.stopwatch(detail.duration)}',
                style: text.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  StatusChip(
                    label: detail.outcome.label,
                    tone: CallHistoryCard.toneOf(detail.outcome),
                  ),
                  if (score != null)
                    StatusChip(
                      label:
                          'Score $score · '
                          '${LeadTemperature.fromScore(score).label}',
                      tone: LeadTemperature.fromScore(score).tone,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'AI summary'),
        const SizedBox(height: AppSpacing.xs),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.summary, style: text.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    size: AppSizes.iconSm,
                    color: context.palette.violet,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Next: ${detail.nextStep}',
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Qualification'),
        const SizedBox(height: AppSpacing.xs),
        QualificationCard(fields: detail.qualification),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: hasTranscript
              ? 'Read transcript (${detail.transcript.length} lines)'
              : 'No transcript: nobody answered',
          variant: AppButtonVariant.secondary,
          leading: const Icon(LucideIcons.audioLines, size: AppSizes.iconMd),
          onPressed: hasTranscript ? onOpenTranscript : null,
        ),
      ],
    );
  }
}

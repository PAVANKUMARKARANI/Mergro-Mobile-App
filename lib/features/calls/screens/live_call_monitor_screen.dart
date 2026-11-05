import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../lead_detail/widgets/qualification_card.dart';
import '../call_script_demo_data.dart';
import '../calls_demo_data.dart';
import '../controllers/call_providers.dart';
import '../controllers/live_calls_controller.dart';
import '../widgets/live_call_tiles.dart';
import '../widgets/transcript_view.dart';

/// Screen 12: one AI call as it happens — stage, timer, reply latency,
/// answers filling in and the streaming transcript.
class LiveCallMonitorScreen extends ConsumerWidget {
  /// Creates the monitor for [callId].
  const LiveCallMonitorScreen({
    super.key,
    required this.callId,
    required this.onOpenLead,
  });

  /// The call watched.
  final String callId;

  /// Opens the lead's profile by id.
  final ValueChanged<String> onOpenLead;

  /// Builds the monitor.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitor = ref.watch(liveCallMonitorProvider(callId));
    final text = context.textStyles;
    return Scaffold(
      appBar: AppBar(title: Text(monitor.value?.call.leadName ?? 'Live call')),
      body: AsyncValueView<LiveCallMonitor>(
        value: monitor,
        onRetry: ref.read(liveCallsControllerProvider.notifier).refresh,
        builder: (data) {
          final call = data.call;
          final isFast = call.replyLatencyMs < CallsDemoData.naturalLatencyMs;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              SurfaceCard(
                accentColor: data.isEnded ? null : context.palette.accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${call.source.label} · ${call.area}',
                            style: text.bodySmall,
                          ),
                        ),
                        StatusChip(
                          label: data.isEnded ? 'Ended' : 'Live',
                          tone: data.isEnded
                              ? StatusTone.neutral
                              : StatusTone.success,
                          icon: data.isEnded ? null : LucideIcons.audioLines,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (data.isEnded)
                      Text(
                        TimeFormat.stopwatch(CallScriptDemoData.endsAt),
                        style: text.displaySmall,
                      )
                    else
                      ElapsedTimeText(
                        since: call.startedAt,
                        style: text.displaySmall,
                      ),
                    Text(
                      'AI reply ${call.replyLatencyMs} ms · '
                      '${isFast ? 'sounds natural' : 'slower than target'}',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CallStageTracker(stage: data.stage, isEnded: data.isEnded),
                  ],
                ),
              ),
              if (data.isEnded) ...[
                const SizedBox(height: AppSpacing.sm),
                const InfoBanner(
                  type: InfoBannerType.success,
                  title: 'Call ended',
                  message: 'The summary and score are on the lead profile.',
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Captured so far'),
              const SizedBox(height: AppSpacing.xs),
              QualificationCard(fields: data.qualification),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Live transcript',
                subtitle: 'Phone numbers and emails are masked.',
                trailing: Text(
                  '${data.lines.length} lines',
                  style: text.labelSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TranscriptView(lines: data.lines),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Open lead profile',
                variant: AppButtonVariant.secondary,
                leading: const Icon(
                  LucideIcons.userRound,
                  size: AppSizes.iconMd,
                ),
                onPressed: () => onOpenLead(call.leadId),
              ),
              const SizedBox(height: AppSpacing.xs),
              // TODO(backend): take over / warm transfer needs the telephony
              // integration (Twilio / Exotel) — POST /api/calls/{id}/transfer.
              Text(
                'Taking over or warm-transferring the call arrives with the '
                'telephony integration.',
                textAlign: TextAlign.center,
                style: text.labelSmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

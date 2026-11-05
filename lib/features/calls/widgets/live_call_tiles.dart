import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../shared/ui.dart';
import '../calls_demo_data.dart';
import '../models/live_call.dart';

/// Ticking "1:36" since [since]; only this text rebuilds each second.
class ElapsedTimeText extends ConsumerWidget {
  /// Creates the timer text.
  const ElapsedTimeText({super.key, required this.since, this.style});

  /// Start time.
  final DateTime since;

  /// Text style.
  final TextStyle? style;

  /// Builds the elapsed time.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    return Text(TimeFormat.stopwatch(now.difference(since)), style: style);
  }
}

/// A call in progress: lead, stage, timer, latest line and AI latency.
class LiveCallTile extends StatelessWidget {
  /// Creates the tile.
  const LiveCallTile({super.key, required this.call});

  /// The call shown.
  final LiveCall call;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final isFast = call.replyLatencyMs < CallsDemoData.naturalLatencyMs;
    return SurfaceCard(
      accentColor: palette.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.audioLines, color: palette.accent),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  call.leadName,
                  style: text.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElapsedTimeText(
                since: call.startedAt,
                style: AppTypography.mono(palette.textPrimary),
              ),
            ],
          ),
          Text('${call.source.label} · ${call.area}', style: text.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            call.lastLine,
            style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              StatusChip(label: call.stage.label, tone: StatusTone.info),
              StatusChip(
                label: 'AI reply ${call.replyLatencyMs} ms',
                tone: isFast ? StatusTone.success : StatusTone.warning,
                icon: LucideIcons.timer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A lead waiting in the dial queue.
class QueuedCallTile extends StatelessWidget {
  /// Creates the tile.
  const QueuedCallTile({super.key, required this.entry, required this.now});

  /// The queue entry shown.
  final QueuedCall entry;

  /// Current time, for the due label.
  final DateTime now;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final due = TimeFormat.isSameDay(entry.dueAt, now)
        ? TimeFormat.clock(entry.dueAt)
        : '${TimeFormat.day(entry.dueAt, now)}, ${TimeFormat.clock(entry.dueAt)}';
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          InitialsAvatar(name: entry.leadName, tone: StatusTone.neutral),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.leadName, style: text.titleSmall),
                Text(
                  '${entry.reason.label} · $due',
                  style: text.bodySmall,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Icon(
            entry.reason == QueueReason.dialingNext
                ? LucideIcons.phoneOutgoing
                : LucideIcons.clock,
            size: AppSizes.iconMd,
            color: context.palette.textSecondary,
          ),
        ],
      ),
    );
  }
}

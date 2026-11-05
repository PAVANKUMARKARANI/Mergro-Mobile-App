import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../shared/ui.dart';
import '../models/handoff.dart';

/// Ticking "Accept in 3:12" / "Overdue 0:45" chip for a waiting handoff.
class SlaCountdownChip extends ConsumerWidget {
  /// Creates the chip.
  const SlaCountdownChip({super.key, required this.dueAt});

  /// Accept-by deadline.
  final DateTime dueAt;

  /// Builds the countdown; red in the last minute and when overdue.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).value ?? DateTime.now();
    final left = dueAt.difference(now);
    final isOverdue = left.isNegative;
    return StatusChip(
      label: isOverdue
          ? 'Overdue ${TimeFormat.stopwatch(-left)}'
          : 'Accept in ${TimeFormat.stopwatch(left)}',
      tone: left.inSeconds < 60 ? StatusTone.error : StatusTone.warning,
      icon: LucideIcons.timer,
    );
  }
}

/// Screen 7 card: lead, score, SLA, AI summary, reasons and Accept.
class HandoffCard extends StatelessWidget {
  /// Creates the card.
  const HandoffCard({
    super.key,
    required this.handoff,
    required this.onAccept,
    this.isCompact = false,
  });

  /// The handoff shown.
  final Handoff handoff;

  /// Accepts it; null hides the button.
  final VoidCallback? onAccept;

  /// Hides the summary and reasons (dashboard preview).
  final bool isCompact;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final isWaiting = handoff.status == HandoffStatus.waiting;
    final accept = onAccept;
    return SurfaceCard(
      accentColor: isWaiting ? palette.error : palette.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(
                name: handoff.leadName,
                tone: isWaiting ? StatusTone.error : StatusTone.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(handoff.leadName, style: text.titleSmall),
                    Text(
                      '${handoff.area} · ${handoff.budget}',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: 'Hot · ${handoff.score}',
                tone: StatusTone.error,
                icon: LucideIcons.flame,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: isWaiting
                ? SlaCountdownChip(dueAt: handoff.dueAt)
                : const StatusChip(
                    label: 'Accepted',
                    tone: StatusTone.success,
                    icon: LucideIcons.userCheck,
                  ),
          ),
          if (!isCompact) ..._details(context),
          if (isWaiting && accept != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Accept handoff',
              leading: const Icon(LucideIcons.userCheck, size: AppSizes.iconMd),
              isLoading: handoff.isAccepting,
              onPressed: accept,
            ),
          ],
        ],
      ),
    );
  }

  /// Summary, reasons and next action.
  List<Widget> _details(BuildContext context) {
    final text = context.textStyles;
    return [
      const SizedBox(height: AppSpacing.sm),
      Text(handoff.summary, style: text.bodyMedium),
      const SizedBox(height: AppSpacing.xs),
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xxs,
        children: [
          for (final reason in handoff.reasons)
            StatusChip(label: reason, tone: StatusTone.info),
        ],
      ),
      const SizedBox(height: AppSpacing.xs),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.sparkles,
            size: AppSizes.iconSm,
            color: context.palette.violet,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(handoff.nextAction, style: text.bodySmall)),
        ],
      ),
    ];
  }
}

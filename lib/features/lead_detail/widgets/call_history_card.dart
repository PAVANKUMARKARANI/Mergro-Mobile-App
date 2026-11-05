import '../../../shared/ui.dart';
import '../models/lead_profile.dart';

/// Past calls with the lead: when, how long and how it ended.
class CallHistoryCard extends StatelessWidget {
  /// Creates the card.
  const CallHistoryCard({
    super.key,
    required this.calls,
    required this.now,
    this.onOpenCall,
  });

  /// Calls, newest first.
  final List<CallSummary> calls;

  /// Current time, for day labels.
  final DateTime now;

  /// Opens a call's detail (screen 14) by id.
  final ValueChanged<String>? onOpenCall;

  /// Tone per outcome.
  static StatusTone toneOf(CallOutcome outcome) => switch (outcome) {
    CallOutcome.qualified => StatusTone.success,
    CallOutcome.callbackRequested => StatusTone.info,
    CallOutcome.noAnswer => StatusTone.warning,
    CallOutcome.optedOut => StatusTone.error,
  };

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final open = onOpenCall;
    if (calls.isEmpty) {
      return SurfaceCard(child: Text('No calls yet.', style: text.bodySmall));
    }
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, call) in calls.indexed) ...[
            if (index > 0) const Divider(height: AppSizes.borderThin),
            InkWell(
              onTap: open == null ? null : () => open(call.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      call.outcome == CallOutcome.noAnswer
                          ? LucideIcons.phoneMissed
                          : LucideIcons.phoneCall,
                      size: AppSizes.iconMd,
                      color: context.palette.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI call', style: text.titleSmall),
                          Text(
                            '${TimeFormat.day(call.startedAt, now)}, '
                            '${TimeFormat.clock(call.startedAt)}'
                            '${call.duration == Duration.zero ? '' : ' · ${TimeFormat.stopwatch(call.duration)}'}',
                            style: text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: call.outcome.label,
                      tone: toneOf(call.outcome),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

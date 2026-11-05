import '../../../shared/ui.dart';
import '../models/lead_insights.dart';

/// Screen 19: calls, messages, CRM sync and consent events, newest first,
/// on a vertical rail.
class ActivityTimeline extends StatelessWidget {
  /// Creates the timeline.
  const ActivityTimeline({super.key, required this.events, required this.now});

  /// Events, newest first.
  final List<TimelineEvent> events;

  /// Current time, for "… ago".
  final DateTime now;

  /// Icon per event kind.
  static IconData iconFor(TimelineKind kind) => switch (kind) {
    TimelineKind.captured => LucideIcons.inbox,
    TimelineKind.call => LucideIcons.phoneCall,
    TimelineKind.message => LucideIcons.messageSquareText,
    TimelineKind.crmSync => LucideIcons.database,
    TimelineKind.viewing => LucideIcons.calendarCheck,
    TimelineKind.handoff => LucideIcons.userCheck,
    TimelineKind.consent => LucideIcons.shieldOff,
  };

  /// Builds the timeline.
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          for (final (index, event) in events.indexed)
            _EventRow(
              event: event,
              now: now,
              isLast: index == events.length - 1,
            ),
        ],
      ),
    );
  }
}

/// One event with its icon dot and the rail down to the next one.
class _EventRow extends StatelessWidget {
  /// Creates the row.
  const _EventRow({
    required this.event,
    required this.now,
    required this.isLast,
  });

  /// The event.
  final TimelineEvent event;

  /// Current time.
  final DateTime now;

  /// Hides the rail under the last event.
  final bool isLast;

  /// Size of the icon dot.
  static const double dot = 32;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final isConsent = event.kind == TimelineKind.consent;
    final detail = event.detail;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: isConsent
                      ? palette.errorContainer
                      : palette.violetContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ActivityTimeline.iconFor(event.kind),
                  size: AppSizes.iconSm,
                  color: isConsent ? palette.error : palette.violet,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: AppSizes.borderThick,
                    color: palette.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.md,
                top: AppSpacing.xxs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: text.titleSmall),
                  if (detail != null) Text(detail, style: text.bodySmall),
                  Text(TimeFormat.ago(event.at, now), style: text.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

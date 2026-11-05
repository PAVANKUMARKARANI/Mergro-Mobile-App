import '../../../shared/ui.dart';
import '../models/nurture_enrollment.dart';

/// Icon per nurture channel.
extension NurtureChannelIcon on NurtureChannel {
  /// Icon for lists and chips.
  IconData get icon => switch (this) {
    NurtureChannel.sms => LucideIcons.messageSquareText,
    NurtureChannel.whatsapp => LucideIcons.messageCircle,
    NurtureChannel.email => LucideIcons.mail,
    NurtureChannel.call => LucideIcons.phoneOutgoing,
  };
}

/// Colour tone per nurture status.
extension NurtureStatusTone on NurtureStatus {
  /// Tone for the status chip.
  StatusTone get tone => switch (this) {
    NurtureStatus.active => StatusTone.info,
    NurtureStatus.replied => StatusTone.success,
    NurtureStatus.paused => StatusTone.warning,
    NurtureStatus.stopped => StatusTone.neutral,
  };
}

/// One enrollment: lead, journey progress, next touch and status.
class EnrollmentTile extends StatelessWidget {
  /// Creates the tile.
  const EnrollmentTile({
    super.key,
    required this.enrollment,
    required this.now,
  });

  /// The enrollment shown.
  final NurtureEnrollment enrollment;

  /// Current time, for the next-touch label.
  final DateTime now;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    final next = enrollment.nextTouchAt;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(enrollment.leadName, style: text.titleSmall),
              ),
              StatusChip(
                label: enrollment.status.label,
                tone: enrollment.status.tone,
              ),
            ],
          ),
          Text(
            '${enrollment.journey} · step ${enrollment.step} of '
            '${enrollment.totalSteps}',
            style: text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: enrollment.step / enrollment.totalSteps,
              minHeight: AppSizes.progressBarHeight,
              color: palette.violet,
              backgroundColor: palette.violetContainer,
              semanticsLabel: 'Journey progress',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                enrollment.nextChannel.icon,
                size: AppSizes.iconSm,
                color: palette.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  next == null
                      ? enrollment.lastEvent
                      : 'Next: ${enrollment.nextChannel.label} · '
                            '${TimeFormat.day(next, now)}, ${TimeFormat.clock(next)}',
                  style: text.bodySmall,
                ),
              ),
            ],
          ),
          if (next != null) Text(enrollment.lastEvent, style: text.labelSmall),
        ],
      ),
    );
  }
}

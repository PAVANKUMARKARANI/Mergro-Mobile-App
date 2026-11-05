import '../../../shared/ui.dart';
import '../../calls/calls_demo_data.dart';
import '../../calls/models/live_call.dart';
import '../../calls/widgets/live_call_tiles.dart';
import '../../viewings/models/viewing.dart';
import '../../viewings/widgets/viewing_tile.dart';

/// One-line live call for the dashboard: lead, stage, timer and latency.
class LiveCallRow extends StatelessWidget {
  /// Creates the row.
  const LiveCallRow({super.key, required this.call, this.onOpen});

  /// The call shown.
  final LiveCall call;

  /// Opens the live call monitor.
  final VoidCallback? onOpen;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final isFast = call.replyLatencyMs < CallsDemoData.naturalLatencyMs;
    return InkWell(
      onTap: onOpen,
      child: _RowPadding(
        child: Row(
          children: [
            _LeadingIcon(
              icon: LucideIcons.audioLines,
              color: palette.accent,
              tint: palette.successContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.leadName,
                    style: text.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${call.stage.label} · ${call.source.label}',
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElapsedTimeText(
                  since: call.startedAt,
                  style: AppTypography.mono(palette.textPrimary),
                ),
                Text(
                  '${call.replyLatencyMs} ms',
                  style: text.labelSmall?.copyWith(
                    color: isFast ? palette.success : palette.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact viewing for the dashboard: property, time, lead and status.
class ViewingRow extends StatelessWidget {
  /// Creates the row.
  const ViewingRow({super.key, required this.viewing, this.onOpen});

  /// The viewing shown.
  final Viewing viewing;

  /// Opens the lead profile.
  final VoidCallback? onOpen;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return InkWell(
      onTap: onOpen,
      child: _RowPadding(
        child: Row(
          children: [
            _LeadingIcon(
              icon: LucideIcons.calendarCheck,
              color: palette.violet,
              tint: palette.violetContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewing.property,
                    style: text.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${TimeFormat.clock(viewing.startsAt)} · ${viewing.leadName}',
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            StatusChip(label: viewing.status.label, tone: viewing.status.tone),
          ],
        ),
      ),
    );
  }
}

/// Icon in a tinted circle at the start of a row.
class _LeadingIcon extends StatelessWidget {
  /// Creates the icon.
  const _LeadingIcon({
    required this.icon,
    required this.color,
    required this.tint,
  });

  /// The icon.
  final IconData icon;

  /// Icon colour.
  final Color color;

  /// Circle colour.
  final Color tint;

  /// Builds the icon.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.cardIconTile,
      height: AppSizes.cardIconTile,
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
      child: Icon(icon, size: AppSizes.iconMd, color: color),
    );
  }
}

/// Standard padding of a dashboard row.
class _RowPadding extends StatelessWidget {
  /// Wraps [child].
  const _RowPadding({required this.child});

  /// Row content.
  final Widget child;

  /// Builds the padding.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: child,
    );
  }
}

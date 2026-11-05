import '../../../shared/ui.dart';
import '../models/handoff.dart';
import 'handoff_card.dart';

/// Compact hot lead for the dashboard: score badge, name, countdown and
/// area, and a small Accept button. About a third of a [HandoffCard].
class HotLeadRow extends StatelessWidget {
  /// Creates the row.
  const HotLeadRow({
    super.key,
    required this.handoff,
    required this.onAccept,
    this.onOpen,
  });

  /// The waiting handoff.
  final Handoff handoff;

  /// Accepts it.
  final VoidCallback onAccept;

  /// Opens the lead profile.
  final VoidCallback? onOpen;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Score ${handoff.score}',
              excludeSemantics: true,
              child: Container(
                width: AppSizes.cardIconTile,
                height: AppSizes.cardIconTile,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${handoff.score}',
                  style: text.labelLarge?.copyWith(color: palette.error),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    handoff.leadName,
                    style: text.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SlaCountdownText(dueAt: handoff.dueAt),
                  Text(
                    '${handoff.area} · ${handoff.budget}',
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            FilledButton(
              onPressed: handoff.isAccepting ? null : onAccept,
              style: FilledButton.styleFrom(
                backgroundColor: palette.primaryButton,
                foregroundColor: palette.onPrimaryButton,
                disabledBackgroundColor: palette.primaryButton,
                minimumSize: const Size(0, AppSizes.compactButtonHeight),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonAll,
                ),
                textStyle: text.labelMedium,
              ),
              child: handoff.isAccepting
                  ? SizedBox.square(
                      dimension: AppSizes.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSizes.spinnerStroke,
                        color: palette.onPrimaryButton,
                      ),
                    )
                  : Text(
                      'Accept',
                      semanticsLabel: 'Accept ${handoff.leadName}',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

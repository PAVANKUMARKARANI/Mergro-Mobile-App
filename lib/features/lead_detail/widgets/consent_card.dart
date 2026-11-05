import '../../../shared/ui.dart';
import '../models/lead_profile.dart';

/// Screen 20: consent per channel with its evidence. Agents can record a
/// withdrawal; only the lead can grant consent, so off switches are locked.
class ConsentCard extends StatelessWidget {
  /// Creates the card.
  const ConsentCard({
    super.key,
    required this.profile,
    required this.onWithdraw,
  });

  /// The profile whose consent is shown.
  final LeadProfile profile;

  /// Asks to record a withdrawal on a channel.
  final ValueChanged<ConsentChannel> onWithdraw;

  /// Icon per channel.
  static IconData iconFor(ConsentChannel channel) => switch (channel) {
    ConsentChannel.call => LucideIcons.phone,
    ConsentChannel.sms => LucideIcons.messageSquareText,
    ConsentChannel.whatsapp => LucideIcons.messageCircle,
    ConsentChannel.email => LucideIcons.mail,
  };

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final isLocked =
        profile.isDoNotContact || profile.busyAction == LeadAction.consent;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, consent) in profile.consents.indexed) ...[
            if (index > 0) const Divider(height: AppSizes.borderThin),
            _ConsentRow(
              consent: consent,
              onWithdraw: consent.isGranted && !isLocked
                  ? () => onWithdraw(consent.channel)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// One channel: icon, label, evidence and a switch.
class _ConsentRow extends StatelessWidget {
  /// Creates the row.
  const _ConsentRow({required this.consent, required this.onWithdraw});

  /// The consent shown.
  final ChannelConsent consent;

  /// Records a withdrawal; null locks the switch.
  final VoidCallback? onWithdraw;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final withdraw = onWithdraw;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            ConsentCard.iconFor(consent.channel),
            size: AppSizes.iconMd,
            color: consent.isGranted ? palette.success : palette.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(consent.channel.label, style: text.titleSmall),
                Text(
                  '${consent.evidence} · ${TimeFormat.shortDate(consent.recordedAt)}',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: consent.isGranted,
            onChanged: withdraw == null ? null : (_) => withdraw(),
          ),
        ],
      ),
    );
  }
}

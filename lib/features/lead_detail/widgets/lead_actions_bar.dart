import '../../../shared/ui.dart';
import '../models/lead_profile.dart';

/// Quick actions under the header: call back, message, book viewing,
/// do-not-contact.
/// Disabled once the lead is suppressed; the running action shows a spinner.
class LeadActionsBar extends StatelessWidget {
  /// Creates the bar.
  const LeadActionsBar({
    super.key,
    required this.profile,
    required this.onCallBack,
    required this.onMessage,
    required this.onBookViewing,
    required this.onDoNotContact,
  });

  /// The profile the actions apply to.
  final LeadProfile profile;

  /// Asks the AI to call the lead back.
  final VoidCallback onCallBack;

  /// Opens the message composer.
  final VoidCallback onMessage;

  /// Opens Book viewing (screen 18).
  final VoidCallback onBookViewing;

  /// Asks to mark the lead do-not-contact.
  final VoidCallback onDoNotContact;

  /// Builds the four buttons.
  @override
  Widget build(BuildContext context) {
    final isBlocked = profile.isDoNotContact || profile.busyAction != null;
    final busy = profile.busyAction;
    const gap = SizedBox(width: AppSpacing.xs);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActionButton(
            icon: LucideIcons.phoneOutgoing,
            label: 'Call back',
            isBusy: busy == LeadAction.callBack,
            onTap: isBlocked ? null : onCallBack,
          ),
          gap,
          _ActionButton(
            icon: LucideIcons.messageSquareText,
            label: 'Message',
            isBusy: busy == LeadAction.message,
            onTap: isBlocked ? null : onMessage,
          ),
          gap,
          _ActionButton(
            icon: LucideIcons.calendarPlus,
            label: 'Book viewing',
            isBusy: false,
            onTap: isBlocked ? null : onBookViewing,
          ),
          gap,
          _ActionButton(
            icon: LucideIcons.ban,
            label: 'Do not contact',
            isBusy: busy == LeadAction.doNotContact,
            isDestructive: true,
            onTap: isBlocked ? null : onDoNotContact,
          ),
        ],
      ),
    );
  }
}

/// Square button: icon over a label.
class _ActionButton extends StatelessWidget {
  /// Creates the button.
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isBusy,
    required this.onTap,
    this.isDestructive = false,
  });

  /// Icon.
  final IconData icon;

  /// Label under the icon.
  final String label;

  /// Shows a spinner instead of the icon.
  final bool isBusy;

  /// Runs the action; null disables the button.
  final VoidCallback? onTap;

  /// Red colouring for irreversible actions.
  final bool isDestructive;

  /// Builds the button.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isEnabled = onTap != null;
    final color = !isEnabled
        ? palette.textSecondary
        : isDestructive
        ? palette.error
        : palette.violet;
    return Expanded(
      child: Opacity(
        opacity: isEnabled || isBusy ? 1 : 0.5,
        child: SurfaceCard(
          onTap: onTap,
          semanticLabel: label,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              SizedBox.square(
                dimension: AppSizes.iconLg,
                child: isBusy
                    ? CircularProgressIndicator(
                        strokeWidth: AppSizes.spinnerStroke,
                        color: color,
                      )
                    : Icon(icon, color: color),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.textStyles.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

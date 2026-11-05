import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import 'app_button.dart';
import 'status_chip.dart';

/// Connection state of a third-party integration.
enum IntegrationStatus {
  /// Available but not linked.
  notConnected('Not connected', StatusTone.neutral),

  /// Link in progress.
  connecting('Connecting…', StatusTone.info),

  /// Linked successfully.
  connected('Connected', StatusTone.success),

  /// Not yet available.
  comingSoon('Coming soon', StatusTone.neutral);

  /// Creates a status with its chip label and tone.
  const IntegrationStatus(this.label, this.tone);

  /// Chip text.
  final String label;

  /// Chip colour tone.
  final StatusTone tone;
}

/// Card for one integration (CRM, calendar…): logo, name, description,
/// status chip and a Connect action.
class IntegrationCard extends StatelessWidget {
  /// Creates an integration card.
  const IntegrationCard({
    super.key,
    required this.name,
    required this.description,
    required this.status,
    this.logo,
    this.onConnect,
    this.onDisconnect,
    this.isRequired = false,
  });

  /// Integration name, e.g. "Zoho CRM".
  final String name;

  /// One-line description.
  final String description;

  /// Current connection state.
  final IntegrationStatus status;

  /// Logo slot; defaults to a generic plug icon.
  final Widget? logo;

  /// Called by the Connect button.
  final VoidCallback? onConnect;

  /// Called by the Disconnect button; hidden when null.
  final VoidCallback? onDisconnect;

  /// Appends " *" to the name.
  final bool isRequired;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    final action = _buildAction();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoSlot(child: logo),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isRequired ? '$name *' : name, style: text.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(description, style: text.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    StatusChip(label: status.label, tone: status.tone),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.sm),
            action,
          ],
        ],
      ),
    );
  }

  /// Connect / Disconnect button for the current status, or null.
  Widget? _buildAction() => switch (status) {
    IntegrationStatus.notConnected || IntegrationStatus.connecting => AppButton(
      label: 'Connect $name',
      variant: AppButtonVariant.secondary,
      isLoading: status == IntegrationStatus.connecting,
      onPressed: onConnect,
    ),
    IntegrationStatus.connected when onDisconnect != null => AppButton(
      label: 'Disconnect',
      variant: AppButtonVariant.ghost,
      onPressed: onDisconnect,
    ),
    _ => null,
  };
}

/// Square, bordered slot that holds the integration logo.
class _LogoSlot extends StatelessWidget {
  /// Creates the slot.
  const _LogoSlot({required this.child});

  /// Logo widget, or null for the default icon.
  final Widget? child;

  /// Builds the slot.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: AppSizes.integrationLogo,
      height: AppSizes.integrationLogo,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadius.inputAll,
      ),
      child:
          child ??
          Icon(
            LucideIcons.plug,
            size: AppSizes.iconMd,
            color: palette.textSecondary,
          ),
    );
  }
}

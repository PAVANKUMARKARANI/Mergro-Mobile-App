import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../../auth/models/app_user.dart';
import '../../controllers/invite_team_controller.dart';
import '../../models/agent_setup_drafts.dart';
import '../../onboarding_demo_data.dart';

/// Admin step 6 (optional): add teammates and choose their roles.
class InviteTeamStep extends ConsumerWidget {
  /// Creates the step.
  const InviteTeamStep({super.key});

  /// Builds the step.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(inviteTeamControllerProvider);
    final controller = ref.read(inviteTeamControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailChipInput(
          label: 'Work emails',
          hint: 'teammate@brokerage.com',
          // Invites are listed below with their roles, so no chips here.
          emails: const [],
          onAdd: controller.addInvite,
          onRemove: controller.removeInvite,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Invites (${draft.invites.length})',
          subtitle: draft.invites.isEmpty
              ? 'Added teammates appear here. New invites join as sales agents.'
              : 'Invites are emailed when you continue.',
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final invite in draft.invites) ...[
          _InviteRow(
            invite: invite,
            onRoleChanged: (role) => controller.setRole(invite.email, role),
            onRemove: () => controller.removeInvite(invite.email),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

/// One invite: email, role picker and remove button.
class _InviteRow extends StatelessWidget {
  /// Creates the row.
  const _InviteRow({
    required this.invite,
    required this.onRoleChanged,
    required this.onRemove,
  });

  /// The invite shown.
  final TeamInvite invite;

  /// Called with a new role.
  final ValueChanged<UserRole> onRoleChanged;

  /// Removes the invite.
  final VoidCallback onRemove;

  /// Builds the row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.mail,
                size: AppSizes.iconSm,
                color: palette.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  invite.email,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Remove ${invite.email}',
                onPressed: onRemove,
                icon: const Icon(LucideIcons.x, size: AppSizes.iconMd),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppDropdownField<UserRole>(
              label: 'Role',
              options: OnboardingDemoData.inviteRoles,
              labelOf: (role) => role.label,
              value: invite.role,
              onChanged: onRoleChanged,
            ),
          ),
        ],
      ),
    );
  }
}

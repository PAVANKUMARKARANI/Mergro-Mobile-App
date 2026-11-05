import '../../../shared/ui.dart';
import '../auth_demo_data.dart';
import '../models/app_user.dart';

/// Debug-only "Preview as: Admin · Agent · Team lead" chips that pick the
/// dummy user's role, and so the onboarding flow.
class PreviewRoleSelector extends StatelessWidget {
  /// Creates the selector.
  const PreviewRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onSelected,
  });

  /// Label before the chips.
  static const String label = 'Preview as:';

  /// The currently selected role.
  final UserRole selectedRole;

  /// Called with the tapped role.
  final ValueChanged<UserRole> onSelected;

  /// Builds the chip row.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(label, style: context.textStyles.bodySmall),
        for (final role in AuthDemoData.previewRoles)
          ChoiceChip(
            label: Text(AuthDemoData.previewLabels[role] ?? role.label),
            selected: role == selectedRole,
            onSelected: (_) => onSelected(role),
            selectedColor: palette.violetContainer,
            backgroundColor: palette.surface,
            side: BorderSide(color: palette.border),
            labelStyle: context.textStyles.labelMedium?.copyWith(
              color: role == selectedRole ? palette.violet : null,
            ),
            showCheckmark: false,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.inputAll,
            ),
          ),
      ],
    );
  }
}

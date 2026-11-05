import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/agent_profile_controllers.dart';
import '../../onboarding_demo_data.dart';

/// Agent step 1: avatar, full name, mobile number and languages.
class AgentProfileStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const AgentProfileStep({super.key});

  /// Creates the state owning the text controllers.
  @override
  ConsumerState<AgentProfileStep> createState() => _AgentProfileStepState();
}

/// Seeds text controllers from the draft so values survive Back / Next.
class _AgentProfileStepState extends ConsumerState<AgentProfileStep> {
  late final AgentProfileController _controller = ref.read(
    agentProfileControllerProvider.notifier,
  );
  late final TextEditingController _nameController = TextEditingController(
    text: ref.read(agentProfileControllerProvider).fullName,
  );
  late final TextEditingController _mobileController = TextEditingController(
    text: ref.read(agentProfileControllerProvider).mobileNumber,
  );

  /// Releases the text controllers.
  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// Builds the step.
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(agentProfileControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _AvatarButton(
            initials: draft.initials,
            hasPhoto: draft.hasPhoto,
            onTap: () => _controller.setHasPhoto(!draft.hasPhoto),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Full name',
          isRequired: true,
          controller: _nameController,
          prefixIcon: LucideIcons.user,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          onChanged: _controller.updateName,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Mobile number',
          isRequired: true,
          hint: '+91 98765 43210',
          controller: _mobileController,
          prefixIcon: LucideIcons.smartphone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          errorText: draft.mobileError,
          onChanged: _controller.updateMobile,
        ),
        const SizedBox(height: AppSpacing.lg),
        ToggleChipGroup<String>(
          label: 'Languages you speak',
          options: OnboardingDemoData.spokenLanguages,
          selected: draft.languages,
          labelOf: (language) => language,
          onToggled: _controller.toggleLanguage,
        ),
      ],
    );
  }
}

/// Circular avatar with initials; tapping toggles a placeholder photo.
class _AvatarButton extends StatelessWidget {
  /// Creates the avatar.
  const _AvatarButton({
    required this.initials,
    required this.hasPhoto,
    required this.onTap,
  });

  /// Initials shown without a photo.
  final String initials;

  /// Whether the placeholder photo is shown.
  final bool hasPhoto;

  /// Toggles the placeholder photo.
  final VoidCallback onTap;

  static const double _diameter = AppSizes.logoLg;

  /// Builds the avatar and caption.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: hasPhoto ? 'Profile photo added, tap to remove' : 'Add photo',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          children: [
            Container(
              width: _diameter,
              height: _diameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasPhoto ? palette.brandNavy : palette.violetContainer,
              ),
              child: hasPhoto
                  ? const Icon(
                      LucideIcons.userRound,
                      size: AppSizes.logoMd,
                      color: AppColors.white,
                    )
                  : Text(
                      initials.isEmpty ? '?' : initials,
                      style: context.textStyles.titleLarge?.copyWith(
                        color: palette.violet,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasPhoto ? 'Remove photo' : 'Add photo',
              style: context.textStyles.labelMedium?.copyWith(
                color: palette.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

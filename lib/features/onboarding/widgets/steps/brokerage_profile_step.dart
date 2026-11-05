import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/brokerage_profile_controller.dart';
import '../../models/onboarding_options.dart';
import '../../onboarding_demo_data.dart';

/// Admin step 1: name, logo, country, time zone, address and hours.
class BrokerageProfileStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const BrokerageProfileStep({super.key});

  /// Creates the state owning the text controllers.
  @override
  ConsumerState<BrokerageProfileStep> createState() =>
      _BrokerageProfileStepState();
}

/// Seeds text controllers from the draft so values survive Back / Next.
class _BrokerageProfileStepState extends ConsumerState<BrokerageProfileStep> {
  late final BrokerageProfileController _controller = ref.read(
    brokerageProfileControllerProvider.notifier,
  );
  late final TextEditingController _nameController = TextEditingController(
    text: ref.read(brokerageProfileControllerProvider).brokerageName,
  );
  late final TextEditingController _addressController = TextEditingController(
    text: ref.read(brokerageProfileControllerProvider).officeAddress,
  );

  /// Releases the text controllers.
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Builds the form.
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(brokerageProfileControllerProvider);
    final country = draft.country;
    final zones = country == null
        ? const <String>[]
        : OnboardingDemoData.timeZones[country] ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Brokerage name',
          isRequired: true,
          hint: 'e.g. Skyline Realty',
          controller: _nameController,
          prefixIcon: LucideIcons.building2,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: _controller.updateName,
        ),
        const SizedBox(height: AppSpacing.lg),
        _LogoUploadTile(
          hasLogo: draft.hasLogo,
          onTap: () => _controller.setHasLogo(!draft.hasLogo),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDropdownField<Country>(
          label: 'Country',
          isRequired: true,
          hint: 'Select country',
          options: Country.values,
          labelOf: (option) => option.label,
          value: country,
          onChanged: _controller.setCountry,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppDropdownField<String>(
          // Re-create when the country changes so the selection resets.
          key: ValueKey(country),
          label: 'Time zone',
          isRequired: true,
          hint: country == null ? 'Select a country first' : 'Select time zone',
          options: zones,
          labelOf: (zone) => zone,
          value: draft.timeZone,
          onChanged: _controller.setTimeZone,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Office address',
          hint: 'Street, city',
          controller: _addressController,
          prefixIcon: LucideIcons.mapPin,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: _controller.updateAddress,
        ),
        const SizedBox(height: AppSpacing.lg),
        TimeRangeField(
          label: 'Business hours',
          startLabel: 'Open',
          endLabel: 'Close',
          start: draft.opensAt,
          end: draft.closesAt,
          onStartChanged: _controller.setOpensAt,
          onEndChanged: _controller.setClosesAt,
          errorText: draft.opensAt.isBefore(draft.closesAt)
              ? null
              : 'Closing time must be after opening time.',
        ),
      ],
    );
  }
}

/// Dashed-style upload tile; tapping toggles a placeholder logo.
class _LogoUploadTile extends StatelessWidget {
  /// Creates the tile.
  const _LogoUploadTile({required this.hasLogo, required this.onTap});

  /// Whether the placeholder logo is shown.
  final bool hasLogo;

  /// Toggles the placeholder logo.
  final VoidCallback onTap;

  /// Builds the tile.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return Semantics(
      button: true,
      label: hasLogo ? 'Brokerage logo added, tap to remove' : 'Upload logo',
      excludeSemantics: true,
      child: Material(
        color: palette.background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardAll,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          borderRadius: AppRadius.cardAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                hasLogo
                    ? const MergroLogoMark(size: AppSizes.cardIconTile)
                    : Icon(LucideIcons.imageUp, color: palette.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLogo ? 'Logo added' : 'Upload logo',
                        style: text.titleSmall,
                      ),
                      Text(
                        hasLogo
                            ? 'Tap to remove'
                            : 'PNG or SVG, square works best',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

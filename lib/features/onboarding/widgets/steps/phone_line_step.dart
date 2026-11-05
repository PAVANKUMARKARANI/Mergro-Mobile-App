import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/brokerage_profile_controller.dart';
import '../../controllers/phone_line_controller.dart';
import '../../models/onboarding_options.dart';
import '../../models/phone_line_draft.dart';
import '../../onboarding_demo_data.dart';
import 'otp_sheet.dart';

/// Admin step 4: provider, number, calling window and consent.
class PhoneLineStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const PhoneLineStep({super.key});

  /// Creates the state owning the existing-number controller.
  @override
  ConsumerState<PhoneLineStep> createState() => _PhoneLineStepState();
}

/// Owns the existing-number text controller.
class _PhoneLineStepState extends ConsumerState<PhoneLineStep> {
  late final PhoneLineController _controller = ref.read(
    phoneLineControllerProvider.notifier,
  );
  late final TextEditingController _numberController;

  /// Creates the controller eagerly: the field isn't always built, and a lazy
  /// first access in dispose() would read `ref` after unmount.
  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: ref.read(phoneLineControllerProvider).existingNumber,
    );
  }

  /// Releases the text controller.
  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  /// Sends the code, then opens the code sheet.
  Future<void> _verifyNumber() async {
    final isSent = await _controller.sendVerificationCode();
    if (!isSent || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => OtpSheet(
        phoneNumber: _numberController.text.trim(),
        onVerified: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  /// Builds the step.
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(phoneLineControllerProvider);
    final country =
        ref.watch(brokerageProfileControllerProvider).country ?? Country.india;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Calling provider'),
        const SizedBox(height: AppSpacing.sm),
        for (final provider in TelephonyProvider.values) ...[
          SelectableCard(
            icon: LucideIcons.radioTower,
            title: provider.label,
            subtitle: provider.description,
            isSelected: draft.provider == provider,
            onTap: () => _controller.selectProvider(provider),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Phone number'),
        const SizedBox(height: AppSpacing.sm),
        for (final source in NumberSource.values) ...[
          SelectableCard(
            icon: source == NumberSource.newNumber
                ? LucideIcons.circlePlus
                : LucideIcons.phone,
            title: source.label,
            isSelected: draft.numberSource == source,
            onTap: () => _controller.setNumberSource(source),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.sm),
        if (draft.numberSource == NumberSource.newNumber)
          ..._buildSampleNumbers(draft, country)
        else
          _buildExistingNumber(draft),
        const SizedBox(height: AppSpacing.xl),
        _buildCallingWindow(country),
        const SizedBox(height: AppSpacing.md),
        CheckboxListTile(
          value: draft.consentConfirmed,
          onChanged: (value) => _controller.setConsent(value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'I confirm our leads have agreed to be contacted. *',
            style: context.textStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// Three sample numbers to choose from.
  List<Widget> _buildSampleNumbers(PhoneLineDraft draft, Country country) {
    final numbers = OnboardingDemoData.sampleNumbers[country] ?? const [];
    return [
      for (final number in numbers) ...[
        SelectableCard(
          title: number,
          subtitle: 'Local number · ${country.label}',
          isSelected: draft.selectedNumber == number,
          onTap: () => _controller.selectNumber(number),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    ];
  }

  /// Existing-number field with Verify, or the verified state.
  Widget _buildExistingNumber(PhoneLineDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Your existing number',
          hint: '+91 98765 43210',
          controller: _numberController,
          prefixIcon: LucideIcons.phone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          errorText: draft.existingNumberError,
          onChanged: _controller.updateExistingNumber,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (draft.isVerified)
          const InfoBanner(
            type: InfoBannerType.success,
            message: 'Number verified.',
          )
        else
          AppButton(
            label: 'Verify number',
            variant: AppButtonVariant.secondary,
            isLoading: draft.isSendingCode,
            onPressed: _verifyNumber,
          ),
      ],
    );
  }

  /// Fixed calling window and the country's compliance note.
  Widget _buildCallingWindow(Country country) {
    final window = OnboardingDemoData.callingWindows[country];
    final hours = window == null
        ? ''
        : '${window.$1.label24}–${window.$2.label24}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Calling window',
          subtitle: 'Mergro only calls leads $hours in their local time.',
        ),
        const SizedBox(height: AppSpacing.sm),
        InfoBanner(
          title: country == Country.india ? 'TRAI DND' : 'TCPA',
          message: OnboardingDemoData.complianceNotes[country] ?? '',
        ),
      ],
    );
  }
}

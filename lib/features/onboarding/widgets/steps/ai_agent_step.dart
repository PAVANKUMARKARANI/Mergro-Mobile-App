import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/ui.dart';
import '../../controllers/ai_agent_controller.dart';
import '../../controllers/brokerage_profile_controller.dart';
import '../../controllers/voice_preview_controller.dart';
import '../../models/onboarding_options.dart';
import '../../onboarding_demo_data.dart';
import '../voice_preview_button.dart';

/// Admin step 5: agent name, voice, languages, greeting and AI disclosure.
class AiAgentStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const AiAgentStep({super.key});

  /// Creates the state owning the name controller.
  @override
  ConsumerState<AiAgentStep> createState() => _AiAgentStepState();
}

/// Owns the agent-name text controller.
class _AiAgentStepState extends ConsumerState<AiAgentStep> {
  late final AiAgentController _controller = ref.read(
    aiAgentControllerProvider.notifier,
  );
  late final TextEditingController _nameController = TextEditingController(
    text: ref.read(aiAgentControllerProvider).agentName,
  );

  /// Releases the text controller.
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Speaks [greeting] in [voice]; tells the user if speech is unavailable.
  Future<void> _togglePreview(
    AgentVoice voice,
    String greeting,
    Country country,
  ) async {
    final isPlayed = await ref
        .read(voicePreviewControllerProvider.notifier)
        .togglePreview(voice, greeting, country);
    if (isPlayed || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text("Voice preview isn't available on this device."),
        ),
      );
  }

  /// Builds the step.
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(aiAgentControllerProvider);
    final playingVoice = ref.watch(voicePreviewControllerProvider);
    final profile = ref.watch(brokerageProfileControllerProvider);
    final brokerageName = profile.brokerageName.trim();
    final country = profile.country ?? Country.india;
    final agentName = draft.agentName.trim().isEmpty
        ? OnboardingDemoData.defaultAgentName
        : draft.agentName.trim();
    final greeting = OnboardingDemoData.greeting(
      agentName,
      brokerageName.isEmpty
          ? OnboardingDemoData.fallbackBrokerageName
          : brokerageName,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Agent name',
          isRequired: true,
          controller: _nameController,
          prefixIcon: LucideIcons.bot,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: _controller.updateName,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Voice'),
        const SizedBox(height: AppSpacing.sm),
        for (final voice in AgentVoice.values) ...[
          SelectableCard(
            icon: LucideIcons.audioLines,
            title: voice.label,
            subtitle: voice.description,
            isSelected: draft.voice == voice,
            onTap: () => _controller.selectVoice(voice),
            trailing: VoicePreviewButton(
              voiceLabel: voice.label,
              isPlaying: playingVoice == voice,
              onPressed: () => _togglePreview(voice, greeting, country),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        const SizedBox(height: AppSpacing.lg),
        ToggleChipGroup<String>(
          label: 'Languages *',
          options: OnboardingDemoData.agentLanguages,
          selected: draft.languages,
          labelOf: (language) => language,
          onToggled: _controller.toggleLanguage,
        ),
        const SizedBox(height: AppSpacing.xl),
        _GreetingPreview(greeting: greeting),
        const SizedBox(height: AppSpacing.md),
        SettingSwitchTile(
          title: "Tell leads they're speaking with an AI",
          subtitle: 'Required for compliance',
          value: draft.disclosesAi,
          isLocked: true,
        ),
      ],
    );
  }
}

/// Speech-bubble card showing the live greeting text.
class _GreetingPreview extends StatelessWidget {
  /// Creates the preview.
  const _GreetingPreview({required this.greeting});

  /// Greeting text.
  final String greeting;

  /// Builds the card.
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = context.textStyles;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.violetContainer,
        borderRadius: AppRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.messageSquareQuote,
                size: AppSizes.iconSm,
                color: palette.violet,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  'Greeting preview',
                  style: text.labelMedium?.copyWith(color: palette.violet),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('“$greeting”', style: text.bodyLarge),
        ],
      ),
    );
  }
}

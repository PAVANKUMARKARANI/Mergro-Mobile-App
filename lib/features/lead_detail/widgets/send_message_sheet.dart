import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/lead_profile_controller.dart';
import '../models/lead_profile.dart';

/// Composer for an SMS, WhatsApp or email to the lead. Only channels the
/// lead agreed to are offered; [onSent] gets the confirmation text.
class SendMessageSheet extends ConsumerStatefulWidget {
  /// Creates the sheet for [leadId].
  const SendMessageSheet({
    super.key,
    required this.leadId,
    required this.onSent,
  });

  /// The lead to message.
  final String leadId;

  /// Called with the success message once sent.
  final ValueChanged<String> onSent;

  /// Messaging channels, in the order offered.
  static const List<ConsentChannel> channels = [
    ConsentChannel.whatsapp,
    ConsentChannel.sms,
    ConsentChannel.email,
  ];

  /// Quick templates; `{name}` becomes the lead's first name.
  static const Map<String, String> templates = {
    'Follow-up': 'Hi {name}, thanks for speaking with us. Any questions about the homes we discussed?',
    'New listings': 'Hi {name}, we have new listings that match what you asked for. Shall I share them?',
    'Viewing reminder': 'Hi {name}, a reminder about your viewing. Reply here if you need to change the time.',
  };

  /// Creates the state owning the text controller.
  @override
  ConsumerState<SendMessageSheet> createState() => _SendMessageSheetState();
}

/// Owns the text field and the selected channel.
class _SendMessageSheetState extends ConsumerState<SendMessageSheet> {
  final TextEditingController _textController = TextEditingController();
  ConsentChannel? _channel;
  String? _error;

  /// Releases the text controller.
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Sends the message and reports the result.
  Future<void> _send(ConsentChannel channel) async {
    setState(() => _error = null);
    final outcome = await ref
        .read(leadProfileControllerProvider(widget.leadId).notifier)
        .sendMessage(channel, _textController.text);
    if (!mounted) return;
    switch (outcome) {
      case LeadActionSucceeded(:final message):
        widget.onSent(message);
      case LeadActionFailed(:final message):
        setState(() => _error = message);
    }
  }

  /// Builds the composer.
  @override
  Widget build(BuildContext context) {
    final profile = ref
        .watch(leadProfileControllerProvider(widget.leadId))
        .value;
    if (profile == null) return const SizedBox.shrink();
    final allowed = SendMessageSheet.channels
        .where(profile.canContact)
        .toList();
    final channel = _channel ?? allowed.firstOrNull;
    final firstName = profile.lead.name.split(' ').first;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: 'Message $firstName', isLarge: true),
            const SizedBox(height: AppSpacing.md),
            if (channel == null)
              const InfoBanner(
                type: InfoBannerType.error,
                message: "This lead hasn't agreed to SMS, WhatsApp or email.",
              )
            else ...[
              ToggleChipGroup<ConsentChannel>(
                label: 'Send by',
                options: allowed,
                selected: {channel},
                labelOf: (option) => option.label,
                onToggled: (option) => setState(() => _channel = option),
              ),
              const SizedBox(height: AppSpacing.md),
              ToggleChipGroup<String>(
                label: 'Templates',
                options: SendMessageSheet.templates.keys.toList(),
                selected: const {},
                labelOf: (name) => name,
                onToggled: (name) => setState(() {
                  _textController.text = SendMessageSheet.templates[name]!
                      .replaceAll('{name}', firstName);
                  _error = null;
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Message',
                controller: _textController,
                maxLines: 5,
                maxLength: 500,
                errorText: _error,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Send ${channel.label}',
                leading: const Icon(LucideIcons.send, size: AppSizes.iconMd),
                isLoading: profile.busyAction == LeadAction.message,
                onPressed: () => _send(channel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

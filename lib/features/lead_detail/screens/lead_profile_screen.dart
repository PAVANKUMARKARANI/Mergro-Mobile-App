import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../controllers/lead_profile_controller.dart';
import '../models/lead_profile.dart';
import '../widgets/activity_timeline.dart';
import '../widgets/call_history_card.dart';
import '../widgets/consent_card.dart';
import '../widgets/lead_actions_bar.dart';
import '../widgets/lead_profile_header.dart';
import '../widgets/qualification_card.dart';
import '../widgets/score_card.dart';

/// Screen 13: everything about one lead — contact, score, qualification
/// (16), score reasons (17), activity (19), consent (20) and calls — with
/// call-back, message and do-not-contact actions.
class LeadProfileScreen extends ConsumerWidget {
  /// Creates the screen for [leadId].
  const LeadProfileScreen({
    super.key,
    required this.leadId,
    required this.onComposeMessage,
    required this.onBookViewing,
    required this.onOpenCall,
  });

  /// The lead shown.
  final String leadId;

  /// Opens the message composer (wired by AppRoutes).
  final VoidCallback onComposeMessage;

  /// Opens Book viewing (screen 18) for this lead.
  final VoidCallback onBookViewing;

  /// Opens a past call's detail (screen 14) by id.
  final ValueChanged<String> onOpenCall;

  /// Builds the profile.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = leadProfileControllerProvider(leadId);
    final profile = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(profile.value?.lead.name ?? 'Lead')),
      body: AsyncValueView<LeadProfile>(
        value: profile,
        onRetry: controller.refresh,
        builder: (data) => RefreshIndicator(
          onRefresh: controller.refresh,
          child: _ProfileBody(
            profile: data,
            onCallBack: () => _report(context, controller.requestCallBack()),
            onMessage: onComposeMessage,
            onBookViewing: onBookViewing,
            onOpenCall: onOpenCall,
            onDoNotContact: () => _confirmDoNotContact(context, controller),
            onWithdraw: (channel) =>
                _confirmWithdraw(context, controller, channel),
          ),
        ),
      ),
    );
  }

  /// Shows the outcome of [action] in a snack bar.
  static Future<void> _report(
    BuildContext context,
    Future<LeadActionOutcome> action,
  ) async {
    final outcome = await action;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(outcome.message)));
  }

  /// Confirms, then marks the lead do-not-contact.
  static Future<void> _confirmDoNotContact(
    BuildContext context,
    LeadProfileController controller,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Stop all contact?',
      message:
          'Calls, messages and journeys stop for good and the lead joins the '
          'suppression list. Only do this if the lead asked.',
      action: 'Do not contact',
    );
    if (confirmed && context.mounted) {
      await _report(context, controller.markDoNotContact());
    }
  }

  /// Confirms, then records that consent on [channel] was withdrawn.
  static Future<void> _confirmWithdraw(
    BuildContext context,
    LeadProfileController controller,
    ConsentChannel channel,
  ) async {
    final confirmed = await _confirm(
      context,
      title: 'Withdraw ${channel.label} consent?',
      message:
          "Mergro won't use ${channel.label} for this lead again. Only the "
          'lead can give consent back.',
      action: 'Withdraw',
    );
    if (confirmed && context.mounted) {
      await _report(context, controller.withdrawConsent(channel));
    }
  }

  /// A Cancel / [action] dialog; true when confirmed.
  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// The scrolling sections of a loaded profile.
class _ProfileBody extends StatelessWidget {
  /// Creates the body.
  const _ProfileBody({
    required this.profile,
    required this.onCallBack,
    required this.onMessage,
    required this.onBookViewing,
    required this.onOpenCall,
    required this.onDoNotContact,
    required this.onWithdraw,
  });

  /// The profile shown.
  final LeadProfile profile;

  /// Call-back action.
  final VoidCallback onCallBack;

  /// Message action.
  final VoidCallback onMessage;

  /// Book viewing action.
  final VoidCallback onBookViewing;

  /// Opens a call's detail.
  final ValueChanged<String> onOpenCall;

  /// Do-not-contact action.
  final VoidCallback onDoNotContact;

  /// Consent withdrawal action.
  final ValueChanged<ConsentChannel> onWithdraw;

  /// Builds the sections.
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    Widget section(String title, Widget child, {String? subtitle}) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        LeadProfileHeader(profile: profile, now: now),
        const SizedBox(height: AppSpacing.sm),
        LeadActionsBar(
          profile: profile,
          onCallBack: onCallBack,
          onMessage: onMessage,
          onBookViewing: onBookViewing,
          onDoNotContact: onDoNotContact,
        ),
        section(
          'Qualification',
          QualificationCard(fields: profile.qualification),
          subtitle: 'Captured by the AI, with its confidence.',
        ),
        section('Lead score', ScoreCard(profile: profile)),
        section(
          'Activity',
          ActivityTimeline(events: profile.timeline, now: now),
        ),
        section(
          'Consent & preferences',
          ConsentCard(profile: profile, onWithdraw: onWithdraw),
          subtitle:
              'Only the lead can give consent; you can record a withdrawal.',
        ),
        section(
          'Calls',
          CallHistoryCard(
            calls: profile.calls,
            now: now,
            onOpenCall: onOpenCall,
          ),
        ),
      ],
    );
  }
}

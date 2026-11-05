import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../leads/controllers/leads_controller.dart';
import '../../leads/leads_demo_data.dart';
import '../../leads/models/lead.dart';
import '../../viewings/models/viewing.dart';
import '../lead_profile_demo_data.dart';
import '../models/lead_insights.dart';
import '../models/lead_profile.dart';

/// The profile of one lead (screen 13), by lead id. Failed loads are not
/// retried automatically: the screen shows the error with a Retry button.
final leadProfileControllerProvider = AsyncNotifierProvider.autoDispose
    .family<LeadProfileController, LeadProfile, String>(
      LeadProfileController.new,
      retry: _noAutomaticRetry,
    );

/// Disables Riverpod's automatic retry (it would hide a not-found lead
/// behind ~30 s of silent retries).
Duration? _noAutomaticRetry(int retryCount, Object error) => null;

/// Loads a lead's profile and runs its actions (simulated until the leads
/// API exists).
class LeadProfileController extends AsyncNotifier<LeadProfile> {
  /// Creates the controller for [leadId].
  LeadProfileController(this.leadId);

  /// The lead shown.
  final String leadId;

  /// Message when an action is already running.
  static const String busyMessage = 'Still working on the last action…';

  /// Loads the profile.
  @override
  Future<LeadProfile> build() async {
    // TODO(backend): GET /api/leads/{id} (profile, qualification, score
    // reasons, consent) and GET /api/leads/{id}/timeline.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    final now = DateTime.now();
    final lead = LeadsDemoData.leads(now)
        .where((item) => item.id == leadId)
        .firstOrNull;
    if (lead == null) {
      throw ApiException(
        ApiErrorKind.notFound,
        message: 'This lead no longer exists.',
      );
    }
    return LeadProfileDemoData.profileFor(lead, now);
  }

  /// Reloads (pull to refresh, Retry).
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Asks the AI to call the lead back now.
  Future<LeadActionOutcome> requestCallBack() {
    final profile = state.value;
    if (profile != null && !profile.canContact(ConsentChannel.call)) {
      return Future.value(
        const LeadActionFailed("This lead hasn't agreed to calls."),
      );
    }
    // TODO(backend): POST /api/leads/{id}/call-back (queues an AI call).
    return _run(
      LeadAction.callBack,
      (current) => current.copyWith(
        timeline: [
          _event(
            TimelineKind.call,
            'AI call-back requested',
            'By ${_agentName()}',
          ),
          ...current.timeline,
        ],
      ),
      'Mergro will call ${_firstName(profile)} within 60 seconds.',
    );
  }

  /// Sends [text] on [channel].
  Future<LeadActionOutcome> sendMessage(ConsentChannel channel, String text) {
    final profile = state.value;
    if (text.trim().isEmpty) {
      return Future.value(const LeadActionFailed('Write a message first.'));
    }
    if (profile != null && !profile.canContact(channel)) {
      return Future.value(
        LeadActionFailed("This lead hasn't agreed to ${channel.label}."),
      );
    }
    // TODO(backend): POST /api/leads/{id}/messages {channel, text}.
    return _run(
      LeadAction.message,
      (current) => current.copyWith(
        timeline: [
          _event(TimelineKind.message, '${channel.label} sent', text.trim()),
          ...current.timeline,
        ],
      ),
      '${channel.label} sent to ${_firstName(profile)}.',
    );
  }

  /// Records that the lead withdrew consent on [channel].
  Future<LeadActionOutcome> withdrawConsent(ConsentChannel channel) {
    // TODO(backend): PUT /api/leads/{id}/consent {channel, granted: false}.
    return _run(
      LeadAction.consent,
      (current) => current.copyWith(
        consents: [
          for (final consent in current.consents)
            consent.channel == channel ? _withdrawn(consent) : consent,
        ],
        timeline: [
          _event(
            TimelineKind.consent,
            '${channel.label} consent withdrawn',
            'Recorded by ${_agentName()}',
          ),
          ...current.timeline,
        ],
      ),
      '${channel.label} consent withdrawn.',
    );
  }

  /// Stops all contact with the lead for good.
  Future<LeadActionOutcome> markDoNotContact() {
    // TODO(backend): POST /api/leads/{id}/suppress (adds to the suppression
    // list and stops every journey).
    return _run(LeadAction.doNotContact, (current) {
      final lead = current.lead.copyWith(
        status: LeadStatus.suppressed,
        lastActivity: 'Marked do-not-contact',
      );
      _updateLeadsList(lead);
      return current.copyWith(
        lead: lead,
        consents: [for (final c in current.consents) _withdrawn(c)],
        timeline: [
          _event(
            TimelineKind.consent,
            'Marked do-not-contact',
            'All channels stopped by ${_agentName()}',
          ),
          ...current.timeline,
        ],
      );
    }, "${_firstName(state.value)} won't be contacted again.");
  }

  /// Records a viewing booked from the Book viewing screen (the booking
  /// request already ran there).
  void recordViewingBooked(Viewing viewing) {
    final profile = state.value;
    if (profile == null) return;
    final lead = profile.lead.copyWith(
      status: LeadStatus.viewingBooked,
      lastActivity: 'Viewing booked: ${viewing.property}',
    );
    _updateLeadsList(lead);
    state = AsyncData(
      profile.copyWith(
        lead: lead,
        timeline: [
          _event(
            TimelineKind.viewing,
            'Viewing booked',
            '${viewing.property} · awaiting the lead\'s confirmation',
          ),
          ...profile.timeline,
        ],
      ),
    );
  }

  /// Runs a simulated request for [action], then applies [apply].
  Future<LeadActionOutcome> _run(
    LeadAction action,
    LeadProfile Function(LeadProfile current) apply,
    String successMessage,
  ) async {
    final profile = state.value;
    if (profile == null) return const LeadActionFailed(busyMessage);
    if (profile.busyAction != null) return const LeadActionFailed(busyMessage);
    state = AsyncData(profile.copyWith(busyAction: () => action));
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    final current = state.value;
    if (!ref.mounted || current == null) {
      return const LeadActionFailed(busyMessage);
    }
    state = AsyncData(apply(current).copyWith(busyAction: () => null));
    return LeadActionSucceeded(successMessage);
  }

  /// [consent] marked withdrawn now by the signed-in user.
  ChannelConsent _withdrawn(ChannelConsent consent) => ChannelConsent(
    channel: consent.channel,
    isGranted: false,
    evidence: 'Withdrawn, recorded by ${_agentName()}',
    recordedAt: DateTime.now(),
  );

  /// A timeline event happening now.
  TimelineEvent _event(TimelineKind kind, String title, String detail) =>
      TimelineEvent(
        at: DateTime.now(),
        kind: kind,
        title: title,
        detail: detail,
      );

  /// Keeps the Leads list in step when it is loaded.
  void _updateLeadsList(Lead lead) {
    if (ref.exists(leadsControllerProvider)) {
      ref.read(leadsControllerProvider.notifier).replaceLead(lead);
    }
  }

  /// Name of the signed-in user for evidence lines.
  String _agentName() {
    final user = ref.read(currentUserProvider);
    if (user == null) return 'you';
    return user.name.isEmpty ? user.email : user.name;
  }

  /// The lead's first name, or "the lead".
  static String _firstName(LeadProfile? profile) =>
      profile?.lead.name.split(' ').first ?? 'the lead';
}

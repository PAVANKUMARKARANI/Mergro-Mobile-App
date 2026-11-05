import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/no_automatic_retry.dart';
import '../../leads/controllers/leads_controller.dart';
import '../../leads/models/lead.dart';
import '../../leads/repositories/leads_repository.dart';
import '../../viewings/models/viewing.dart';
import '../models/lead_insights.dart';
import '../models/lead_profile.dart';

/// The profile of one lead (screen 13), by lead id. Failed loads are not
/// retried automatically: the screen shows the error with a Retry button.
final leadProfileControllerProvider = AsyncNotifierProvider.autoDispose
    .family<LeadProfileController, LeadProfile, String>(
      LeadProfileController.new,
      retry: noAutomaticRetry,
    );

/// Loads a lead's profile from the API and runs its actions.
class LeadProfileController extends AsyncNotifier<LeadProfile> {
  /// Creates the controller for [leadId].
  LeadProfileController(this.leadId);

  /// The lead shown.
  final String leadId;

  /// Message when an action is already running.
  static const String busyMessage = 'Still working on the last action…';

  LeadsRepository get _repository => ref.read(leadsRepositoryProvider);

  /// Loads the profile and its timeline.
  @override
  Future<LeadProfile> build() => _repository.fetchProfile(leadId);

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
    // TODO(backend): the server only records the request until the Voice AI
    // dialler exists; then say "Mergro will call … within 60 seconds".
    return _run(
      LeadAction.callBack,
      (repository) => repository.requestCallBack(leadId),
      'Call-back requested for ${_firstName(profile)}. AI calling starts '
      'once telephony is connected.',
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
    // TODO(backend): the server only records the message until the SMS /
    // WhatsApp / email connectors exist.
    return _run(
      LeadAction.message,
      (repository) => repository.sendMessage(leadId, channel, text.trim()),
      '${channel.label} to ${_firstName(profile)} recorded. Sending starts '
      'once messaging is connected.',
    );
  }

  /// Records that the lead withdrew consent on [channel].
  Future<LeadActionOutcome> withdrawConsent(ConsentChannel channel) => _run(
    LeadAction.consent,
    (repository) => repository.withdrawConsent(leadId, channel),
    '${channel.label} consent withdrawn.',
  );

  /// Stops all contact with the lead for good.
  Future<LeadActionOutcome> markDoNotContact() => _run(
    LeadAction.doNotContact,
    (repository) => repository.suppress(leadId),
    "${_firstName(state.value)} won't be contacted again.",
  );

  /// Records a viewing booked from the Book viewing screen (the booking
  /// request already ran there).
  void recordViewingBooked(Viewing viewing) {
    // TODO(backend): re-fetch the profile once POST /api/viewings exists;
    // until then the booking only changes this device's copy.
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
          TimelineEvent(
            at: DateTime.now(),
            kind: TimelineKind.viewing,
            title: 'Viewing booked',
            detail: '${viewing.property} · awaiting the lead\'s confirmation',
          ),
          ...profile.timeline,
        ],
      ),
    );
  }

  /// Runs [request] for [action], then reloads the profile so consent,
  /// status and timeline come from the server.
  Future<LeadActionOutcome> _run(
    LeadAction action,
    Future<void> Function(LeadsRepository repository) request,
    String successMessage,
  ) async {
    final profile = state.value;
    if (profile == null || profile.busyAction != null) {
      return const LeadActionFailed(busyMessage);
    }
    state = AsyncData(profile.copyWith(busyAction: () => action));
    final repository = _repository;
    try {
      await request(repository);
    } on ApiException catch (error) {
      _clearBusy();
      return LeadActionFailed(error.message);
    }
    final updated = await _reload(repository);
    if (!ref.mounted) return LeadActionSucceeded(successMessage);
    if (updated != null) {
      _updateLeadsList(updated.lead);
      state = AsyncData(updated);
    } else {
      _clearBusy();
    }
    return LeadActionSucceeded(successMessage);
  }

  /// The profile after an action, or null when it could not be reloaded
  /// (the action itself succeeded; pull to refresh catches up).
  Future<LeadProfile?> _reload(LeadsRepository repository) async {
    try {
      return await repository.fetchProfile(leadId);
    } on ApiException catch (error) {
      AppLogger.warning('Lead profile reload failed: ${error.kind.name}');
      return null;
    }
  }

  /// Ends the running action without other changes.
  void _clearBusy() {
    final current = state.value;
    if (!ref.mounted || current == null) return;
    state = AsyncData(current.copyWith(busyAction: () => null));
  }

  /// Keeps the Leads list in step when it is loaded.
  void _updateLeadsList(Lead lead) {
    if (ref.exists(leadsControllerProvider)) {
      ref.read(leadsControllerProvider.notifier).replaceLead(lead);
    }
  }

  /// The lead's first name, or "the lead".
  static String _firstName(LeadProfile? profile) =>
      profile?.lead.name.split(' ').first ?? 'the lead';
}

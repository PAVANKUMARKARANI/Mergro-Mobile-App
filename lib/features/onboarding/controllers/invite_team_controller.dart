import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/validation/form_validators.dart';
import '../../auth/models/app_user.dart';
import '../models/agent_setup_drafts.dart';
import '../models/onboarding_flow_models.dart';
import '../repositories/onboarding_repository.dart';

/// Admin step 6 draft; kept alive so values survive Back / Next.
final inviteTeamControllerProvider =
    NotifierProvider<InviteTeamController, InviteTeamDraft>(
      InviteTeamController.new,
    );

/// Collects team invites and sends them.
class InviteTeamController extends Notifier<InviteTeamDraft> {
  /// Error shown for a duplicate email.
  static const String duplicateMessage = 'This email is already invited.';

  /// Message returned when sending is already running.
  static const String busyMessage = 'Sending invites…';

  /// Starts with no invites.
  @override
  InviteTeamDraft build() => const InviteTeamDraft();

  /// Adds an invite as a sales agent. Returns an error message, or null when
  /// the email was added.
  String? addInvite(String email) {
    final normalized = email.trim().toLowerCase();
    final error = FormValidators.email(normalized);
    if (error != null) return error;
    if (state.invites.any((invite) => invite.email == normalized)) {
      return duplicateMessage;
    }
    state = state.copyWith(
      invites: [
        ...state.invites,
        TeamInvite(email: normalized),
      ],
      errorMessage: () => null,
    );
    return null;
  }

  /// Removes the invite for [email].
  void removeInvite(String email) => state = state.copyWith(
    invites: state.invites.where((invite) => invite.email != email).toList(),
    errorMessage: () => null,
  );

  /// Changes the role of the invite for [email].
  void setRole(String email, UserRole role) => state = state.copyWith(
    invites: [
      for (final invite in state.invites)
        invite.email == email ? invite.copyWith(role: role) : invite,
    ],
  );

  /// Sends every pending invite. Sent invites leave the list; failed ones
  /// stay, with the reasons in `errorMessage`, so the admin can fix or
  /// remove them and continue again.
  Future<StepActionOutcome> sendInvites() async {
    if (state.isSending) return const StepActionFailed(busyMessage);
    if (state.invites.isEmpty) return const StepActionSucceeded();
    state = state.copyWith(isSending: true, errorMessage: () => null);
    try {
      final result = await ref
          .read(onboardingRepositoryProvider)
          .sendInvites(state.invites);
      if (!ref.mounted) return const StepActionFailed(busyMessage);
      final failed = state.invites
          .where((invite) => !result.sentEmails.contains(invite.email))
          .toList();
      final message = failed.isEmpty
          ? null
          : failed
                .map(
                  (invite) =>
                      '${invite.email}: '
                      '${result.failures[invite.email] ?? 'Not sent.'}',
                )
                .join('\n');
      state = state.copyWith(
        isSending: false,
        invites: failed,
        sentCount: state.sentCount + result.sentEmails.length,
        errorMessage: () => message,
      );
      return message == null
          ? const StepActionSucceeded()
          : StepActionFailed(message);
    } on ApiException catch (error) {
      if (!ref.mounted) return const StepActionFailed(busyMessage);
      state = state.copyWith(
        isSending: false,
        errorMessage: () => error.message,
      );
      return StepActionFailed.from(error);
    }
  }
}

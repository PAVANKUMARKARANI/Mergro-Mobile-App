import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/validation/form_validators.dart';
import '../../auth/models/app_user.dart';
import '../models/agent_setup_drafts.dart';

/// Admin step 6 draft; kept alive so values survive Back / Next.
final inviteTeamControllerProvider =
    NotifierProvider<InviteTeamController, InviteTeamDraft>(
      InviteTeamController.new,
    );

/// Collects team invites and sends them.
class InviteTeamController extends Notifier<InviteTeamDraft> {
  /// Error shown for a duplicate email.
  static const String duplicateMessage = 'This email is already invited.';

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
    );
    return null;
  }

  /// Removes the invite for [email].
  void removeInvite(String email) => state = state.copyWith(
    invites: state.invites.where((invite) => invite.email != email).toList(),
  );

  /// Changes the role of the invite for [email].
  void setRole(String email, UserRole role) => state = state.copyWith(
    invites: [
      for (final invite in state.invites)
        invite.email == email ? invite.copyWith(role: role) : invite,
    ],
  );

  /// Sends every pending invite. Returns true once sent.
  Future<bool> sendInvites() async {
    if (state.isSending) return false;
    if (state.invites.isEmpty) return true;
    state = state.copyWith(isSending: true);

    // TODO(backend): POST /team/invites [{email, role}] — emails each invitee
    // a sign-up link; surface per-email failures.
    await Future<void>.delayed(AppDurations.simulatedNetwork);
    if (!ref.mounted) return false;

    state = state.copyWith(isSending: false, sentCount: state.invites.length);
    return true;
  }
}

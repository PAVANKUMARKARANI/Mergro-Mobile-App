import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// The signed-in user, or null when signed out. App-wide (not auto-disposed).
final currentUserProvider = NotifierProvider<CurrentUserController, AppUser?>(
  CurrentUserController.new,
);

/// Holds the current session's user.
class CurrentUserController extends Notifier<AppUser?> {
  /// Starts signed out; the splash restores a stored session.
  @override
  AppUser? build() => null;

  /// Stores the user of a successful sign-in or restored session.
  void setUser(AppUser user) => state = user;

  /// Reloads the user from the server (e.g. after onboarding renamed the
  /// brokerage). Keeps the current user when that fails.
  Future<void> refresh() async {
    try {
      final user = await ref.read(authRepositoryProvider).fetchCurrentUser();
      if (ref.mounted) state = user;
    } on ApiException catch (error) {
      AppLogger.warning('Refreshing the user failed', error);
    }
  }

  /// Ends the session on the server and on this device.
  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (!ref.mounted) return;
    state = null;
  }
}

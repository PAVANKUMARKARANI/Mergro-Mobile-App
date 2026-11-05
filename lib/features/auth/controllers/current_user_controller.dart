import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';

/// The signed-in user, or null when signed out. App-wide (not auto-disposed).
final currentUserProvider = NotifierProvider<CurrentUserController, AppUser?>(
  CurrentUserController.new,
);

/// Holds the current session's user.
class CurrentUserController extends Notifier<AppUser?> {
  /// Starts signed out.
  @override
  AppUser? build() => null;

  /// Stores the user returned by a successful sign-in.
  void setUser(AppUser user) {
    // TODO(backend): replace with the real session (persist tokens, GET /me).
    state = user;
  }

  /// Signs out locally.
  void clear() {
    // TODO(backend): POST /auth/logout and clear stored tokens.
    state = null;
  }
}

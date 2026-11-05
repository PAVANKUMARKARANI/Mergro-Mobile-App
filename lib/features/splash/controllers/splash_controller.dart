import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/splash_destination.dart';

/// Resolves where the app should go after the splash.
final splashControllerProvider =
    AsyncNotifierProvider.autoDispose<SplashController, SplashDestination>(
      SplashController.new,
    );

/// Decides the first destination while the splash animation plays.
class SplashController extends AsyncNotifier<SplashDestination> {
  /// Restores the session and returns the destination.
  ///
  /// Always returns [SplashDestination.login] until the backend exists.
  @override
  Future<SplashDestination> build() async {
    // TODO(backend): restore session and onboarding status
    // (read the stored refresh token → GET /me → login | onboarding | home).
    return SplashDestination.login;
  }
}

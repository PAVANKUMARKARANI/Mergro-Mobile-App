import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/splash_destination.dart';

/// Resolves where the app should go after the splash.
final splashControllerProvider =
    AsyncNotifierProvider.autoDispose<SplashController, SplashDestination>(
      SplashController.new,
    );

/// Decides the first destination while the splash animation plays.
class SplashController extends AsyncNotifier<SplashDestination> {
  /// Restores a stored session: no session → login; otherwise onboarding or
  /// home depending on the user's onboarding state. When the server can't be
  /// reached the user goes to login; the stored token is kept for next time.
  @override
  Future<SplashDestination> build() async {
    try {
      final user = await ref.read(authRepositoryProvider).restoreSession();
      if (user == null || !ref.mounted) return SplashDestination.login;
      ref.read(currentUserProvider.notifier).setUser(user);
      return user.isOnboardingComplete
          ? SplashDestination.home
          : SplashDestination.onboarding;
    } on ApiException catch (error) {
      AppLogger.warning('Session restore failed', error);
      return SplashDestination.login;
    } catch (error, stackTrace) {
      // E.g. secure storage unavailable: never leave the user on the splash.
      AppLogger.error('Session restore crashed', error, stackTrace);
      return SplashDestination.login;
    }
  }
}

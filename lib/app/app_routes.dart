import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/controllers/current_user_controller.dart';
import '../features/auth/models/app_user.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/widgets/company_sso_sheet.dart';
import '../features/auth/widgets/forgot_password_sheet.dart';
import '../features/auth/widgets/request_access_sheet.dart';
import '../features/home/screens/home_placeholder_screen.dart';
import '../features/onboarding/controllers/onboarding_providers.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/onboarding_success_screen.dart';
import '../features/splash/models/splash_destination.dart';
import '../features/splash/screens/splash_screen.dart';
import '../shared/ui.dart';

/// All app navigation in one place. Screens receive navigation callbacks
/// from here and never push routes themselves.
abstract final class AppRoutes {
  /// The first screen shown after launch.
  static Widget initialScreen() => Builder(
    builder: (context) => SplashScreen(
      onFinished: (destination) => _openDestination(context, destination),
    ),
  );

  /// Login, with its sheets wired up.
  static Widget login() => Builder(
    builder: (context) => LoginScreen(
      onSignedIn: (user) => _replaceAll(context, _afterSignIn(user)),
      onForgotPassword: (email) => _showForgotPassword(context, email),
      onCompanySso: () => _showCompanySso(context),
      onRequestAccess: () => _showRequestAccess(context),
    ),
  );

  /// Role-based onboarding.
  static Widget onboarding() => Builder(
    builder: (context) => OnboardingScreen(
      onFinished: (role) => _replaceAll(context, _onboardingSuccess(role)),
    ),
  );

  /// Success screen after onboarding; clears onboarding state on the way
  /// to Home (the onboarding screen is gone by then, so nothing flickers).
  static Widget _onboardingSuccess(UserRole role) => Builder(
    builder: (context) => OnboardingSuccessScreen.forRole(
      role: role,
      onContinue: () {
        resetOnboarding(ProviderScope.containerOf(context, listen: false));
        _replaceAll(context, home());
      },
    ),
  );

  /// Home Dashboard placeholder.
  static Widget home() => Builder(
    builder: (context) =>
        HomePlaceholderScreen(onRestartPreview: () => _restartPreview(context)),
  );

  /// Maps the splash result to a screen.
  static void _openDestination(
    BuildContext context,
    SplashDestination destination,
  ) {
    final screen = switch (destination) {
      SplashDestination.login => login(),
      SplashDestination.onboarding => onboarding(),
      SplashDestination.home => home(),
    };
    _replaceAll(context, screen);
  }

  /// Where a freshly signed-in user goes.
  // TODO(backend): skip onboarding when GET /me says it is already complete.
  static Widget _afterSignIn(AppUser user) => onboarding();

  /// Clears the user and all onboarding state, then returns to the splash.
  static void _restartPreview(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(currentUserProvider.notifier).clear();
    resetOnboarding(container);
    _replaceAll(context, initialScreen());
  }

  /// Replaces the whole stack with [screen] using a 300 ms fade (instant
  /// when reduced motion is on).
  static void _replaceAll(BuildContext context, Widget screen) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppDurations.routeFade;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (_, _, _) => screen,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  /// Opens a scroll-controlled bottom sheet.
  static Future<T?> _showSheet<T>(
    BuildContext context,
    Widget Function(BuildContext sheetContext) builder,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: builder,
    );
  }

  /// Forgot-password sheet.
  static void _showForgotPassword(BuildContext context, String email) {
    _showSheet<void>(
      context,
      (sheetContext) => ForgotPasswordSheet(
        initialEmail: email,
        onDone: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  /// Company-SSO sheet; navigates on when it returns a user.
  static Future<void> _showCompanySso(BuildContext context) async {
    final user = await _showSheet<AppUser>(
      context,
      (sheetContext) => CompanySsoSheet(
        onSignedIn: (user) => Navigator.of(sheetContext).pop(user),
      ),
    );
    if (user == null || !context.mounted) return;
    _replaceAll(context, _afterSignIn(user));
  }

  /// Request-access info sheet.
  static void _showRequestAccess(BuildContext context) {
    _showSheet<void>(
      context,
      (sheetContext) =>
          RequestAccessSheet(onClose: () => Navigator.of(sheetContext).pop()),
    );
  }
}

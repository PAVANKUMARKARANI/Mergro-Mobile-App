import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/controllers/current_user_controller.dart';
import '../features/auth/models/app_user.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/widgets/company_sso_sheet.dart';
import '../features/auth/widgets/forgot_password_sheet.dart';
import '../features/auth/widgets/request_access_sheet.dart';
import '../features/calls/screens/live_calls_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/hot_leads/screens/hot_leads_screen.dart';
import '../features/leads/screens/leads_screen.dart';
import '../features/leads/widgets/lead_filter_sheet.dart';
import '../features/nurture/screens/nurture_screen.dart';
import '../features/onboarding/controllers/onboarding_providers.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/onboarding_success_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/shell/controllers/app_shell_controller.dart';
import '../features/shell/models/app_tab.dart';
import '../features/shell/screens/app_shell.dart';
import '../features/shell/screens/more_screen.dart';
import '../features/splash/models/splash_destination.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/viewings/screens/viewings_screen.dart';
import '../shared/ui.dart';

part 'app_routes_shell.dart';

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
      onSessionExpired: () => _signOut(context),
    ),
  );

  /// Success screen after onboarding; clears onboarding state on the way
  /// to Home (the onboarding screen is gone by then, so nothing flickers).
  static Widget _onboardingSuccess(UserRole role) => Builder(
    builder: (context) => OnboardingSuccessScreen.forRole(
      role: role,
      onContinue: () async {
        final container = ProviderScope.containerOf(context, listen: false);
        resetOnboarding(container);
        // Picks up the new brokerage name and completed state for Home.
        await container.read(currentUserProvider.notifier).refresh();
        if (context.mounted) _replaceAll(context, home());
      },
    ),
  );

  /// The signed-in app: Home dashboard and role-based tabs.
  static Widget home() => Builder(
    builder: (context) => AppShell(
      tabBuilder: (tab) =>
          _ShellRoutes.tabRoot(context, tab, () => _signOut(context)),
    ),
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

  /// Where a freshly signed-in user goes: Home once onboarding is done.
  static Widget _afterSignIn(AppUser user) =>
      user.isOnboardingComplete ? home() : onboarding();

  /// Ends the session, clears all onboarding state and returns to Login.
  static Future<void> _signOut(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(currentUserProvider.notifier).signOut();
    resetOnboarding(container);
    if (!context.mounted) return;
    _replaceAll(context, login());
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

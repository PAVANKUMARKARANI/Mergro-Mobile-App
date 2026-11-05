import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/current_user_controller.dart';
import '../../auth/models/app_user.dart';
import '../models/app_tab.dart';

/// Selected bottom-bar tab of the app shell.
final appShellControllerProvider =
    NotifierProvider.autoDispose<AppShellController, AppTab>(
      AppShellController.new,
    );

/// Switches bar tabs. Destinations outside the bar are pushed by AppRoutes.
class AppShellController extends Notifier<AppTab> {
  /// Starts on Home.
  @override
  AppTab build() => AppTab.home;

  /// Bar tabs for the signed-in user's role.
  List<AppTab> get barTabs => AppTab.barTabsFor(
    ref.read(currentUserProvider)?.role ?? UserRole.salesAgent,
  );

  /// Selects [tab] if it is in the bar and returns true; returns false when
  /// it must be opened as its own screen instead.
  bool select(AppTab tab) {
    if (!barTabs.contains(tab)) return false;
    state = tab;
    return true;
  }
}

part of 'app_routes.dart';

/// Navigation inside the signed-in app shell (screens 4–11). Part of
/// [AppRoutes] so all navigation stays in one library.
abstract final class _ShellRoutes {
  /// Root screen of [tab]. In the bar it has no back button; pushed from
  /// "More" or a dashboard link it gets one automatically.
  static Widget tabRoot(
    BuildContext context,
    AppTab tab,
    VoidCallback onSignOut,
  ) {
    void open(AppTab target) => openTab(context, target, onSignOut);
    return switch (tab) {
      AppTab.home => HomeScreen(onOpenTab: open),
      AppTab.leads => LeadsScreen(
        onOpenFilters: () => showLeadFilters(context),
      ),
      AppTab.liveCalls => const LiveCallsScreen(),
      AppTab.hotLeads => const HotLeadsScreen(),
      AppTab.viewings => const ViewingsScreen(),
      AppTab.nurture => const NurtureScreen(),
      AppTab.profile => ProfileScreen(onSignOut: onSignOut),
      AppTab.more => MoreScreen(onOpenTab: open),
    };
  }

  /// Switches to [tab] when it is in the bar; otherwise pushes it as its
  /// own screen.
  static void openTab(
    BuildContext context,
    AppTab tab,
    VoidCallback onSignOut,
  ) {
    final container = ProviderScope.containerOf(context, listen: false);
    if (container.read(appShellControllerProvider.notifier).select(tab)) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pushedContext) => tabRoot(pushedContext, tab, onSignOut),
      ),
    );
  }

  /// Lead search filters (screen 11) as a bottom sheet.
  static void showLeadFilters(BuildContext context) {
    AppRoutes._showSheet<void>(
      context,
      (sheetContext) =>
          LeadFilterSheet(onDone: () => Navigator.of(sheetContext).pop()),
    );
  }
}

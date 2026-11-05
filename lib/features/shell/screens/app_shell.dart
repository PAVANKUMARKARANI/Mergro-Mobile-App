import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/ui.dart';
import '../../auth/controllers/current_user_controller.dart';
import '../../auth/models/app_user.dart';
import '../../hot_leads/controllers/hot_leads_controller.dart';
import '../../hot_leads/models/handoff.dart';
import '../controllers/app_shell_controller.dart';
import '../models/app_tab.dart';

/// The signed-in app: role-based tabs in a bottom bar (a side rail at
/// ≥ 600 px). Tabs are built on first visit and then kept alive.
class AppShell extends ConsumerStatefulWidget {
  /// Creates the shell; [tabBuilder] builds each tab's root screen.
  const AppShell({super.key, required this.tabBuilder});

  /// Builds the root screen of a bar tab (wired by AppRoutes).
  final Widget Function(AppTab tab) tabBuilder;

  /// Creates the state tracking visited tabs.
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

/// Remembers which tabs were opened so they are built lazily.
class _AppShellState extends ConsumerState<AppShell> {
  final Set<AppTab> _visited = {AppTab.home};

  /// Builds the bar or rail around the selected tab.
  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.salesAgent;
    final tabs = AppTab.barTabsFor(role);
    final selected = ref.watch(appShellControllerProvider);
    final index = tabs.indexOf(selected).clamp(0, tabs.length - 1);
    _visited.add(tabs[index]);
    final hotWaiting = ref.watch(
      hotLeadsControllerProvider.select(
        (items) =>
            items.value
                ?.where((item) => item.status == HandoffStatus.waiting)
                .length ??
            0,
      ),
    );
    final body = IndexedStack(
      index: index,
      children: [
        for (final tab in tabs)
          _visited.contains(tab) ? widget.tabBuilder(tab) : const SizedBox(),
      ],
    );
    void onSelected(int i) =>
        ref.read(appShellControllerProvider.notifier).select(tabs[i]);
    final isWide =
        MediaQuery.sizeOf(context).width >= AppSizes.tabletBreakpoint;
    return PopScope(
      // System back returns to Home before leaving the app.
      canPop: tabs[index] == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onSelected(0);
      },
      child: isWide
          ? Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: onSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final tab in tabs)
                        NavigationRailDestination(
                          icon: _TabIcon(tab: tab, hotWaiting: hotWaiting),
                          label: Text(tab.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: AppSizes.borderThin),
                  Expanded(child: body),
                ],
              ),
            )
          : Scaffold(
              body: body,
              bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: onSelected,
                destinations: [
                  for (final tab in tabs)
                    NavigationDestination(
                      icon: _TabIcon(tab: tab, hotWaiting: hotWaiting),
                      label: tab.label,
                      tooltip: tab == AppTab.hotLeads && hotWaiting > 0
                          ? '${tab.label}, $hotWaiting waiting'
                          : tab.label,
                    ),
                ],
              ),
            ),
    );
  }
}

/// Tab icon; Hot leads shows a badge with the number waiting.
class _TabIcon extends StatelessWidget {
  /// Creates the icon.
  const _TabIcon({required this.tab, required this.hotWaiting});

  /// The tab.
  final AppTab tab;

  /// Handoffs waiting, for the Hot leads badge.
  final int hotWaiting;

  /// Builds the icon.
  @override
  Widget build(BuildContext context) {
    final icon = Icon(tab.icon);
    if (tab != AppTab.hotLeads) return icon;
    return Badge(
      isLabelVisible: hotWaiting > 0,
      label: Text('$hotWaiting'),
      child: icon,
    );
  }
}

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/widgets.dart';

import '../../auth/models/app_user.dart';

/// Main destinations of the signed-in app (screens 4–10) plus "More".
enum AppTab {
  /// Screen 4.
  home('Home', LucideIcons.layoutDashboard),

  /// Screen 5.
  leads('Leads', LucideIcons.users),

  /// Screen 6.
  liveCalls('Live calls', LucideIcons.phoneCall),

  /// Screen 7.
  hotLeads('Hot leads', LucideIcons.flame),

  /// Screen 8.
  viewings('Viewings', LucideIcons.calendarCheck),

  /// Screen 9.
  nurture('Nurture', LucideIcons.send),

  /// Screen 10.
  profile('Profile', LucideIcons.circleUser),

  /// Lists the destinations that don't fit in the bar.
  more('More', LucideIcons.ellipsis);

  /// Creates a tab.
  const AppTab(this.label, this.icon);

  /// Bar label.
  final String label;

  /// Bar icon.
  final IconData icon;

  /// Bar tabs for [role] (at most 5). Agents work hot leads and viewings
  /// first; admins and team leads watch leads and live calls.
  static List<AppTab> barTabsFor(UserRole role) => switch (role) {
    UserRole.salesAgent => const [home, hotLeads, leads, viewings, more],
    UserRole.brokerageAdmin ||
    UserRole.teamLead ||
    UserRole.operations ||
    UserRole.complianceReviewer => const [
      home,
      leads,
      liveCalls,
      hotLeads,
      more,
    ],
  };

  /// Destinations listed under "More" for [role]: everything not in the bar.
  static List<AppTab> moreTabsFor(UserRole role) {
    final bar = barTabsFor(role);
    return values.where((tab) => tab != more && !bar.contains(tab)).toList();
  }
}

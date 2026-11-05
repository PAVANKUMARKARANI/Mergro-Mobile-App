import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/controllers/current_user_controller.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/shell/controllers/app_shell_controller.dart';
import 'package:mergro_ai_voice_assistant/features/shell/models/app_tab.dart';

import '../../helpers/fakes.dart';

void main() {
  test('every role gets Home first, More last and at most 5 tabs', () {
    for (final role in UserRole.values) {
      final bar = AppTab.barTabsFor(role);
      expect(bar.length, lessThanOrEqualTo(5), reason: role.name);
      expect(bar.first, AppTab.home);
      expect(bar.last, AppTab.more);
    }
  });

  test('bar plus More reach every destination exactly once', () {
    for (final role in UserRole.values) {
      final reachable = [
        ...AppTab.barTabsFor(role).where((tab) => tab != AppTab.more),
        ...AppTab.moreTabsFor(role),
      ];
      expect(reachable.toSet().length, reachable.length, reason: role.name);
      expect(
        reachable.toSet(),
        AppTab.values.where((tab) => tab != AppTab.more).toSet(),
      );
    }
  });

  test('agents get hot leads and viewings; admins get live calls', () {
    expect(
      AppTab.barTabsFor(UserRole.salesAgent),
      containsAll([AppTab.hotLeads, AppTab.viewings]),
    );
    expect(
      AppTab.barTabsFor(UserRole.brokerageAdmin),
      containsAll([AppTab.leads, AppTab.liveCalls]),
    );
  });

  test('the shell selects bar tabs and refuses the rest', () {
    final container = fakeContainer();
    container
        .read(currentUserProvider.notifier)
        .setUser(testUser(UserRole.salesAgent));
    container.listen(appShellControllerProvider, (_, _) {});
    final shell = container.read(appShellControllerProvider.notifier);

    expect(shell.select(AppTab.viewings), isTrue);
    expect(container.read(appShellControllerProvider), AppTab.viewings);
    expect(shell.select(AppTab.liveCalls), isFalse, reason: 'under More');
    expect(container.read(appShellControllerProvider), AppTab.viewings);
  });
}

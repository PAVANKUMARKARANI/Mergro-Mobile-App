import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_mode_controller.dart';
import '../shared/ui.dart';
import 'app_routes.dart';

/// Root widget: Material 3 light/dark themes, following the user's
/// Light / Dark / System choice (Profile → Appearance).
class MergroApp extends ConsumerWidget {
  /// Creates the root widget.
  const MergroApp({super.key});

  /// App title shown by the OS task switcher.
  static const String title = 'Mergro';

  /// Builds the [MaterialApp].
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      builder: (context, child) => _withStatusBarStyle(context, child),
      home: AppRoutes.initialScreen(),
    );
  }

  /// Default status-bar icons that contrast with the theme background.
  /// Screens with navy headers (Splash, Login) override this with their own
  /// region; without this default, their light icons would stick on the
  /// light screens that follow.
  Widget _withStatusBarStyle(BuildContext context, Widget? child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: child ?? const SizedBox.shrink(),
    );
  }
}

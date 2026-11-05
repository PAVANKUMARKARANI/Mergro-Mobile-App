import 'package:flutter/services.dart';

import '../shared/ui.dart';
import 'app_routes.dart';

/// Root widget: Material 3 light/dark themes that follow the system setting.
class MergroApp extends StatelessWidget {
  /// Creates the root widget.
  const MergroApp({super.key});

  /// App title shown by the OS task switcher.
  static const String title = 'Mergro';

  /// Builds the [MaterialApp].
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
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

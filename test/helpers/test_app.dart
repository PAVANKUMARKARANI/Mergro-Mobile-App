import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/core/theme/app_theme.dart';
import 'package:mergro_ai_voice_assistant/core/theme/app_typography.dart';

import 'fakes.dart';

/// Smallest supported phone size.
const Size smallPhone = Size(360, 780);

/// Largest text scale the app must support without overflow.
const double maxTextScale = 1.3;

/// Pumps [child] in a themed app on a [smallPhone] at [maxTextScale].
/// Pass [container] to share provider state with the test; otherwise the
/// app gets [fakeOverrides] so nothing reaches the network.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  bool isDark = false,
  bool disableAnimations = false,
  Size size = smallPhone,
  ProviderContainer? container,
}) async {
  AppTypography.useGoogleFonts = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final app = MaterialApp(
    theme: isDark ? AppTheme.dark : AppTheme.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(maxTextScale),
          disableAnimations: disableAnimations,
        ),
        child: child,
      ),
    ),
  );
  await tester.pumpWidget(
    container == null
        ? ProviderScope(overrides: fakeOverrides(), child: app)
        : UncontrolledProviderScope(container: container, child: app),
  );
}

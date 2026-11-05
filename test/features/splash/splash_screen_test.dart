import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/splash/models/splash_destination.dart';
import 'package:mergro_ai_voice_assistant/features/splash/screens/splash_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('finishes with login only after the 2.4 s animation', (
    tester,
  ) async {
    final destinations = <SplashDestination>[];
    await pumpTestApp(tester, SplashScreen(onFinished: destinations.add));

    await tester.pump(const Duration(milliseconds: 2000));
    expect(destinations, isEmpty);

    await tester.pump(const Duration(milliseconds: 500));
    expect(destinations, [SplashDestination.login]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion holds the final frame for 1.5 s', (tester) async {
    final destinations = <SplashDestination>[];
    await pumpTestApp(
      tester,
      SplashScreen(onFinished: destinations.add),
      disableAnimations: true,
    );

    await tester.pump(const Duration(milliseconds: 1400));
    expect(destinations, isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
    expect(destinations, [SplashDestination.login]);
  });
}

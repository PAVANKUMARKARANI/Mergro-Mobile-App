import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/auth/screens/login_screen.dart';

import '../../helpers/test_app.dart';

/// Builds the login screen recording successful sign-ins in [signedIn].
LoginScreen _buildLogin(List<AppUser> signedIn) => LoginScreen(
  onSignedIn: signedIn.add,
  onForgotPassword: (_) {},
  onCompanySso: () {},
  onRequestAccess: () {},
);

void main() {
  for (final isDark in [false, true]) {
    testWidgets('no overflow at 360 px and 1.3x text, dark=$isDark', (
      tester,
    ) async {
      await pumpTestApp(tester, _buildLogin([]), isDark: isDark);
      await tester.scrollUntilVisible(
        find.text('Request access'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('"wrong" password shows the error banner', (tester) async {
    final signedIn = <AppUser>[];
    await pumpTestApp(tester, _buildLogin(signedIn));
    await tester.enterText(find.byType(TextField).at(0), 'asha@skyline.in');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Email or password is incorrect.'), findsOneWidget);
    expect(signedIn, isEmpty);
  });

  testWidgets('valid credentials call onSignedIn', (tester) async {
    final signedIn = <AppUser>[];
    await pumpTestApp(tester, _buildLogin(signedIn));
    await tester.enterText(find.byType(TextField).at(0), 'asha@skyline.in');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(seconds: 1));

    expect(signedIn.single.email, 'asha@skyline.in');
  });
}

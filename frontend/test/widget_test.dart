import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/main.dart';
import 'package:frontend/router/app_router.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
  });

  Future<void> openLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(child: MyApp(router: createAppRouter())),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('password sign in opens home', (WidgetTester tester) async {
    await openLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter your mobile number'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('phone-field')), '9876543210');
    await tester.enterText(find.byKey(const Key('password-field')), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Ramesh Kumar'), findsOneWidget);
    expect(find.text('More workers'), findsOneWidget);

    await tester.tap(find.text('Ramesh Kumar'));
    await tester.pumpAndSettle();
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('+91 9811111111'), findsOneWidget);

    await tester.tap(find.text('Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Brick work, Plaster'), findsOneWidget);

    await tester.tap(find.text('Edit worker'));
    await tester.pumpAndSettle();
    expect(find.text('Save worker'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Ramesh Updated');
    await tester.tap(find.widgetWithText(FilledButton, 'Save worker'));
    await tester.pumpAndSettle();
    expect(find.text('Ramesh Updated'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workers'));
    await tester.pumpAndSettle();
    expect(find.text('Add worker'), findsOneWidget);
    await tester.tap(find.text('Add worker'));
    await tester.pumpAndSettle();
    expect(find.text('Save worker'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('+91 9876543210'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('sign up and log in toggle between screens', (WidgetTester tester) async {
    await openLogin(tester);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Create an account'), findsOneWidget);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('signup waits for approval and login stays pending', (WidgetTester tester) async {
    await openLogin(tester);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('phone-field')), '9876543210');
    await tester.tap(find.widgetWithText(FilledButton, 'Submit for Review'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for okay'), findsOneWidget);
    expect(find.text('+91 9876543210'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('phone-field')), '9876543210');
    await tester.enterText(find.byKey(const Key('password-field')), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for okay'), findsOneWidget);
    expect(find.text('More workers'), findsNothing);
  });

  testWidgets('otp sign in asks for a code', (WidgetTester tester) async {
    await openLogin(tester);

    await tester.tap(find.text('Login with OTP instead'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('phone-field')), '9876543210');
    await tester.tap(find.widgetWithText(FilledButton, 'Send OTP'));
    await tester.pump();

    expect(find.text('Enter the 6-digit code for +91 9876543210.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otp-field')), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify OTP'));
    await tester.pumpAndSettle();

    expect(find.text('More workers'), findsOneWidget);
  });

  testWidgets('first launch asks for language', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(child: MyApp(router: createAppRouter())),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Choose language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('ગુજરાતી'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('forgot password collects a new password', (WidgetTester tester) async {
    await openLogin(tester);

    await tester.enterText(find.byKey(const Key('phone-field')), '9876543210');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot your password?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Send OTP'));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('reset-otp-field')), '123456');
    await tester.enterText(find.byKey(const Key('new-password-field')), 'newpass1');
    await tester.enterText(find.byKey(const Key('confirm-password-field')), 'newpass1');
    await tester.tap(find.widgetWithText(FilledButton, 'Update password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Password updated. Sign in with your new password.'), findsOneWidget);
  });
}

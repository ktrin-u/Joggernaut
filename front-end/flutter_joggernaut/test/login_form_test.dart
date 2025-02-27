import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/widgets/login_form.dart';
import 'package:flutter_application_1/widgets/recovery_form.dart';

void main() {
  testWidgets('LoginForm has necessary fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    );

    expect(find.text('Log in to your account'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Forgot password button opens recovery form', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    );

    expect(find.byType(RecoverPasswordForm), findsNothing);
    await tester.tap(find.text('Forgot your password?'));
    await tester.pumpAndSettle();
    expect(find.byType(RecoverPasswordForm), findsOneWidget);
  });

  testWidgets('Login button navigates to HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LoginForm()),
      ),
    );

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
}

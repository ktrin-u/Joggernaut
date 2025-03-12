import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/landing_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LandingPage has Joggernaut title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('JOGGERNAUT'), findsOneWidget);
  });

  testWidgets('LandingPage has login button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('LandingPage has sign-up button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Pressing login button shows login form', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('Log In'), findsOneWidget);

    // Tap the login button
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

  });

  testWidgets('Pressing sign-up button shows sign-up form', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('Sign Up'), findsOneWidget);

    // Tap the sign-up button
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

  });
}
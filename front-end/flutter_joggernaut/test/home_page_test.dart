import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/home_page.dart';

void main() {
  testWidgets('HomePage has welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Ernest K.'), findsOneWidget);
  });

  testWidgets('HomePage has menu buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
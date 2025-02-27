import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/landing_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LandingPage has Joggernaut title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LandingPage()));
    expect(find.text('JOGGERNAUT'), findsOneWidget);
  });
}

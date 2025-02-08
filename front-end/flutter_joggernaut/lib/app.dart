import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'utils/constants.dart';

class JoggernautApp extends StatelessWidget {
  const JoggernautApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joggernaut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      home: const LandingPage(),
    );
  }
}

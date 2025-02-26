import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'utils/constants.dart';

class JoggernautApp extends StatefulWidget {
  const JoggernautApp({super.key});

  @override
  State<JoggernautApp> createState() => _JoggernautAppState();
}

class _JoggernautAppState extends State<JoggernautApp> {

  Future clearAll() async {
    await AuthService().logout();
    await AuthService().clearAll();
  }

  @override
  void initState(){
    super.initState();
    clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Joggernaut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      routerConfig: router,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/landing_page.dart';
import '../widgets/home_menu_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(250, 243, 239, 1),
        body: Center(
          child: (
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome,",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                ),
                Text(
                  "Ernest K.",
                  style: TextStyle(
                    fontFamily: 'Big Shoulders Display',
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(90, 155, 212, 1),
                  ),
                ),
                SizedBox(height: 30),
                Wrap(
                  spacing: 50,
                  alignment: WrapAlignment.center,
                  children: [
                    MenuButton(icon: Icons.fitness_center, label: "Workout"),
                    MenuButton(icon: Icons.videogame_asset, label: "Play"),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 50,
                  alignment: WrapAlignment.center,
                  children: [
                    MenuButton(icon: Icons.people, label: "Social"),
                    MenuButton(icon: Icons.person, label: "Profile"),
                  ],
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 50,
                  alignment: WrapAlignment.center,
                  children: [
                    MenuButton(icon: Icons.settings, label: "Settings"),
                  ],
                ),
                SizedBox(height: 80),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LandingPage()),
                      (route) => false, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(90, 30),
                  ),
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}
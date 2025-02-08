import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';
import '../utils/constants.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _titleMovedUpLogin = false;
  bool _titleMovedUpSignUp = false;

  void _moveTitleUpLogin() {
    setState(() => _titleMovedUpLogin = true);
  }

  void _moveTitleUpSignUp() {
    setState(() => _titleMovedUpSignUp = true);
  }

  void _resetTitlePosition() {
    setState(() {
      _titleMovedUpLogin = false;
      _titleMovedUpSignUp = false;
    });
  }

  void _showBottomSheet(BuildContext context, Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(child: form),
        );
      },
    ).whenComplete(() => _resetTitlePosition());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/landing_screen_bg.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _titleMovedUpLogin ? 275 : (_titleMovedUpSignUp ? 110 : MediaQuery.of(context).size.height / 2.5),
            left: 0,
            right: 0,
            child: Center(
              child: Text("JOGGERNAUT", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 69.87, fontFamily: 'Big Shoulders Display')),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _moveTitleUpLogin();
                    _showBottomSheet(context, const LoginForm());
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(165, 30),
                  ),
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Roboto',
                      fontSize: 17.47,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _moveTitleUpSignUp();
                    _showBottomSheet(context, const SignUpForm());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(165, 30),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 51, 51, 1),
                      fontFamily: 'Roboto',
                      fontSize: 17.47,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
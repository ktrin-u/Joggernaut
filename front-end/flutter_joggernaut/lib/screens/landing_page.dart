import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';
import '../utils/constants.dart';
import '../widgets/form_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/landing_screen_bg.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _titleMovedUpLogin
                ? screenHeight * 0.18
                : (_titleMovedUpSignUp ? screenHeight * 0.08 : screenHeight / 3.5),
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "JOGGERNAUT",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.15, 
                  fontFamily: 'Big Shoulders Display',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.08, 
            left: screenWidth * 0.1, 
            right: screenWidth * 0.1, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _moveTitleUpLogin();
                      showFormBottomSheet(
                        context: context, 
                        minHeight: 0.50,
                        maxHeight: 0.70, 
                        form: LoginForm(), 
                        onClose: _resetTitlePosition
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 1.2),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.05),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: screenWidth * 0.045, 
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20), 
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _moveTitleUpSignUp();
                      showFormBottomSheet(
                        context: context, 
                        minHeight: 0.80,
                        maxHeight: 0.80, 
                        form: SignUpForm(), 
                        onClose: _resetTitlePosition
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(screenWidth * 0.4, screenHeight * 0.05),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: screenWidth * 0.045, 
                        fontWeight: FontWeight.w700,
                      ),
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
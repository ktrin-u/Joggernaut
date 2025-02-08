import 'package:flutter/material.dart';

void main() {
  runApp(const JoggernautApp());
}

class JoggernautApp extends StatelessWidget {
  const JoggernautApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Joggernaut',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(250, 243, 239, 1))
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _titleMovedUpLogin = false;
  bool _titleMovedUpSignUp = false;

  void _moveTitleUpLogin() {
    setState(() {
      _titleMovedUpLogin = true;
    });
  }

  void _resetTitlePosition() {
    setState(() {
      _titleMovedUpLogin = false;
      _titleMovedUpSignUp = false;
    });
  }

  void _moveTitleUpSignUp() {
    setState(() {
      _titleMovedUpSignUp = true;
    });
  }

  // Function to Show Bottom Sheet
  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: const LoginForm(),
          )
        );
      },
    ).whenComplete(() {
      _resetTitlePosition(); 
    });
  }

  void _showSignUpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: const SignUpForm(),
          )
        );
      },
    ).whenComplete(() {
      _resetTitlePosition(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/landing_screen_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Title with Animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: (_titleMovedUpLogin) ? 275 : (_titleMovedUpSignUp) ? 110: MediaQuery.of(context).size.height / 2.5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "JOGGERNAUT",
                style: const TextStyle(
                  color: Color.fromRGBO(250, 243, 239, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 69.87,
                  fontFamily: 'Big Shoulders Display',
                ),
              ),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Log-In Button
                OutlinedButton(
                  onPressed: () {
                    _moveTitleUpLogin();
                    _showLoginBottomSheet(context);
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
                // Sign-Up Button
                ElevatedButton(
                  onPressed: () {
                    _moveTitleUpSignUp();
                    _showSignUpBottomSheet(context);
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

// Function to Show Bottom Sheet
void _showRecoverPassBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
    ),
    backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const RecoverPasswordForm(),
      );
    },
  );
}

// Login Form Widget
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
            child: const Text(
              "Log in to your account",
              style: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 33,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Email does not exist.",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 92, 92, 1),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter your email",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showRecoverPassBottomSheet(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(51, 51, 51, 1),
              ),
              child: const Text(
                "Forgot your password?", 
                style: TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.italic,
                  fontSize: 14
                )
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    iconSize: 20
                  ),
                  label: const Text(
                    "Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 51, 51, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
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

// SignUp Form Widget
class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
            child: const Text(
              "Create an account",
              style: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 33,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "First Name",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter your first name",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Last Name",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter your last name",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Email is taken.",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 92, 92, 1),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter your email",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Password",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Phone Number",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "Phone number is taken.",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 92, 92, 1),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter your phone number",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    iconSize: 20
                  ),
                  label: const Text(
                    "Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 51, 51, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
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

// Recover Password Form Widget
class RecoverPasswordForm extends StatelessWidget {
  const RecoverPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
            child: const Text(
              "Recover Password",
              style: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 33,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "New Password",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter a new password",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email Code",
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter the code sent to your email",
              hintStyle: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 0.75
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: Color.fromRGBO(51, 51, 51, 1), 
                  width: 1.25
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    iconSize: 20
                  ),
                  label: const Text(
                    "Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 51, 51, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 17                  
                    )
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

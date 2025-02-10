import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/widgets/recovery_form.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  void _showRecoverSheet(BuildContext context, Widget form) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      builder: (context) {
        return  ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.70,  
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20), 
            child: SingleChildScrollView(
              child: form,
            )
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 5, 5, 5),
            child: Text(
              "Log in to your account",
              style: TextStyle(
                color: const Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: screenWidth * 0.075, 
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),    
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, 
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Email does not exist.",
                  style: TextStyle(
                    color: const Color.fromRGBO(255, 92, 92, 1),
                    fontSize: screenWidth * 0.035, 
                    fontFamily: 'Roboto',
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
                fontSize: screenWidth * 0.04,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Text(
              "Password",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
         TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showRecoverSheet(context, const RecoverPasswordForm());
              },
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(51, 51, 51, 1),
              ),
              child: Text(
                "Forgot your password?",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
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
                    iconSize: screenWidth * 0.045
                  ),
                  label: Text(
                    "Back",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.045
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 51, 51, 1),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.045
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
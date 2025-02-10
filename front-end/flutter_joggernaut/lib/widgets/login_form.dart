import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/widgets/recovery_form.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

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
    );
  }

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
                _showBottomSheet(context, const RecoverPasswordForm());
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
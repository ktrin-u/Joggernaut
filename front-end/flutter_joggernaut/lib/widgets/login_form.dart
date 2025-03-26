import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/form_sheet.dart';
import 'package:flutter_application_1/widgets/recovery_form.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isLoading = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  int? statusCode;

  Future login(context) async {
    setState(() {
      isLoading = true;
      statusCode = null;
    });

    var response = (await AuthService().login(usernameController.text, passwordController.text));

    if (response.statusCode == 200) {
      router.goNamed('homepage');
    }

    setState(() {
      isLoading = false;
      statusCode = response.statusCode;
    });
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
                color: Color.fromRGBO(51, 51, 51, 1),
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
                if (statusCode != null && statusCode != 200) Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: Text(
                    "Invalid email or password.",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 92, 92, 1),
                      fontSize: screenWidth * 0.030, 
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ) else Padding(
                  padding: EdgeInsets.only(bottom: screenHeight*0.01),
                  child: Row()
                ),
              ],
            ),
          ),
          TextField(
            controller: usernameController,
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
                borderSide: BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
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
            controller: passwordController,
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
                borderSide: BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showFormBottomSheet(
                  context: context, 
                  minHeight: 0.52,
                  maxHeight: 0.52, 
                  form: ResetPasswordForm(), 
                  onClose: null
                );
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
                  onPressed: () => router.pop(),
                  icon: Icon(
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
                    login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                    backgroundColor: Color.fromRGBO(245, 245, 245, 1),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: isLoading ? 0.0 : 1.0, 
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                      if (isLoading)
                        SizedBox(
                          height: screenWidth * 0.045, 
                          width: screenWidth * 0.045, 
                          child: CircularProgressIndicator(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            strokeWidth: 2.5,
                          ),
                        ),
                    ],
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

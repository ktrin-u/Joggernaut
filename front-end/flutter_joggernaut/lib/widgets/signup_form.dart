import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/snackbar.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isLoading = false;

  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phonenumberController = TextEditingController();  
  final passwordController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  
  Future createUser(context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    setState(() {
      isLoading = true;
      firstNameError = null;
      lastNameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
    });

    var response = await ApiService().createUser(firstnameController.text, lastnameController.text, emailController.text, phonenumberController.text, passwordController.text);
    var responseData = json.decode((response).body);
    if (response.statusCode == 201) {
      Navigator.pop(context);
      router.go("/");
      ScaffoldMessenger.of(context).showSnackBar(NotifSnackbar(message: "Account created successfully!", screenHeight: screenHeight, screenWidth: screenWidth));
    }

    setState(() {
      firstNameError = responseData["firstname"]?.join(", ");
      lastNameError = responseData["lastname"]?.join(", ");
      emailError = responseData["email"]?.join(", ");
      phoneError = responseData["phonenumber"]?.join(", ");
      passwordError = responseData["password"]?.join(", ");
      isLoading = false;
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
              "Create an account",
              style: TextStyle(
                color: const Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontSize: screenWidth * 0.075, 
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildFormText("First Name", screenWidth),
          _buildFormField("Enter your first name", false, firstnameController, screenWidth, screenHeight),
          _buildFormErrorMsg(firstNameError, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.01),
          _buildFormText("Last Name", screenWidth),
          _buildFormField("Enter your last name", false, lastnameController, screenWidth, screenHeight),
          _buildFormErrorMsg(lastNameError, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.01),
          _buildFormText("Email", screenWidth),
          _buildFormField("Enter your email address", false, emailController, screenWidth, screenHeight),
          _buildFormErrorMsg(emailError, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.01),
          _buildFormText("Phone Number", screenWidth),
          _buildFormField("Enter your phone number", false, phonenumberController, screenWidth, screenHeight),
          _buildFormErrorMsg(phoneError, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.01),
          _buildFormText("Password", screenWidth),
          _buildFormField("Enter your password", true, passwordController, screenWidth, screenHeight),
          _buildFormErrorMsg(passwordError, screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => router.pop(),
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
                    createUser(context);
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
                          "Sign Up",
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

Widget _buildFormText (String label, double screenWidth){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.05, 
            color: Color.fromRGBO(51, 51, 51, 1),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFormField (String hint, bool isObscure, TextEditingController controller, double screenWidth, double screenHeight){
  return TextField(
    controller: controller,
    obscureText: isObscure,
    decoration: InputDecoration(
      hintText: hint,
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
  );
}

Widget _buildFormErrorMsg (String? error, double screenWidth, double screenHeight){
  return error != null ? Padding(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
    child: Text(
      error,
      style: TextStyle(
        color: const Color.fromRGBO(255, 92, 92, 1),
        fontSize: screenWidth * 0.030, 
        fontFamily: 'Roboto',
        fontStyle: FontStyle.italic,
      ),
    ),
  ) : Padding(
    padding: EdgeInsets.only(bottom: screenHeight*0.01),
    child: Row()
  );
}
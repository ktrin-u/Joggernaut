import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/snackbar.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  String? error;
  bool isLoading = false;

  Future changePassword(context) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var response = await AuthService().forgetPasswordChange(newPasswordController.text, confirmPasswordController.text);
    if (response.statusCode == 200){
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(NotifSnackbar(message: "Password changed successfully!", screenHeight: screenHeight, screenWidth: screenWidth*0.9));
    }
    else{
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");

      setState(() {
        error = errorMessage;
      });
    }
    setState(() {
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
              "Change Password",
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
                  "New Password",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, 
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: newPasswordController,
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
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Text(
              "Confirm Password",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
         TextField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              hintText: "Confirm your password",
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
          if (error != null) Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Text(
              error!,
              style: TextStyle(
                color: Color.fromRGBO(255, 92, 92, 1),
                fontSize: screenWidth * 0.030, 
                fontFamily: 'Roboto',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.085),
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
                    changePassword(context);
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
                          "Submit",
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

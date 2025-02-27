// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class ChangePassword {
  static void showChangePasswordDialog(BuildContext context, TextEditingController newPasswordController, TextEditingController confirmPasswordController, Function(BuildContext) onConfirm) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangePasswordDialog(
          context: context, 
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          height: screenHeight,
          width: screenWidth,
          onConfirm: onConfirm
        );
      }
    );
  }
  
  static AlertDialog ChangePasswordDialog({
    required BuildContext context,
    required TextEditingController newPasswordController,
    required TextEditingController confirmPasswordController,
    required double height,
    required double width,
    required Function(BuildContext) onConfirm,
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        "Change Password",
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newPasswordController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter your new password",
              hintStyle: TextStyle(
                fontSize: width * 0.03,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide:  BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide:  BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
              ),
            ), 
          ),
          SizedBox(height: height*0.02),
          TextField(
            controller: confirmPasswordController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Confirm your new password",
              hintStyle: TextStyle(
                fontSize: width * 0.03,
                color: Color.fromRGBO(51, 51, 51, 1),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide:  BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 0.75),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide:  BorderSide(color: Color.fromRGBO(51, 51, 51, 1), width: 1.25),
              ),
            ), 
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "No",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: width * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1)
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); 
            onConfirm(context); 
          },
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Yes",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: width * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1)
            ),
          ),
        ),
      ],
    );
  }
}
  
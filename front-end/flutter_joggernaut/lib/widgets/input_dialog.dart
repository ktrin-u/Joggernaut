// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputHelper {
  static void showInputDialog(BuildContext context, String title, String hint, TextEditingController controller, VoidCallback callback, TextInputType inputType) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputDialog(
          context: context,
          title: title,
          hint: hint,
          controller: controller,
          callback: callback,
          inputType: inputType,
          height: screenHeight,
          width: screenWidth
        );
      },
    );
  }
  
  static AlertDialog InputDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required TextEditingController controller,
    required VoidCallback callback,
    required TextInputType inputType,
    required double height,
    required double width
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Cancel",
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
            callback(); 
            Navigator.pop(context); 
          },
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Save",
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

   static void showInputNumDialog(BuildContext context, String title, String hint, TextEditingController controller, VoidCallback callback) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InputNumDialog(
          context: context,
          title: title,
          hint: hint,
          controller: controller,
          callback: callback,
          height: screenHeight,
          width: screenWidth, 
        );
      },
    );
  }
  
  static AlertDialog InputNumDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required TextEditingController controller,
    required VoidCallback callback,
    required double height,
    required double width
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        decoration: InputDecoration(
          hintText: hint,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Cancel",
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
            callback(); 
            Navigator.pop(context); 
          },
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Save",
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
            "Cancel",
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
            "Save",
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

  static void showWorkoutDialog(BuildContext context, String title, TextEditingController stepsController, TextEditingController caloriesController, Function(BuildContext) onConfirm) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorkoutDialog(
          context: context, 
          title: title,
          stepsController: stepsController,
          caloriesController: caloriesController,
          height: screenHeight,
          width: screenWidth,
          onConfirm: onConfirm
        );
      }
    );
  }
  
  static AlertDialog WorkoutDialog({
    required BuildContext context,
    required String title,
    required TextEditingController stepsController,
    required TextEditingController caloriesController,
    required double height,
    required double width,
    required Function(BuildContext) onConfirm,
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        title,
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
            controller: stepsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter your number of steps",
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
            controller: caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter your calories burned",
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
            "Cancel",
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
            "Save",
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
  
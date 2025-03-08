// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class ConfirmHelper {
  static void showConfirmDialog(BuildContext context, String confirmationText, Function(BuildContext) onConfirm) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          context: context, 
          confirmationText: confirmationText,
          height: screenHeight,
          width: screenWidth,
          onConfirm: onConfirm
        );
      }
    );
  }
  
  static AlertDialog ConfirmDialog({
    required BuildContext context,
    required String confirmationText,
    required double height,
    required double width,
    required Function(BuildContext) onConfirm,
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        "Confirmation",
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content: Text(
        confirmationText,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
          fontSize: width * 0.04,
          color: Color.fromRGBO(51, 51, 51, 1)
        ),
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

  static void showResultDialog(BuildContext context, String resultText, String titleText) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(
          context: context, 
          resultText: resultText,
          titleText: titleText,
          height: screenHeight,
          width: screenWidth,
        );
      }
    );
  }

  static AlertDialog ResultDialog({
    required BuildContext context,
    required String resultText,
    required String titleText,
    required double height,
    required double width,
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        titleText,
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content:  Column(
        mainAxisSize: MainAxisSize.min,
        children: resultText
          .split("\n") 
          .map((error) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(fontSize: width * 0.04)), // Bullet point
              Expanded(
                child: Text(
                  error.trim(),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: width * 0.04,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                ),
              ),
            ],
          ))
          .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            "Done",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: width * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1)
            ),
          ),
        )
      ],
    );
  }
}
  
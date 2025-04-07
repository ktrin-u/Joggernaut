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

  static void showChallengeDialog(BuildContext context, Function(BuildContext) onConfirm) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChallengeDialog(
          context: context, 
          height: screenHeight,
          width: screenWidth,
          onConfirm: onConfirm
        );
      }
    );
  }
  
  static AlertDialog ChallengeDialog({
    required BuildContext context,
    required double height,
    required double width,
    required Function(BuildContext) onConfirm,
  }) {
    return AlertDialog.adaptive(
      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      title: Text(
        "Challenge",
        style: TextStyle(
          fontFamily: 'Big Shoulders Display',
          fontSize: width * 0.08,
          fontWeight: FontWeight.bold,
          color:  Color.fromRGBO(51, 51, 51, 1),
        ),
        ), 
      content: Text(
        "Challenge your friend one on one and see who has the most steps taken by the end of your challenge.\n\nPerson with the most steps by the end of your challenge wins!\n\nSteps will be counted from 12:00 AM on the challenge start date until 11:59 PM on the challenge end date.",
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
            "Back",
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
            "Continue",
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
              Text("• ", style: TextStyle(fontSize: width * 0.04)),
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

  static void showPlainActionDialog(
    BuildContext context,
    String titleText,
    String bodyText,
    String buttonText1,
    String buttonText2,
    bool toAccept,
    Function(BuildContext) onConfirm1,
    Function(BuildContext) onConfirm2,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlainActionDialog(
          context: context, 
          titleText: titleText,
          bodyText: bodyText,
          buttonText1: buttonText1,
          buttonText2: buttonText2,
          toAccept: toAccept,
          height: screenHeight,
          width: screenWidth,
          onConfirm1: onConfirm1,
          onConfirm2: onConfirm2,
        );
      }
    );
  }

  static AlertDialog PlainActionDialog({
    required BuildContext context,
    required String titleText,
    required String bodyText,
    required String buttonText1,
    required String buttonText2,
    required bool toAccept,
    required double height,
    required double width,
    required Function(BuildContext) onConfirm1,
    required Function(BuildContext) onConfirm2,
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
      content: Text(
        bodyText,
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
            "Back",
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
            onConfirm1(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            buttonText1,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: width * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1)
            ),
          ),
        ),
        if (toAccept) TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm2(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(51, 51, 51, 1),
          ),
          child: Text(
            buttonText2,
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
  
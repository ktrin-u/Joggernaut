// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/character.dart';
import 'package:flutter_application_1/utils/constants.dart';

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

  static void showTutorialDialog(
    BuildContext context,
    String title,
    String description,
    String buttonText,
    Function onNextPressed,
    Image? image,
  ) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TutorialDialog(
          context: context, 
          height: screenHeight,
          width: screenWidth,
          title: title,
          description: description,
          buttonText: buttonText,
          onNextPressed: onNextPressed,
          image: image
        );
      }
    );
  }

  static AlertDialog TutorialDialog({
    required BuildContext context,
    required double height,
    required double width,
    required title,
    required description,
    required buttonText,
    required onNextPressed,
    image
  }) {
    return AlertDialog.adaptive(
      backgroundColor: Colors.white,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: width*0.07,
            color: Color.fromRGBO(51, 51, 51, 1),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width*0.5,
            height: width*0.5,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: image 
          ),
          SizedBox(height: height*0.02),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              fontSize: width*0.055,
              color: Color.fromRGBO(51, 51, 51, 1),
            ),
            textAlign: TextAlign.center,
          ),
        ]
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(bottom: height*0.01),
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: width*0.05,
                  vertical: height*0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
                onNextPressed();
              },
              child: Text(buttonText, style: TextStyle(fontSize: width*0.05, color: Colors.black87)),
            ),
          ),
        ),
      ]
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

  static void showEditCharacterDialog(
    BuildContext context,
    String? color,
    String? type,
    List<Character> characters,
    Function onConfirm
  ) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCharacterDialog(
          context: context, 
          color: color!,
          type: type!,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          characters: characters,
          onConfirm: onConfirm
        );
      }
    );
  }

  static StatefulBuilder EditCharacterDialog({
    required BuildContext context,
    required String color,
    required String type,
    required double screenHeight,
    required double screenWidth,
    required List<Character> characters,
    required Function onConfirm
  }) {
    List<Character> characterImages = characters.where((character) => character.type == type).toList();
    int selectedItemIndex = characterImages.indexWhere((character) => character.color == color && character.type == type);
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog.adaptive(
          backgroundColor: primaryColor,
          title: Text(
            "Edit Character",
            style: TextStyle(
              fontFamily: 'Big Shoulders Display',
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(51, 51, 51, 1),
            ),
          ),
          content: SizedBox(
            width: screenWidth * 0.8, 
            height: screenHeight * 0.35, 
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                      horizontal: screenWidth * 0.05,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.02,
                      mainAxisSpacing: screenHeight * 0.02,
                    ),
                    shrinkWrap: true,
                    itemCount: 4, 
                    itemBuilder: (context, index) {
                     return GestureDetector(
                      onTap: () {
                        setState(() {
                          color = characterImages[index].color;
                          type = characterImages[index].type;
                          selectedItemIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedItemIndex == index
                              ? Colors.blue 
                              : Colors.white, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedItemIndex == index
                                ? Color.fromRGBO(90, 155, 212, 1) 
                                : Colors.transparent, 
                            width: 5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 6
                            )
                          ]
                        ),
                        child: Container(
                          width: screenWidth * 0.5,
                          height: screenWidth * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: AssetImage(characterImages[index].imagePath),
                              fit: BoxFit.cover,
                            ),
                          )
                        ),
                      ),
                    );
                    },
                  ),
                ),
                Text(
                  "$color $type",
                  style: TextStyle(
                    fontFamily: 'Big Shoulders Display',
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Back",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: screenWidth * 0.04,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm(color);
              },
              child: Text(
                "Save",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: screenWidth * 0.04,
                  color: Color.fromRGBO(51, 51, 51, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
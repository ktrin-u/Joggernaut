import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
SnackBar NotifSnackbar({required String message, required double screenHeight, required double screenWidth}){
  return SnackBar(
    elevation: 10,
    showCloseIcon: true,  
    padding: EdgeInsets.all(screenHeight*0.03),
    closeIconColor: Color.fromRGBO(51, 51, 51, 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
    ),
    content: Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          color: Color.fromRGBO(0, 0, 0, 1),
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  );
}

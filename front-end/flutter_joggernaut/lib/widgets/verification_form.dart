import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/change_password_form.dart';
import 'package:flutter_application_1/widgets/form_sheet.dart';

class VerificationForm extends StatefulWidget {
  const VerificationForm({super.key});

  @override
  State<VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends State<VerificationForm> {
  final verificationController = TextEditingController();
  int? statusCode;
  int counter = 30;
  bool isLoading = false;  
  bool isLoadingCode = false; 
  bool isButtonDisabled = true;
  Timer? timer;

  Future confirmVerificationCode(context) async{
    setState(() {
      isLoading = true;
      statusCode = null;
    });

    var response = (await AuthService().forgetPasswordGet(verificationController.text));

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      showFormBottomSheet(
        context: context, 
        minHeight: 0.52,
        maxHeight: 0.52, 
        form: ChangePasswordForm(), 
        onClose: null
      );
    }

    setState(() {
      isLoading = false;
      statusCode = response.statusCode;
    });
  }
  
  void _startTimer() {
    isButtonDisabled = true;
    counter = 30;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (counter > 0) {
        setState(() {
          counter--;
        });
      } else {
        timer.cancel();
        setState(() {
          isButtonDisabled = false;
        });
      }
    });
  }

  Future _resendCode() async{
    setState(() {
      isLoadingCode = true;
    });
    var response = await AuthService().forgetPasswordPost("getsavedemail");
    if (response.statusCode == 200){
      _startTimer();
    }
    setState(() {
      isLoadingCode = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
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
              "Verify Email",
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
                  "Verification Code",
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
                    "Invalid code",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 92, 92, 1),
                      fontSize: screenWidth * 0.030, 
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ) else
                  Padding(
                  padding: EdgeInsets.only(bottom: screenHeight*0.01),
                  child: Row()
                ),
              ],
            ),
          ),
          TextField(
            controller: verificationController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter the verification code sent to your email",
              hintStyle: TextStyle(
                fontSize: screenWidth * 0.035,
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
              onPressed: isButtonDisabled ? null : _resendCode,
              style: TextButton.styleFrom(
                foregroundColor: Color.fromRGBO(51, 51, 51, 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isLoadingCode ? 0.0 : 1.0, 
                    child: Text(
                      isButtonDisabled ? "Resend code in $counter s" : "Resend Code",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: isButtonDisabled ? Colors.grey : Color.fromRGBO(51, 51, 51, 1),
                        fontFamily: 'Roboto',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  if (isLoadingCode)
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
          ),
          SizedBox(height: screenHeight * 0.16),
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
                    confirmVerificationCode(context);
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

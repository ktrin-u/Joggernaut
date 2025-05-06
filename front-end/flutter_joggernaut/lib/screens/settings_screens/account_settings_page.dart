// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }
  
  bool isLoading = false;
  bool isEditing = false;
  late Future gettingAccInfo;
  String? email;
  String? firstname;
  String? lastname;
  String? phonenumber;

  TextEditingController emailController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void _toggleEdit(context){
    if (isEditing){
      ConfirmHelper.showConfirmDialog(
        context, 
        "Are you sure you want to update your account info?",
        (context) => updateUserInfo (context)
      );
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future updateUserInfo(context) async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().updateUserInfo(firstname, lastname, phonenumber);
    if (response.statusCode == 202){
      ConfirmHelper.showResultDialog(_currentContext, "User Info updated successfully!", "Success");
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future getUserInfo() async {
    var response = await ApiService().getUserInfo();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        email = data["email"] ?? "??";
        firstname = data["firstname"] ?? "??";
        lastname = data["lastname"] ?? "??";
        phonenumber = data["phonenumber"]?.toString() ?? "??";
        
        emailController.text = email!;
        firstnameController.text = firstname!;
        lastnameController.text = lastname!;
        phonenumberController.text = phonenumber!;
      });
    }
  }

  void onConfirmChangePassword(context){
    ConfirmHelper.showConfirmDialog(context, "Are you sure you want to change your password?", (context) => changePassword());
  }

  void onConfirmDeletion(context){
    ConfirmHelper.showConfirmDialog(context, "Are you sure you want to permanently delete your account?", (context) => deleteAccount(context));
  }

  Future deleteAccount (context) async{
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().deleteAccount();
    if (response.statusCode == 200){
      ConfirmHelper.showResultDialog(_currentContext, "Account deleted successfully!", "Success");
      await AuthService().logout();
      router.goNamed('landingpage');
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future changePassword () async{
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().changePassword(newPasswordController.text, confirmPasswordController.text);
    if (response.statusCode == 200){
      ConfirmHelper.showResultDialog(_currentContext, "Password changed successfully!", "Success");
    } 
    else {
      Map responseBody = jsonDecode(response.body);
      String errorMessage = responseBody.entries.map((entry) {
        String field = (entry.key)[0].toUpperCase() + entry.key.substring(1);
        String messages = (entry.value as List).join("\n");
        return "$field: $messages";
      }).join("\n");
      ConfirmHelper.showResultDialog(_currentContext, errorMessage, "Failed");
    }
    setState(() {
      isLoading = false;
    });
  }

  void _saveFirstname(){
    setState(() {
      firstname = firstnameController.text;
    });
  }
  void _saveLastname(){
    setState(() {
      lastname = lastnameController.text;
    });
  }
  void _savePhonenumber(){
    setState(() {
      phonenumber = phonenumberController.text;
    });
  }

  @override
  void initState(){
    super.initState();
    gettingAccInfo = getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder(
        future: gettingAccInfo,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
            color: Color.fromRGBO(51, 51, 51, 1),
            ) 
          ); 
        } else if (snapshot.hasError) {
            return Center(child: Text("Error loading account"));
        } else {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: screenHeight*0.07, left: screenWidth*0.08, right: screenWidth*0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: (){
                        router.pop();
                      },
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
                    Opacity(
                      opacity: isLoading ? 0.0 : 1.0, 
                      child: IconButton(
                        onPressed: (){
                          _toggleEdit(context);
                        },
                        icon: Icon(
                          Icons.edit_square,
                          color: (!isEditing) ? Color.fromRGBO(51, 51, 51, 1) : Color.fromRGBO(90, 155, 212, 1),
                          size: screenWidth * 0.09,
                        ),
                      ),
                    ),
                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth*0.03),
                        child: SizedBox(
                          height: screenWidth * 0.09, 
                          width: screenWidth * 0.09, 
                          child: CircularProgressIndicator(
                            color: Color.fromRGBO(51, 51, 51, 1),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight*0.005),
                  child: Text(
                    "Account Info",
                    style: TextStyle(
                      fontFamily: 'Big Shoulders Display',
                      fontSize: screenWidth * 0.13,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(51, 51, 51, 1)
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight*0.02),
                  child: ListView(
                    padding: EdgeInsets.zero, 
                    children: [
                      _buildListTileItem("Email", email!, context, emailController, false, TextInputType.emailAddress, ()=>(), "Enter your new email address", Icon(Icons.email)),
                      _buildListTileItem("First Name", firstname!, context, firstnameController, isEditing, TextInputType.text, _saveFirstname, "Enter your first name", Icon(Icons.account_circle)),
                      _buildListTileItem("Last Name", lastname!, context, lastnameController, isEditing, TextInputType.text, _saveLastname, "Enter your last name", Icon(Icons.account_circle)),
                      _buildListTileItem("Phone Number", phonenumber!, context, phonenumberController, isEditing, TextInputType.text, _savePhonenumber, "Enter your new phonenumber", Icon(Icons.smartphone_rounded)),
                      SizedBox(height: screenHeight*0.02),
                      Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.005),
                        child: _buildMenuItem("Change Password", screenWidth, screenHeight, Icon(Icons.key_rounded), (){InputHelper.showChangePasswordDialog(context, newPasswordController, confirmPasswordController, onConfirmChangePassword);}, Color.fromRGBO(51, 51, 51, 1))
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.005),
                        child: _buildMenuItem("Delete Account", screenWidth, screenHeight, Icon(Icons.delete_forever, color: Colors.red), (){onConfirmDeletion(context);}, Colors.red),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07), child: Divider()),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        }
      )
    );
  }
}

Widget _buildMenuItem(String title, double screenWidth, double screenHeight, Icon icon, Function call, Color color) {
  return Column(
    children: [
      ListTile(
        title: Text(
          title, 
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.04,
            color: color
            )
          ),
        trailing: Icon(Icons.chevron_right, color: color),
        leading: icon,
        onTap: () {
          call();
        },
      ),
    ],
  );
}

Widget _buildListTileItem(
  String label, 
  String data, 
  BuildContext context, 
  TextEditingController controller, 
  bool isEditing,
  TextInputType inputType,
  VoidCallback callback,
  String dialogHint,
  Icon icon
  ){
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.0075),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: (isEditing) ? InkWell(
          onTap: (){
            InputHelper.showInputDialog(
              context, 
              label, 
              dialogHint, 
              controller, 
              callback,
              inputType
            );
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.black12,
          child: ListTile(
            title: Text(
            "$label:",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: screenWidth * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1)
            ),
            ),
            leading: Icon(Icons.edit),
            trailing: Text(
            data,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: screenWidth * 0.04,
              color: Color.fromRGBO(51, 51, 51, 1),
              decoration: TextDecoration.underline,
              decorationColor:Color.fromRGBO(51, 51, 51, 1),
            ),
            ),
          ),
        ) : ListTile(
              title: Text(
              "$label:",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: screenWidth * 0.04,
                color: Color.fromRGBO(51, 51, 51, 1)
              ),
              ),
              leading: icon,
              trailing: Text(
              data,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: screenWidth * 0.04,
                color: Color.fromRGBO(51, 51, 51, 1),
              ),
              ),
            ),
      ),
    );
  }
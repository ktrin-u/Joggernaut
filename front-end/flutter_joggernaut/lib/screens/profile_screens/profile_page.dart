// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  bool isLoading = false;
  bool isEditing = false;
  bool? isNewUser;
  late Future gettingProfile;
  String? accountName;
  String? weight;
  String? height;
  String? address;
  String? dateofbirth;
  String? gender;

  TextEditingController accNameController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController(); 
  TextEditingController dateofbirthController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController validateController = TextEditingController();

  void _toggleEdit(context){
    if (isEditing) {
      if (isNewUser!) {
        ConfirmHelper.showConfirmDialog(
          context, 
          "Are you sure you want to create your profile?",
          (context) => createUserProfile(context)
        );
      }
      else {
        ConfirmHelper.showConfirmDialog(
          context, 
          "Are you sure you want to update your profile?",
          (context) => updateUserProfile(context)
        );
      }
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future createUserProfile(context) async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().createUserProfile(accountName, dateofbirth, gender, address, height, weight);
    if (response.statusCode == 201){
      ConfirmHelper.showResultDialog(_currentContext, "User Profile created successfully!", "Success");
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

  Future updateUserProfile(context) async {
    setState(() {
      isLoading = true;
    });
    var response  = await ApiService().updateUserProfile(accountName, dateofbirth, gender, address, height, weight);
    if (response.statusCode == 201){
      ConfirmHelper.showResultDialog(_currentContext, "User Profile updated successfully!", "Success");
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

  void _saveAccName(){
    setState(() {
      accountName = accNameController.text;
    });
  }
  
  void _saveWeight(){
    setState(() {
      weight = weightController.text;
    });
  }
  void _saveHeight(){
    setState(() {
      height = heightController.text;
    });
  }
  void _savedateofbirth(){
    setState(() {
      dateofbirth = dateofbirthController.text;
    });
  }
  void _saveGender(){
    setState(() {
      gender = genderController.text;
    });
  }
  void _saveAddress(){
    setState(() {
      address = addressController.text;
    });
  }

  Future getUserProfile() async {
    var response = await ApiService().getUserProfile();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        isNewUser = false;
        accountName = data["accountname"] ?? "??";
        dateofbirth = data["dateofbirth"] ?? "??";
        gender = data["gender"] ?? "??";
        weight = data["weight_kg"]?.toString() ?? "??";
        height = data["height_cm"]?.toString() ?? "??";
        address = data["address"] ?? "??";

        accNameController.text = accountName!;
        dateofbirthController.text = dateofbirth!;
        genderController.text = gender!;
        weightController.text = weight!;
        heightController.text = height!;
        addressController.text = address!;
      });
    }
    else if (response.statusCode == 404){
      setState(() {
        isNewUser = true;
        accountName = "New User";
        dateofbirth = "??";
        gender = "??";
        weight =  "??";
        height = "??";
        address ="??";

        accNameController.text = accountName!;
        dateofbirthController.text = dateofbirth!;
        genderController.text = gender!;
        weightController.text = weight!;
        heightController.text = height!;
        addressController.text = address!;
      });
    }
  }

  @override
  void initState(){
    super.initState();
    gettingProfile = getUserProfile();
  }
  
  @override
  Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;
  
  return Scaffold(
    body: FutureBuilder(
      future: gettingProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
            color: Color.fromRGBO(51, 51, 51, 1),
            ) 
          ); 
        } else if (snapshot.hasError) {
            return Center(child: Text("Error loading profile"));
        } else {
            return  Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40), 
                      bottomRight: Radius.circular(40),
                    ),
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                  width: screenWidth,
                  height: screenHeight * 0.4745,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight*0.07),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Profile",
                              style: TextStyle(
                                fontFamily: 'Big Shoulders Display',
                                fontSize: screenWidth * 0.13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                                  color: (!isEditing) ? Colors.white : Color.fromRGBO(90, 155, 212, 1),
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
                                    color: Color.fromRGBO(255, 255, 255, 1),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              CircleAvatar(radius: screenWidth * 0.17),
                              Material(
                                shape: CircleBorder(),
                                color: Colors.white,
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: CircleBorder(),
                                  splashColor: Colors.black12,
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    child: Icon(Icons.edit, size: screenWidth * 0.055, color: Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),  
                          SizedBox(height: screenHeight * 0.01),
                          (isEditing) ? TextButton(
                            onPressed: () {
                              InputHelper.showInputDialog(
                                context, 
                                "Account Name", 
                                "Enter your account name", 
                                accNameController, 
                                _saveAccName,
                                TextInputType.text
                              );
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: Text(
                              accountName!,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ) : Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.015),
                            child: Text(
                              accountName!,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight*0.02),
                    child: ListView(
                      padding: EdgeInsets.zero, 
                      children: [
                        _buildListTileItem("Weight in kg", weight!, context, weightController, isEditing, TextInputType.number, _saveWeight, "Enter your weight in kg", Icon(Icons.monitor_weight)),
                        _buildListTileItem("Height in cm", height!, context, heightController, isEditing, TextInputType.number, _saveHeight, "Enter your height in cm", Icon(Icons.height)),
                        _buildListTileItem("Gender", gender!, context, genderController, isEditing, TextInputType.text, _saveGender, "Enter your gender", Icon(Icons.account_circle_rounded)),
                        _buildListTileItem("Birthdate", dateofbirth!, context, dateofbirthController, isEditing, TextInputType.datetime, _savedateofbirth, "Enter your birthdate (yyyy-mm-dd)", Icon(Icons.cake)),
                        _buildListTileItem("Address", address!, context, addressController, isEditing, TextInputType.streetAddress, _saveAddress, "Enter your city", Icon(Icons.location_on))
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        }  
      )
    );
  }
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
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';

class ViewCharacterPage extends StatefulWidget {
  final String characterid;

  const ViewCharacterPage({
    super.key, 
    required this.characterid,
  });

  @override
  State<ViewCharacterPage> createState() => _ViewCharacterPageState();
}

class _ViewCharacterPageState extends State<ViewCharacterPage> {
  Map <String, dynamic> character = {};
  bool isLoading = false;
  bool isEditing = false;
  late Future gettingCharacter;
  int? health;
  int? stamina;
  int? speed;
  int? strength;
  String? name;
  String? type;
  String? color;

  TextEditingController healthController = TextEditingController();
  TextEditingController staminaController = TextEditingController();
  TextEditingController speedController = TextEditingController(); 
  TextEditingController strengthController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  void _saveName(){
    setState(() {
      name = nameController.text;
    });
  }
  // void _saveHealth(){
  //   setState(() {
  //     health = int.tryParse(healthController.text);
  //   });
  // }
  // void _saveStamina(){
  //   setState(() {
  //     stamina = int.tryParse(staminaController.text);
  //   });
  // }
  // void _saveSpeed(){
  //   setState(() {
  //     speed = int.tryParse(speedController.text);
  //   });
  // }
  // void _saveStrength(){
  //   setState(() {
  //     strength = int.tryParse(strengthController.text);
  //   });
  // }

  void _toggleEdit(context){
    if (isEditing) {
      ConfirmHelper.showConfirmDialog(
        context, 
        "Are you sure you want to update your character?",
        (context) => updateCharacter()
      );
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future getCharacters() async {
    var response = await ApiService().getCharacters();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      var myCharacters = List<Map<String, dynamic>>.from(data["characters"]); 
      setState(() {
        character = myCharacters.firstWhere(
          (element) => element['id'] == int.tryParse(widget.characterid),
          orElse: () => {}, 
        );

        name = character["name"] ?? "New Character";
        type = character["class"] ?? "Class";
        color = character["color"] ?? "Color";
        strength = character["strength"] ?? 0;
        speed = character["speed"] ?? 0;
        stamina = character["stamina"] ?? 0;
        health = character["health"] ?? 0;
      });
    }
    else {
      setState(() {
        name = character["name"] ?? "New Character";
        type = character["class"] ?? "Class";
        color = character["color"] ?? "Color";
        strength = character["strength"] ?? 0;
        speed = character["speed"] ?? 0;
        stamina = character["stamina"] ?? 0;
        health = character["health"] ?? 0;
      });
    }
  }

  Future updateCharacter() async {

  }

  @override
  void initState(){
    super.initState();
    gettingCharacter = getCharacters();
  }
  
  @override
  Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
  double screenWidth = MediaQuery.of(context).size.width;
  
  return Scaffold(
    body: FutureBuilder(
      future: gettingCharacter,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
            color: Color.fromRGBO(51, 51, 51, 1),
            ) 
          ); 
        } else if (snapshot.hasError) {
            return Center(child: Text("Error loading character"));
        } else {
            return Column(
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
                              "Character",
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
                                "Character Name", 
                                "Enter your character's name", 
                                nameController, 
                                _saveName,
                                TextInputType.text
                              );
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: Text(
                              name!,
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
                              name!,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: screenWidth * 0.1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            "$color $type",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontStyle: FontStyle.italic,
                              fontSize: screenWidth * 0.06,
                              color: Colors.white,
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
                        _buildListTileItem("Health", health.toString(), context, Icon(CupertinoIcons.heart)),
                        _buildListTileItem("Strength", strength.toString(), context, Icon(Icons.fitness_center_rounded)),
                        _buildListTileItem("Stamina", stamina.toString(), context, Icon(Icons.directions_run_rounded)),
                        _buildListTileItem("Speed", speed.toString(), context, Icon(Icons.speed)),
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
  Icon icon
  ){
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight*0.0075),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
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
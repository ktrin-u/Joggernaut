// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/character.dart';
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
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }
  Map <String, dynamic> character = {};
  bool isLoading = false;
  bool isLoadingName = false;
  bool isEditing = false;
  late Future gettingCharacter;
  int? health;
  int? stamina;
  int? speed;
  int? strength;
  String? name;
  String? type;
  String? color;
  String? selectedImage;
  int? id;

  TextEditingController healthController = TextEditingController();
  TextEditingController staminaController = TextEditingController();
  TextEditingController speedController = TextEditingController(); 
  TextEditingController strengthController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  List<Character> characterImages = [
    Character(color: "Blue", type: "Archer", imagePath: "assets/characters/Blue Archer.png"),
    Character(color: "Purple", type: "Archer", imagePath: "assets/characters/Purple Archer.png"),
    Character(color: "Red", type: "Archer", imagePath: "assets/characters/Red Archer.png"),
    Character(color: "Yellow", type: "Archer", imagePath: "assets/characters/Yellow Archer.png"),
    Character(color: "Blue", type: "Pawn", imagePath: "assets/characters/Blue Pawn.png"),
    Character(color: "Purple", type: "Pawn", imagePath: "assets/characters/Purple Pawn.png"),
    Character(color: "Red", type: "Pawn", imagePath: "assets/characters/Red Pawn.png"),
    Character(color: "Yellow", type: "Pawn", imagePath: "assets/characters/Yellow Pawn.png"),
    Character(color: "Blue", type: "Knight", imagePath: "assets/characters/Blue Knight.png"),
    Character(color: "Purple", type: "Knight", imagePath: "assets/characters/Purple Knight.png"),
    Character(color: "Red", type: "Knight", imagePath: "assets/characters/Red Knight.png"),
    Character(color: "Yellow", type: "Knight", imagePath: "assets/characters/Yellow Knight.png"),
  ];

  void _saveName() async{
    setState(() {
      name = nameController.text;
    });
    await updateName();
  }

  void _saveCharacter(newColor) async{
    setState(() {
      color = newColor;
      selectedImage = getImagePath(color!, "${character["type"][0]}${character["type"].substring(1).toLowerCase()}");
    });
    await updateCharacter();
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

  String getImagePath(String color, String type) {
    final character = characterImages.firstWhere(
      (c) => c.color == color && c.type == type,
      orElse: () => throw Exception('Character not found'),
    );
    return character.imagePath;
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
        type = character["type"] ?? "Class";
        color = character["color"] ?? "Color";
        strength = character["strength"] ?? 0;
        speed = character["speed"] ?? 0;
        stamina = character["stamina"] ?? 0;
        health = character["health"] ?? 0;
        id = character["id"] ?? 0;
        selectedImage = getImagePath("${character["color"][0]}${character["color"].substring(1).toLowerCase()}", "${character["type"][0]}${character["type"].substring(1).toLowerCase()}");
      });
    }
  }

  Future updateCharacter() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().updateCharacter(id, type, color, name);
    if (response.statusCode == 202){
      ConfirmHelper.showResultDialog(_currentContext, "Character updated successfully!", "Success");
      await getCharacters();
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

  Future updateName() async {
    setState(() {
      isLoadingName = true;
    });
    var response = await ApiService().updateCharacter(id, type, color, name);
    if (response.statusCode == 202){
      ConfirmHelper.showResultDialog(_currentContext, "Character updated successfully!", "Success");
      await getCharacters();
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
      isLoadingName = false;
    });
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
                              Container(
                                width: screenWidth*0.3,
                                height: screenWidth*0.3,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                  image: DecorationImage(
                                    image: AssetImage(selectedImage!), 
                                    fit: BoxFit.cover, 
                                  ),
                                ),
                              ),
                              Material(
                                shape: CircleBorder(),
                                color: Colors.white,
                                elevation: 2,
                                child: (!isLoading) ? InkWell(
                                  onTap: () { 
                                    ConfirmHelper.showEditCharacterDialog(context, "${color![0]}${color!.substring(1).toLowerCase()}", "${type![0]}${type!.substring(1).toLowerCase()}", characterImages, _saveCharacter);
                                  },
                                  customBorder: CircleBorder(),
                                  splashColor: Colors.black12,
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    child: Icon(Icons.edit, size: screenWidth * 0.055, color: Colors.black87),
                                  ),
                                ) : CircularProgressIndicator(
                                  color: Color.fromRGBO(51, 51, 51, 1),
                                )
                              ) 
                            ],
                          ),  
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name!,
                                style: TextStyle(
                                  fontFamily: 'Big Shoulders Display',
                                  fontSize: screenWidth * 0.1,
                                  fontWeight: FontWeight.bold,
                                  color:  Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              (!isLoadingName) ? IconButton(
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
                                icon: Icon(
                                  Icons.edit,
                                  size: screenHeight*0.03,
                                  color: Colors.white,
                                ),
                              ) : Padding(
                                padding: EdgeInsets.only(left: screenWidth*0.04),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Text(
                            "${color![0]}${color!.substring(1).toLowerCase()} ${type![0]}${type!.substring(1).toLowerCase()}",
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
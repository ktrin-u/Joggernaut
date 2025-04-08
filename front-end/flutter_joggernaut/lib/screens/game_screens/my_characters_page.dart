// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/character.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';

class MyCharactersPage extends StatefulWidget {
  const MyCharactersPage({super.key});

  @override
  State<MyCharactersPage> createState() => _MyCharactersPageState();
}

class _MyCharactersPageState extends State<MyCharactersPage> {
  late BuildContext _currentContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  late Future gettingCharacters;
  List<Map<String, dynamic>> myCharacters = [];
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
  bool isDeleting = false;

  void deletingCharacters(){
    setState(() {
      isDeleting = true;
    });
  }

  void resetDeleting(){
    setState(() {
      isDeleting = false;
    });
  }

  Future selectCharacter(characterid) async {
    await ApiService().selectCharacter(characterid);
    setState(() {
      setup();
    });
  }
  
  Future getCharacters() async {
    var response = await ApiService().getCharacters();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      setState(() {
        myCharacters = List<Map<String, dynamic>>.from(data["characters"]);
      });
    }
  }

  Future deleteCharacter(characterid) async {
    var response = await ApiService().deleteCharacter(characterid);
    if (response.statusCode == 200){
      setState(() {
        setup();
      });
      ConfirmHelper.showResultDialog(_currentContext, "Character deleted successfully!", "Success");
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
      isDeleting = false;
    });
  }

  Future getGameSave() async{
    await ApiService().getGameSave();
  }

  Future setup() async{
    await getGameSave();
    await getCharacters();
  }

  @override
  void initState() {
    super.initState();
    gettingCharacters = setup();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
        future: gettingCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
              color: Color.fromRGBO(51, 51, 51, 1),
              ) 
            ); 
          } else if (snapshot.hasError) {
              return Center(child: Text("Error loading my characters"));
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.07, left: screenWidth * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Characters",
                        style: TextStyle(
                          fontFamily: 'Big Shoulders Display',
                          fontSize: screenWidth * 0.09,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: (){ (!isDeleting) ? deletingCharacters() : resetDeleting();},
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.black87,
                              size: screenWidth * 0.07,
                            ),
                          ),
                          IconButton(
                            onPressed: (){router.push("/game/create-character");},
                            icon: Icon(
                              Icons.add_circle_rounded,
                              color: Colors.black87,
                              size: screenWidth * 0.07,
                            ),
                          ),  
                          IconButton(
                            onPressed: (){router.pop();},
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.black87,
                              size: screenWidth * 0.05,
                            ),
                          ),                        
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: screenHeight * 0.01),
                    itemCount: myCharacters.length,
                    itemBuilder: (context, index) {
                      var item = myCharacters[index];                  
                      int characterid = item["id"];
                      String characteridstr = characterid.toString();
                      bool isSelected = item["selected"];

                      Future selectingCharacter() async{
                        setState(() {
                          item["isLoading"] = true;
                        });
                        await selectCharacter(characterid);
                      }

                      Future deletingCharacter() async{
                        setState(() {
                          item["isLoading"] = true;
                        });
                        await deleteCharacter(characterid);
                      }

                      String getImagePath(String color, String type) {
                        final character = characterImages.firstWhere(
                          (c) => c.color == color && c.type == type,
                          orElse: () => throw Exception('Character not found'),
                        );
                        return character.imagePath;
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.005,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected ? Color.fromRGBO(90, 155, 212, 1) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: (){router.push('/game/view-character/$characteridstr');},
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                                child: ListTile(
                                  title: Padding(
                                    padding: EdgeInsets.only(left: screenWidth*0.02),
                                    child: Text(
                                      item["name"],
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                        fontSize: screenWidth * 0.04,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                  ),
                                  leading: Container(
                                    width: screenWidth*0.17,
                                    height: screenWidth*0.17,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(245, 245, 245, 1),
                                      image: DecorationImage(
                                        image: AssetImage(getImagePath("${item["color"][0]}${item["color"].substring(1).toLowerCase()}", "${item["type"][0]}${item["type"].substring(1).toLowerCase()}")), 
                                        fit: BoxFit.cover, 
                                      ),
                                    ),
                                  ),
                                  trailing: (item["isLoading"] == true) ? Padding(
                                    padding: EdgeInsets.only(right: screenWidth*0.02),
                                    child: SizedBox(
                                      height: screenWidth * 0.07, 
                                      width: screenWidth * 0.07, 
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ) : (isDeleting) ? IconButton(
                                    onPressed: (){
                                      ConfirmHelper.showConfirmDialog(context, "Are you sure you want to delete this character?", (context) => deletingCharacter());
                                    },
                                    icon: Icon(
                                      Icons.disabled_by_default_rounded,
                                      color: Colors.black87,
                                      size: screenWidth * 0.07,
                                    ),
                                  ) : (isSelected) ? Padding(
                                    padding: EdgeInsets.only(right: screenWidth*0.025),
                                    child: Icon(
                                      Icons.check_box_rounded,
                                      color: Color.fromRGBO(90, 155, 212, 1),
                                      size: screenWidth * 0.07,
                                    ),
                                  ) : IconButton(
                                    onPressed: () => ConfirmHelper.showConfirmDialog(context, "Are you sure you want to select this character?", (context) => selectingCharacter()),
                                    icon: Icon(
                                      Icons.check_box_outline_blank_rounded,
                                      color: Colors.black87,
                                      size: screenWidth * 0.07,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: EdgeInsets.only(left: screenWidth*0.02),
                                    child: Text(
                                      "${item["color"][0]}${item["color"].substring(1).toLowerCase()} ${item["type"][0]}${item["type"].substring(1).toLowerCase()}", 
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        fontSize: screenWidth * 0.035,
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]
            );
          }
        }
      )
    );
  }
}
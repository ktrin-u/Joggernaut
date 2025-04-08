// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/character.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/input_dialog.dart';

class CreateCharacterPage extends StatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  State<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends State<CreateCharacterPage> {
  late BuildContext _currentContext;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentContext = context;
  }

  String name = "Insert Name";
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  int selectedItemIndex = 0;
  
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

  late String selectedImage = characterImages[0].imagePath;
  late String type = characterImages[0].type;
  late String color = characterImages[0].color;


  void _saveName(){
    setState(() {
      name = nameController.text;
    });
  }

  Future createCharacter() async {
    setState(() {
      isLoading = true;
    });
    var response = await ApiService().createCharacter(name, type, color);
    if (response.statusCode == 201){
      ConfirmHelper.showResultDialog(_currentContext, "Character created successfully!", "Success");
      router.push('/game/my-characters');
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.07, left: screenWidth * 0.07),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Create Character",
                style: TextStyle(
                  fontFamily: 'Big Shoulders Display',
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
        ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight*0.01),
          child: Container(
            width: screenWidth*0.4, 
            height: screenWidth*0.4, 
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), 
              image: DecorationImage(
                image: AssetImage(selectedImage), 
                fit: BoxFit.cover, 
              ),
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight*0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Big Shoulders Display',
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
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
                ),
              )
            ],
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
        Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), child: Divider(thickness: 1.75, color: Colors.grey,)),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01, horizontal: screenWidth * 0.05),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, 
              crossAxisSpacing: screenWidth * 0.01,
              mainAxisSpacing: screenHeight * 0.01,
            ),
            itemCount: 12, 
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImage = characterImages[index].imagePath;
                    color = characterImages[index].color;
                    type = characterImages[index].type;
                    selectedItemIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedItemIndex == index
                        ? Colors.blue 
                        : Colors.grey, 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedItemIndex == index
                          ? Color.fromRGBO(90, 155, 212, 1) 
                          : Colors.transparent, 
                      width: 5,
                    ),
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
        Padding(padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05), child: Divider(thickness: 1.75, color: Colors.grey,)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight*0.03, right: screenWidth*0.05, top: screenHeight*0.01),
              child: ElevatedButton(
                onPressed: () {
                  ConfirmHelper.showConfirmDialog(context, "Are you sure you want to create the character:\n\n$name - $color $type?", (context)=>{createCharacter()});
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromRGBO(51, 51, 51, 1),
                  backgroundColor: Color.fromRGBO(84, 166, 238, 1),
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
                        "Create",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        height: screenWidth * 0.045, 
                        width: screenWidth * 0.045, 
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          strokeWidth: 2.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
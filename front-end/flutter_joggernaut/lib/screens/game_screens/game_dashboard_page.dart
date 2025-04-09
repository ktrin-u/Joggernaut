// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/utils/routes.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';

class GameDashboardPage extends StatefulWidget {
  const GameDashboardPage({super.key});

  @override
  State<GameDashboardPage> createState() => _GameDashboardPageState();
}

class _GameDashboardPageState extends State<GameDashboardPage> {

  List<(String, String, String)> iconImages = [
    ("My Characters", "assets/dashboard/characters.png","/game/my-characters"),
    ("Play Game", "assets/dashboard/game.png", "/game/play"),
    ("Tutorial", "assets/dashboard/tutorial.png", "/game/play"),
    ("Leaderboards", "assets/dashboard/leaderboards.png", "/game/leaderboards"),
  ];
  Map<String, dynamic> selectedCharacter = {};

  Future getGameSave() async{
    await ApiService().getGameSave();
  }

  Future setup() async{
    await getGameSave();
    await getCharacters();
  }

  Future getCharacters() async {
    var response = await ApiService().getCharacters();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      var characters = List<Map<String, dynamic>>.from(data["characters"]);
      setState(() {
        selectedCharacter = characters.firstWhere((item) => item["selected"] == true, orElse: () => {});
      });
    }
  }

  void checkCharacter(path) async{
    await setup();
    if (selectedCharacter.isEmpty){
      ConfirmHelper.showResultDialog(context, "Please select a character first from the 'My Characters' page", "Failed");
      return;
    }
    else {
      router.push(path);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(90, 155, 212, 1),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight*0.07, right: screenWidth * 0.04, left: screenWidth * 0.07, bottom: screenHeight*0.025),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Game Dashboard",
                  style: TextStyle(
                    fontFamily: 'Big Shoulders Display',
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: (){router.go("/home");},
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: screenWidth * 0.07,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: screenHeight,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40)
                  ),
                ),
              
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.04, horizontal: screenWidth * 0.05),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 2.75,
                  crossAxisCount: 1, 
                  mainAxisSpacing: screenHeight * 0.03,
                ),
                itemCount: 4, 
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (index == 1){
                        checkCharacter(iconImages[index].$3);
                      }
                      else if (index == 2){
                        ConfirmHelper.showTutorialDialog(
                          context, 
                          "How to Play", 
                          "Survive as long as possible while defeating enemies", 
                          "Next", 
                          (){ConfirmHelper.showTutorialDialog(
                            context, 
                            "Controls", 
                            "Use the joystick to move your character", 
                            "Next", 
                            (){ConfirmHelper.showTutorialDialog(
                              context, 
                              "Attacking", 
                              "Your character automatically shoots at enemies", 
                              "Next", 
                              (){ConfirmHelper.showTutorialDialog(
                                context, 
                                "Health", 
                                "Stay away from enemies to avoid losing health", 
                                "Done", 
                                (){}, 
                                Image.asset("assets/tutorial/health.png"));}, 
                              Image.asset("assets/tutorial/attacking.png"));}, 
                            Image.asset("assets/tutorial/controls.png"));}, 
                          Image.asset("assets/tutorial/how_to_play.png"));
                      }
                      else {
                        router.push(iconImages[index].$3);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.transparent, 
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 4
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(iconImages[index].$2),
                                fit: BoxFit.cover
                              ),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight*0.01),
                            child: Text(
                              iconImages[index].$1,
                              style: TextStyle(
                                fontFamily: "Roboto",
                                fontSize: screenWidth*0.045,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ]
      ),
    );
  }
}
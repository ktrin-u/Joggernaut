import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_services.dart';
import 'package:flutter_joggernaut_game/game_over.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future loadingGame;
  JoggernautGame? game;

  Map<String, dynamic> selectedCharacter = {};

  Future getGameSave() async{
    await ApiService().getGameSave();
  }

  Future getCharacters() async {
    var response = await ApiService().getCharacters();
    if (response.statusCode == 200){
      var data = jsonDecode(response.body);
      var characters = List<Map<String, dynamic>>.from(data["characters"]);
      setState(() {
        selectedCharacter = characters.firstWhere((item) => item["selected"] == true, orElse: () => {});
        if (selectedCharacter["type"] == "KNIGHT"){
          selectedCharacter["type"] = "WARRIOR";
        }
      });
    }
  }
  
  Future addGameStat() async {
    await ApiService().postGameStats();
  }

  Future loadGame () async{
    await getGameSave();
    await getCharacters();
    await addGameStat();
    game = JoggernautGame(character: "${selectedCharacter["type"][0]}${selectedCharacter["type"].substring(1).toLowerCase()}",
    color: "${selectedCharacter["color"][0]}${selectedCharacter["color"].substring(1).toLowerCase()}",
    atkSpeed: 1.0,);
    await game!.onLoad();
  }

  @override
  void initState() {
    super.initState();
    loadingGame = loadGame();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
      future: loadingGame,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
            color: Color.fromRGBO(51, 51, 51, 1),
            ) 
          ); 
        } else if (snapshot.hasError) {
            return Center(child: Text("Error loading game"));
        } else {
          return Scaffold(
            body: GameWidget(
                game: game!,
                overlayBuilderMap: {
                  'gameOver':
                      (context, game) => GameOverMenu(game: game as JoggernautGame),
                },
              ),
          );
          }
        },
      ),
    );
  }
}
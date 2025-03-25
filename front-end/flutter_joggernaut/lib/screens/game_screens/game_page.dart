import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Future loadingGame;
  JoggernautGame? game;

  Future loadGame () async{
    game = JoggernautGame();
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
          return GameWidget(game: game!);
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Game Page", 
        style: TextStyle(
          fontSize: 24
        )
      ),
    );
  }
}
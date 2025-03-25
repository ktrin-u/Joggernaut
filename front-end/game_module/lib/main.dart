import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

void main() {
  JoggernautGame game = JoggernautGame();
  runApp(GameWidget(game: game));
}
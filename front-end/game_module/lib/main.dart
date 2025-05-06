import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/game_over.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

void main() {
  // Characters: Archer, Warrior
  // (no Pawn yet. Will use Warrior as close-range tank para no new projectile asset)
  // Colors: Blue, Yellow, Purple, Red
  final game = JoggernautGame(
    character: 'Warrior',
    color: 'Purple',
    atkSpeed: 1.0,
  );

  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        'gameOver':
            (context, game) => GameOverMenu(game: game as JoggernautGame),
      },
    ),
  );
}

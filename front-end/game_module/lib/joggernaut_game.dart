import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/components/enemy.dart';
import 'package:flutter_joggernaut_game/components/player.dart';
import 'package:flutter_joggernaut_game/components/map.dart';
import 'package:flutter_joggernaut_game/components/projectile.dart';
import 'package:flutter_joggernaut_game/components/score.dart';

class JoggernautGame extends FlameGame {
  final String character;
  final String color;
  final double atkSpeed;

  JoggernautGame({
    this.character = 'Archer',
    this.color = 'Blue',
    this.atkSpeed = 1.0,
  });

  @override
  Color backgroundColor() => const Color(0xFF47ABA9);
  late Map map;
  late Player player;
  late JoystickComponent joystick;

  double elapsedTime = 0;
  int get score => elapsedTime.floor();

  bool isGameOver = false;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    player = Player(color: color, character: character, atkSpeed: atkSpeed);
    player.priority = 2;
    map = Map(mapName: 'world01', player: player);

    camera = CameraComponent.withFixedResolution(
      world: map,
      width: 540,
      height: 1100,
    );
    camera.priority = 1;
    camera.follow(player);

    addAll([camera, map]);
    addJoystick();
    add(ScoreDisplay()..priority = 3);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isGameOver) {
      elapsedTime += dt;
    }
    super.update(dt);
  }

  void addJoystick() {
    double joystickSize = 48;
    joystick = JoystickComponent(
      priority: 2,
      knob: CircleComponent(
        radius: joystickSize,
        paint: BasicPalette.gray.withAlpha(150).paint(), // alpha = transparency
      ),
      background: CircleComponent(
        radius: joystickSize * 2,
        paint: BasicPalette.black.withAlpha(100).paint(),
      ),
      margin: EdgeInsets.only(left: 64, bottom: 128),
    );
    camera.viewport.add(joystick);
  }

  void gameOver() {
    isGameOver = true;
    overlays.add('gameOver');
    pauseEngine();
  }

  void restartGame() {
    isGameOver = false;
    overlays.remove('gameOver');

    map.respawnPlayer();
    map.removeAll(map.children.whereType<Enemy>());
    map.removeAll(map.children.whereType<Projectile>());
    elapsedTime = 0;

    camera.viewfinder.position = player.position;

    resumeEngine();
  }
}

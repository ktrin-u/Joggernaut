import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/actors/player.dart';
import 'package:flutter_joggernaut_game/worlds/map.dart';

class JoggernautGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late Map map;
  late Player player;
  late JoystickComponent joystick;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    player = Player();
    map = Map(player: player);

    camera = CameraComponent.withFixedResolution(
      world: map,
      width: 640,
      height: 360,
    );
    camera.priority = 1;
    camera.follow(player);

    addAll([camera, map]);
    addJoystick();
  }

  @override
  void update(double dt) {
    if (joystick.direction != JoystickDirection.idle) {
      player.position.add(joystick.relativeDelta * player.maxSpeed * dt);
      player.angle = joystick.delta.screenAngle();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 2,
      knob: CircleComponent(
        radius: 24,
        paint: BasicPalette.gray.withAlpha(150).paint(), // alpha = transparency
      ),
      background: CircleComponent(
        radius: 48,
        paint: BasicPalette.black.withAlpha(100).paint(),
      ),
      margin: EdgeInsets.only(left: 32, bottom: 32),
    );
    camera.viewport.add(joystick);
  }
}

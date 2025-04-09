import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/character.dart';

class Enemy extends Character {
  String enemy;
  Enemy({super.position, required this.enemy});

  @override
  double maxSpeed = 80.0; // fixed for now

  @override
  void loadAllAnimations() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Goblins/Troops/Torch/Blue/Torch_Blue.png',
      ),
      srcSize: Vector2.all(192),
    );

    idleAnimation = _loadAnimation(7, 0);
    moveAnimation = _loadAnimation(6, 1);

    animations = {
      CharacterState.idle: idleAnimation,
      CharacterState.moving: moveAnimation,
    };
  }

  SpriteAnimation _loadAnimation(int amount, int row) {
    return spriteSheet.createAnimation(
      row: row,
      stepTime: stepTime,
      from: 0,
      to: amount,
    );
  }

  @override
  void updateMovement(double dt) {
    Vector2 direction = (gameRef.player.position - position).normalized();

    direction +=
        Vector2(
          (Random().nextDouble() - 0.5) * 0.2,
          (Random().nextDouble() - 0.5) * 0.2,
        ).normalized();

    velocity = direction * maxSpeed;
    position += velocity * dt;

    if (gameRef.player.x < x) {
      scale.x = 1;
    } else {
      scale.x = -1;
    }

    current = CharacterState.moving;
  }
}

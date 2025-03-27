import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/character.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';

class Enemy extends Character {
  String enemy;
  Enemy({super.position, required this.enemy}) : super(character: enemy);

  @override
  double maxSpeed = 50.0; // fixed for now

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

    velocity = direction * maxSpeed;
    position += velocity * dt;

    if (velocity.x < 0) {
      scale.x = 1;
    } else if (velocity.x > 0) {
      scale.x = -1;
    }

    current = CharacterState.moving;
  }

  @override
  void checkCollisions(double dt) {
    for (final wall in collisionBlocks) {
      if (checkCollision(this, wall)) {
        if (velocity.x != 0) {
          position.x -= (velocity.x * dt);
        }
        if (velocity.y != 0) {
          position.y -= (velocity.y * dt);
        }
      }
    }
  }
}

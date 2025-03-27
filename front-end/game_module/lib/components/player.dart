import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/character.dart';
import 'package:flutter_joggernaut_game/components/projectile.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';

class Player extends Character {
  String color;
  Player({super.position, required this.color}) : super(character: color);

  double lastShotTime = 0.0;
  double shootInterval = 0.5;
  Vector2 shootDirection = Vector2(1, 0);

  @override
  void update(double dt) {
    lastShotTime += dt;

    updateMovement(dt);
    checkCollisions(dt);
    shootProjectile(dt);

    super.update(dt);
  }

  @override
  void loadAllAnimations() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Knights/Troops/Archer/Blue/Archer_Blue.png',
      ),
      srcSize: Vector2.all(192),
    );

    idleAnimation = _loadAnimation(6, 0);
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
    JoystickComponent joystick = gameRef.joystick;
    if (joystick.direction != JoystickDirection.idle) {
      velocity = joystick.relativeDelta;
      position.add(velocity * maxSpeed * dt);

      if (velocity.x < 0) {
        scale.x = -1;
      } else if (velocity.x > 0) {
        scale.x = 1;
      }

      current = CharacterState.moving;
    } else {
      current = CharacterState.idle;
    }
  }

  @override
  void checkCollisions(double dt) {
    for (final wall in collisionBlocks) {
      if (checkCollision(this, wall)) {
        if (velocity.x != 0) {
          position.x -= (velocity.x * maxSpeed * dt);
        }
        if (velocity.y != 0) {
          position.y -= (velocity.y * maxSpeed * dt);
        }
      }
    }
  }

  void shootProjectile(dt) {
    if (lastShotTime >= shootInterval) {
      if (gameRef.joystick.direction != JoystickDirection.idle) {
        shootDirection = gameRef.joystick.relativeDelta.normalized();
      }

      final projectile = Projectile(
        position: position + (shootDirection * 32),
        direction: shootDirection,
      );

      gameRef.map.add(projectile);
      lastShotTime = 0;
    }
  }
}

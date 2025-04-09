import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/character.dart';
import 'package:flutter_joggernaut_game/components/enemy.dart';
import 'package:flutter_joggernaut_game/components/projectile.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';

class Player extends Character {
  final String color;
  final String character;
  final double atkSpeed;

  Player({
    super.position,
    required this.color,
    required this.character,
    required this.atkSpeed,
  }) {
    shootSpeed = 2 / atkSpeed;
  }

  int maxHp = 100;
  int currentHp = 100;
  double damageCooldown = 0.2;
  double lastDamageTime = 0.0;
  bool get isInvulnerable => lastDamageTime < damageCooldown;

  bool dead = false;

  late final RectangleComponent hpBarBackground;
  late final RectangleComponent hpBar;

  double shootSpeed = 0.5;
  Vector2 shootDirection = Vector2(1, 0);
  double lastShotTime = 0.0;

  @override
  Future<void> onLoad() async {
    _initHpBar();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    lastShotTime += dt * atkSpeed;
    lastDamageTime += dt;

    updateMovement(dt);
    shootProjectile(dt);
    checkWallCollisions();
    checkEnemyCollisions(); // adds player health and enemy damage
    checkCharacterCollisions();

    super.update(dt);
  }

  @override
  void loadAllAnimations() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Knights/Troops/$character/$color/${character}_$color.png',
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

  void _initHpBar() {
    // fix width and height to variable
    hpBarBackground = RectangleComponent(
      size: Vector2(192 / 3, 10),
      position: Vector2(192 / 3, 192 / 3 * 2.1),
      paint: Paint()..color = const Color.fromARGB(255, 61, 61, 61),
    );

    hpBar = RectangleComponent(
      size: Vector2(192 / 3, 10),
      position: Vector2(192 / 3, 192 / 3 * 2.1),
      paint: Paint()..color = const Color.fromARGB(255, 93, 223, 93),
    );

    add(hpBarBackground);
    add(hpBar);
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

      if (scale.x > 0) {
        hpBar.x = width / 3;
        hpBarBackground.x = width / 3;
        hpBar.scale.x = 1;
        hpBarBackground.scale.x = 1;
      } else {
        hpBar.x = width / 3 * 2;
        hpBarBackground.x = width / 3 * 2;
        hpBar.scale.x = -1;
        hpBarBackground.scale.x = -1;
      }

      current = CharacterState.moving;
    } else {
      current = CharacterState.idle;
    }
  }

  void shootProjectile(dt) {
    if (gameRef.joystick.relativeDelta.length > 0) {
      shootDirection = gameRef.joystick.relativeDelta.normalized();
    }

    if (lastShotTime >= shootSpeed) {
      final projectile = Projectile(
        position: position + (shootDirection * 32),
        direction: shootDirection,
      );

      gameRef.map.add(projectile);
      lastShotTime = 0;
    }
  }

  void checkEnemyCollisions() {
    if (isInvulnerable) return;

    for (final component in gameRef.map.children.whereType<Enemy>()) {
      if (checkCharacterCollision(this, component, 1.01)) {
        takeDamage(5);
        lastDamageTime = 0.0;
        break;
      }
    }
  }

  void takeDamage(int amount) {
    currentHp -= amount;
    updateHpBar();

    if (currentHp <= 0) {
      die();
    }
  }

  void updateHpBar() {
    final hpPercentage = currentHp / maxHp;
    hpBar.size = Vector2(width / 3 * hpPercentage, 10);

    if (hpPercentage < 0.3) {
      hpBar.paint.color = const Color.fromARGB(255, 243, 76, 76); // Red
    } else if (hpPercentage < 0.6) {
      hpBar.paint.color = const Color.fromARGB(255, 241, 241, 74); // Yellow
    } else {
      hpBar.paint.color = const Color.fromARGB(255, 93, 223, 93); // Green
    }
  }

  void die() {
    currentHp = 100;
  } // implement game over / play again screen
}

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/enemy.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class Projectile extends SpriteComponent with HasGameRef<JoggernautGame> {
  Vector2 direction;
  Projectile({required super.position, required this.direction})
    : super(anchor: Anchor.center);

  late final SpriteSheet spriteSheet;
  double maxSpeed = 300;

  @override
  FutureOr<void> onLoad() {
    _loadSprite();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction * maxSpeed * dt;
    checkCollisions();
  }

  void _loadSprite() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Knights/Troops/Archer/Arrow/Arrow.png',
      ),
      srcSize: Vector2(64, 16),
    );

    sprite = spriteSheet.getSprite(0, 0);
    angle = -direction.angleToSigned(Vector2(1, 0));
  }

  void checkCollisions() {
    for (final object in gameRef.map.children) {
      if (object is Enemy && checkCharacterCollision(object, this, 1)) {
        object.removeFromParent();
        removeFromParent();
      } else if (object is CollisionBlock && checkWallCollision(this, object)) {
        removeFromParent();
      }
    }

    // in case the projectile goes out of bounds
    if (position.x < 0 ||
        position.y < 0 ||
        position.x > 64 * 80 ||
        position.y > 64 * 80) {
      removeFromParent();
    }
  }
}

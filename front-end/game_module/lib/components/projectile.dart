import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class Projectile extends SpriteComponent with HasGameRef<JoggernautGame> {
  Vector2 direction;
  Projectile({required super.position, required this.direction})
    : super(anchor: Anchor.center);

  List<CollisionBlock> collisionBlocks = []; // add collisions for enemies and walls

  late final SpriteSheet spriteSheet;
  double maxSpeed = 300;

  @override
  FutureOr<void> onLoad() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Knights/Troops/Archer/Arrow/Arrow.png',
      ),
      srcSize: Vector2.all(64),
    );

    sprite = spriteSheet.getSprite(0, 0);
    angle = -direction.angleToSigned(Vector2(1, 0));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction * maxSpeed * dt;

    if (position.x < 0 ||
        position.y < 0 ||
        position.x > 64 * 80 ||
        position.y > 64 * 80) {
      removeFromParent();
    }
  }

  void checkCollisions(double dt) {
    for (final wall in collisionBlocks) {
      if (checkCollision(this, wall)) {
        if (direction.x != 0 || direction.y != 0) {
          removeFromParent();
        }
      }
    }
  }
}

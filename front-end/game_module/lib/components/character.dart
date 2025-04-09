import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

enum CharacterState { idle, moving }

abstract class Character extends SpriteAnimationGroupComponent<CharacterState>
    with HasGameRef<JoggernautGame> {
  Character({super.position})
    : super(anchor: Anchor.center);

  late final SpriteSheet spriteSheet;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveAnimation;
  final double stepTime = 0.1;

  Vector2 velocity = Vector2.zero();
  Iterable<CollisionBlock> collisionBlocks = [];
  double get maxSpeed => 100.0;
  double push = 1;

  @override
  Future<void> onLoad() async {
    collisionBlocks = gameRef.map.children.whereType<CollisionBlock>();
    loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateMovement(dt);
    checkWallCollisions();
    checkCharacterCollisions();
    super.update(dt);
  }

  void loadAllAnimations();

  void updateMovement(double dt);

  void checkWallCollisions() {
    for (final wall in collisionBlocks) {
      if (checkWallCollision(this, wall)) {
        final overlapX = calculateOverlap(
          x - (width / 6),
          x + (width / 6),
          wall.x,
          wall.x + wall.width,
        );

        final overlapY = calculateOverlap(
          y - (height / 6),
          y + (height / 6),
          wall.y,
          wall.y + wall.height,
        );

        if (overlapX.abs() < overlapY.abs()) {
          position += Vector2(overlapX, 0);
        } else {
          position += Vector2(0, overlapY);
        }
      }
    }
  }

  void checkCharacterCollisions() {
    for (final component in gameRef.map.children) {
      if (component is Character && component != this) {
        if (checkCharacterCollision(this, component, 1)) {
          final overlapX = calculateOverlap(
            x - (width / 6),
            x + (width / 6),
            component.x - (component.width / 6),
            component.x + (component.width / 6),
          );

          final overlapY = calculateOverlap(
            y - (height / 6),
            y + (height / 6),
            component.y - (component.height / 6),
            component.y + (component.height / 6),
          );

          if (velocity.length > 0) {
            if (overlapX.abs() < overlapY.abs()) {
              position += Vector2(overlapX * push, 0);
            } else {
              position += Vector2(0, overlapY * push);
            }
          }
        }
      }
    }
  }
}

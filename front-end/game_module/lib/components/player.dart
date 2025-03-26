import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/components/utils.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

enum PlayerState { idle, moving }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<JoggernautGame> {
  String character;
  Player({super.position, required this.character})
    : super(anchor: Anchor.center);

  late final SpriteSheet spriteSheet;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveAnimation;
  final double stepTime = 0.1;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];

  double maxSpeed = 200.0;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateMovement(dt);
    _checkCollisions(dt);
    super.update(dt);
  }

  void _loadAllAnimations() {
    spriteSheet = SpriteSheet(
      image: game.images.fromCache(
        'Factions/Knights/Troops/Archer/Blue/Archer_Blue.png',
      ),
      srcSize: Vector2.all(192),
    );

    idleAnimation = _loadAnimation(6, 0);
    moveAnimation = _loadAnimation(6, 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.moving: moveAnimation,
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

  void _updateMovement(dt) {
    JoystickComponent joystick = gameRef.joystick;
    if (joystick.direction != JoystickDirection.idle) {
      velocity = joystick.relativeDelta;
      position.add(velocity * maxSpeed * dt);

      if (velocity.x < 0) {
        scale.x = -1;
      } else if (velocity.x > 0) {
        scale.x = 1;
      }

      current = PlayerState.moving;
    } else {
      current = PlayerState.idle;
    }
  }

  void _checkCollisions(dt) {
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
}

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter_joggernaut_game/components/collision_block.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

enum CharacterState { idle, moving }

abstract class Character extends SpriteAnimationGroupComponent<CharacterState>
    with HasGameRef<JoggernautGame> {
  String character;
  Character({super.position, required this.character})
    : super(anchor: Anchor.center);

  late final SpriteSheet spriteSheet;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation moveAnimation;
  final double stepTime = 0.1;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  double get maxSpeed => 100.0;

  @override
  Future<void> onLoad() async {
    loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateMovement(dt);
    checkCollisions(dt);
    super.update(dt);
  }

  void loadAllAnimations();

  void updateMovement(double dt);

  void checkCollisions(double dt);
}

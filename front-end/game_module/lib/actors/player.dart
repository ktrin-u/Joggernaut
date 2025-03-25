import 'dart:ui';

import 'package:flame/components.dart';

class Player extends PositionComponent with HasGameRef {
  // no sprite yet; if sprite use SpriteComponent
  Player() : super(anchor: Anchor.center, size: Vector2.all(32.0));

  double maxSpeed = 300.0;

  @override
  Future<void> onLoad() async {
    position = gameRef.size / 2;
  }

  @override
  void render(Canvas canvas) {
    final paint =
        Paint()..color = const Color.fromARGB(255, 49, 102, 216); // Green color
    canvas.drawRect(size.toRect(), paint);
    super.render(canvas);
  }
}

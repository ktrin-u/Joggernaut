import 'package:flame/components.dart';
import 'package:flutter/material.dart';

double calculateOverlap(double pMin, double pMax, double wMin, double wMax) {
  if (pMin < wMax && pMax > wMin) {
    return pMax > wMax ? wMax - pMin : wMin - pMax;
  }
  return 0;
}

bool checkWallCollision(PositionComponent player, PositionComponent wall) {
  final playerRect = Rect.fromCenter(
    center: Offset(player.x, player.y),
    width: player.width / 3,
    height: player.height / 3,
  );

  final wallRect = Rect.fromLTWH(
    wall.position.x,
    wall.position.y,
    wall.width,
    wall.height,
  );

  return playerRect.overlaps(wallRect);
}

bool checkCharacterCollision(PositionComponent char, PositionComponent other, double multiplier) {
  final charRect = Rect.fromCenter(
    center: Offset(char.x, char.y),
    width: char.width / 3 * multiplier,
    height: char.height / 3 * multiplier,
  );

  final otherRect = Rect.fromCenter(
    center: Offset(other.x, other.y),
    width: other.width / 3 * multiplier,
    height: other.height / 3 * multiplier,
  );

  return charRect.overlaps(otherRect);
}

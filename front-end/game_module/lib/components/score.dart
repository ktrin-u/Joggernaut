import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class ScoreDisplay extends Component with HasGameRef<JoggernautGame> {
  final TextPaint textPaint;

  ScoreDisplay()
    : textPaint = TextPaint(
        style: TextStyle(
          fontSize: 48,
          fontFamily: 'Big Shoulders Display',
          color: Colors.white,
        ),
      );

  @override
  void render(Canvas canvas) {
    final minutes = (gameRef.score / 60).floor();
    final remainingSeconds = (gameRef.score % 60).floor();
    final scoreText =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    
    textPaint.render(
      canvas,
      scoreText,
      Vector2((gameRef.camera.viewport.size.x / 2), 100),
      anchor: Anchor.center,
    );
  }
}

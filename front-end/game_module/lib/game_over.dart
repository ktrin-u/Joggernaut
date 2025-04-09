import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joggernaut_game/joggernaut_game.dart';

class GameOverMenu extends StatelessWidget {
  final JoggernautGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final TextStyle gameOverTextStyle = TextStyle(
      fontFamily: 'Big Shoulders Display',
      fontSize: 84,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    );

    final TextStyle buttonTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 24,
      color: Colors.white,
    );

    return Material(
      color: const Color.fromARGB(128, 73, 9, 9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GAME OVER', style: gameOverTextStyle),
            Text(
              'Survived for ${game.score} seconds!',
              style: buttonTextStyle,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: const Color.fromARGB(255, 91, 155, 75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                game.restartGame();
              },
              child: Text('RETRY', style: buttonTextStyle),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                backgroundColor: const Color.fromARGB(255, 151, 151, 151),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // idk pano iccode yung exit, ginagawa neto is exit to homescreen
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  SystemNavigator.pop();
                }
              },
              child: Text('  EXIT  ', style: buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:attention_game/screens/lobby.dart';
import 'package:attention_game/screens/menu.dart';
import 'package:attention_game/colors.dart';
import 'package:attention_game/widgets.dart';
import 'package:flutter/material.dart';
import 'package:attention_game/game/types/gamemode.dart';
import 'package:attention_game/screens/maze_widget.dart';

import '../gameplay/handler.dart';

late Function(int) globalUpdateTimeLeft;

class Gameplay extends StatefulWidget {
  final GameMode gamemode;

  const Gameplay({super.key, required this.gamemode});

  @override
  State<Gameplay> createState() => _GameplayState();
}

class _GameplayState extends State<Gameplay> {
  int playerLeft = 0;
  bool isDead = false;
  int playersLeft = 5;
  int mazeShrinkTimeSeconds = 191;
  int lives = 3;

  void updateLivesLeft(livesLeft) {
    setState(() {
      isDead = livesLeft == 0;
      lives = livesLeft;
    });
  }

  void updatePlayersLeft(players) {
    setState(() {
      playersLeft = players;
    });
  }

  void updateTimeLeft(time) {
    setState(() {
      mazeShrinkTimeSeconds = time;
    });
  }

  @override
  void initState() {
    Handler.startGameLoop();
    Handler.pvp(() {}, updatePlayersLeft, updateLivesLeft);

    globalUpdateTimeLeft = updateTimeLeft;
    super.initState();
  }

  Widget detailText(String label, String value) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: DETAIL_TEXT_HEADER_SIZE,
              fontWeight: FontWeight.bold,
            ),
          ),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: DETAIL_TEXT_VALUE_SIZE,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget leftArea() {
    int keys = 5;
    int totalKeys = 10;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.gamemode == GameMode.pvp
          ? [detailText('Lives Left:', lives.toString())]
          : [detailText('Keys Found:', '$keys/$totalKeys')],
    );
  }

  Widget rightArea() {
    String formatDuration(int totalSeconds) {
      final duration = Duration(milliseconds: totalSeconds);
      final minutes = duration.inMinutes;
      final seconds = totalSeconds % 60;

      final minutesString = '$minutes'.padLeft(2, '0');
      final secondsString = '$seconds'.padLeft(2, '0');
      return '$minutesString:$secondsString';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        detailText('Players Left:', playersLeft.toString()),
        const SizedBox(height: 40),
        detailText('Maze Shrinks in:', formatDuration(mazeShrinkTimeSeconds)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isDead) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You Died!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MenuButton(
                buttonText: 'Return to Home',
                backgroundColor: const Color(SPECTATE_BUTTON_COLOR),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Menu(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: leftArea()),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 70.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: MazeWidget(),
            ),
          ),
          Expanded(child: rightArea()),
        ],
      ),
    );
  }
}

import 'package:attention_game/screens/lobby.dart';
import 'package:flutter/material.dart';
import 'package:attention_game/game/types/gamemode.dart';
import 'package:attention_game/screens/maze_widget.dart';

import '../gameplay/handler.dart';

class Gameplay extends StatefulWidget {
  final GameMode gamemode;

  const Gameplay({super.key, required this.gamemode});

  @override
  State<Gameplay> createState() => _GameplayState();
}

class _GameplayState extends State<Gameplay> {
  @override
  void initState() {
    Handler.startGameLoop();
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
    int lives = 5;
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
      final duration = Duration(seconds: totalSeconds);
      final minutes = duration.inMinutes;
      final seconds = totalSeconds % 60;

      final minutesString = '$minutes'.padLeft(2, '0');
      final secondsString = '$seconds'.padLeft(2, '0');
      return '$minutesString:$secondsString';
    }

    int playersLeft = 5;
    int mazeShrinkTimeSeconds = 191;

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

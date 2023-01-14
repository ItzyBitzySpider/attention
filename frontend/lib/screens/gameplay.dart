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

  Widget leftArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('left'),
      ],
    );
  }

  Widget rightArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'right',
        )
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
            padding: EdgeInsets.symmetric(vertical: 50.0),
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

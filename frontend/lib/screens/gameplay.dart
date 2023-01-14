import 'package:flutter/material.dart';
import 'package:attention_game/game/types/gamemode.dart';
import 'package:attention_game/screens/maze_widget.dart';

class Gameplay extends StatelessWidget {
  final GameMode gamemode;

  const Gameplay({super.key, required this.gamemode});

  Widget leftArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('left'),
      ],
    );
  }

  Widget rightArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          Expanded(flex: 1, child: leftArea()),
          const Expanded(flex: 3, child: MazeWidget()),
          Expanded(flex: 1, child: rightArea()),
        ],
      ),
    );
  }
}

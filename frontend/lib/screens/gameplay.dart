import 'package:flutter/material.dart';
import 'package:attention_game/game/types/gamemode.dart';
import 'package:attention_game/screens/maze_widget.dart';

class Gameplay extends StatelessWidget {
  final GameMode gamemode;

  const Gameplay({super.key, required this.gamemode});

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

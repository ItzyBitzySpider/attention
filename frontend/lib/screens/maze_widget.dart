import 'package:attention_game/colors.dart';
import 'package:attention_game/game/maze_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MazeWidget extends StatelessWidget {
  const MazeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget<MazeGame>(
      game: MazeGame(),
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(WALL_COLOR)),
      ),
    );
  }
}

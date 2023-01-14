import 'package:attention_game/game/maze_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MazeWidget extends StatelessWidget {
  const MazeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print('hi');
    return GameWidget<MazeGame>(
      game: MazeGame(),
      loadingBuilder: (context) => Center(
        child: Text(
          'Loading...',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      // overlayBuilderMap: {
      //   'menu': (_, game) => Menu(game),
      //   'game_over': (_, game) => GameOver(game),
      // },
      // initialActiveOverlays: const ['menu'],
    );
  }
}

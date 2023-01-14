import 'dart:ui';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:flame/components.dart';

class Earthquake extends RectangleComponent {
  Earthquake({
    required MazeHelper mazeHelper,
  }) : super(
          position:
              Vector2(mazeHelper.playerSize / 2, mazeHelper.playerSize / 2),
          size: Vector2((mazeHelper.playerSize + mazeHelper.wallThickness) * 3,
              (mazeHelper.playerSize + mazeHelper.wallThickness) * 3),
          paint: Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(EARTHQUAKE_COLOR),
          anchor: Anchor.center,
        );
}

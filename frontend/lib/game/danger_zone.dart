import 'dart:ui';

import 'package:attention_game/game/maze_helper.dart';
import 'package:flame/components.dart';

class DangerZone extends RectangleComponent {
  DangerZone({
    required MazeHelper mazeHelper,
    required int positionX,
    required int positionY,
    required int colorCode,
  }) : super(
          position: mazeHelper.positionToCoordinates(positionX, positionY),
          size: Vector2(mazeHelper.playerSize + mazeHelper.wallThickness,
              mazeHelper.playerSize + mazeHelper.wallThickness),
          paint: Paint()
            ..style = PaintingStyle.fill
            ..color = Color(colorCode),
        );
}

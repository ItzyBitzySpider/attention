import 'dart:ui';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:flame/components.dart';

class DangerZone extends RectangleComponent {
  DangerZone({
    required MazeHelper mazeHelper,
    required double length,
    required Vector2 coordinates,
    required bool isVertical,
  }) : super(
          position: coordinates,
          size: isVertical
              ? Vector2(mazeHelper.wallThickness, length)
              : Vector2(length, mazeHelper.wallThickness),
          paint: Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(RED_BORDER_COLOR),
        );
}

class VerticalDangerZone extends DangerZone {
  VerticalDangerZone({
    required MazeHelper mazeHelper,
    required int shrinkExtent,
    required Vector2 coordinates,
  }) : super(
          mazeHelper: mazeHelper,
          length:
              (mazeHelper.positionMax - shrinkExtent) * mazeHelper.playerSize +
                  (mazeHelper.positionMax - shrinkExtent - 1) *
                      mazeHelper.wallThickness,
          coordinates: coordinates,
          isVertical: true,
        );
}

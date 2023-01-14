import 'dart:ui';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/types/wall_type.dart';
import 'package:flame/components.dart';

class Wall extends RectangleComponent {
  late bool visible;

  Wall({
    required double wallThickness,
    required double wallLength,
    required WallType wallType,
    required Vector2 coordinates,
  }) : super(
          position: coordinates,
          size: wallType == WallType.vertical
              ? Vector2(wallThickness, wallLength + wallThickness * 2)
              : Vector2(wallThickness * 2 + wallLength, wallThickness),
          paint: Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(WALL_COLOR),
        );
}

class TopWall extends Wall {
  TopWall(MazeHelper mazeHelper, int x, int y)
      : super(
          wallType: WallType.horizontal,
          wallThickness: mazeHelper.wallThickness,
          wallLength: mazeHelper.playerSize,
          coordinates: mazeHelper.positionToCoordinates(x, y) + Vector2(0, 0),
        );
}

class BottomWall extends Wall {
  BottomWall(MazeHelper mazeHelper, int x, int y)
      : super(
          wallThickness: mazeHelper.wallThickness,
          wallLength: mazeHelper.playerSize,
          coordinates: mazeHelper.positionToCoordinates(x, y) +
              Vector2(0, mazeHelper.wallThickness + mazeHelper.playerSize),
          wallType: WallType.horizontal,
        );
}

class LeftWall extends Wall {
  LeftWall(MazeHelper mazeHelper, int x, int y)
      : super(
          wallThickness: mazeHelper.wallThickness,
          wallLength: mazeHelper.playerSize,
          coordinates: mazeHelper.positionToCoordinates(x, y) + Vector2(0, 0),
          wallType: WallType.vertical,
        );
}

class RightWall extends Wall {
  RightWall(MazeHelper mazeHelper, int x, int y)
      : super(
          wallThickness: mazeHelper.wallThickness,
          wallLength: mazeHelper.playerSize,
          coordinates: mazeHelper.positionToCoordinates(x, y) +
              Vector2(mazeHelper.wallThickness + mazeHelper.playerSize, 0),
          wallType: WallType.vertical,
        );
}

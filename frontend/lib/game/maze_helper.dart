import 'package:flame/components.dart';

// ignore: constant_identifier_names
const int WALL_HEIGHT_FACTOR = 15;
// ignore: constant_identifier_names
const int WALL_THICKNESS_FACTOR = 2;

class MazeHelper {
  late int positionMax;
  late double wallThickness;
  late double playerSize;
  late List<List<bool>> vertical;
  late List<List<bool>> horizontal;
  late double screenSize;

  MazeHelper({
    required this.vertical,
    required this.horizontal,
    required this.screenSize,
  }) {
    positionMax = vertical.length;
    double u = screenSize /
        (positionMax * WALL_HEIGHT_FACTOR +
            (positionMax + 1) * WALL_THICKNESS_FACTOR);
    wallThickness = u * WALL_THICKNESS_FACTOR;
    playerSize = u * WALL_HEIGHT_FACTOR;
  }

  Vector2 positionToCoordinates(int positionX, int positionY) {
    double x = (wallThickness + playerSize) * positionX;
    double y = (wallThickness + playerSize) * positionY;

    return Vector2(x, y);
  }

  bool hasTopWall(int x, int y) => horizontal[y][x];
  bool hasBottomWall(int x, int y) => horizontal[y + 1][x];
  bool hasLeftWall(int x, int y) => vertical[y][x];
  bool hasRightWall(int x, int y) => vertical[y][x + 1];
}

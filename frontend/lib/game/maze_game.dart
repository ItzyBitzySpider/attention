import 'dart:math';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/player.dart';
import 'package:attention_game/game/sample.dart';
import 'package:attention_game/game/wall.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MazeGame extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Color backgroundColor() => const Color(MAZE_BACKGROUND_COLOR);

  late MazeHelper mazeHelper;

  void drawMaze(List<List<bool>> vertical, List<List<bool>> horizontal) {
    double screenSize = min(size.x, size.y);

    mazeHelper = MazeHelper(
      vertical: vertical,
      horizontal: horizontal,
      screenSize: screenSize,
    );

    for (int y = 0; y < mazeHelper.positionMax; y++) {
      for (int x = 0; x < mazeHelper.positionMax; x++) {
        Vector2 coordinates = mazeHelper.positionToCoordinates(x, y);

        if (mazeHelper.hasTopWall(x, y)) {
          add(horizontalWall(
            wallThickness: mazeHelper.wallThickness,
            wallLength: mazeHelper.playerSize,
            coordinates: coordinates + Vector2(mazeHelper.wallThickness, 0),
          ));
        }

        if (mazeHelper.hasBottomWall(x, y)) {
          add(horizontalWall(
            wallThickness: mazeHelper.wallThickness,
            wallLength: mazeHelper.playerSize,
            coordinates: coordinates +
                Vector2(mazeHelper.wallThickness,
                    mazeHelper.wallThickness + mazeHelper.playerSize),
          ));
        }

        if (mazeHelper.hasLeftWall(x, y)) {
          add(verticalWall(
            wallThickness: mazeHelper.wallThickness,
            wallLength: mazeHelper.playerSize,
            coordinates: coordinates + Vector2(0, 0),
          ));
        }

        if (mazeHelper.hasRightWall(x, y)) {
          add(verticalWall(
            wallThickness: mazeHelper.wallThickness,
            wallLength: mazeHelper.playerSize,
            coordinates: coordinates +
                Vector2(mazeHelper.wallThickness + mazeHelper.playerSize,
                    mazeHelper.wallThickness),
          ));
        }
      }
    }

    add(horizontalWall(
      wallThickness: mazeHelper.wallThickness,
      wallLength: mazeHelper.wallThickness,
      coordinates: Vector2(0, screenSize - mazeHelper.wallThickness),
    ));
  }

  void spawnPlayer(int x, int y) {
    add(Player(mazeHelper: mazeHelper, positionX: x, positionY: y));
  }

  @override
  Future<void> onLoad() async {
    drawMaze(vertical, horizontal);
    spawnPlayer(0, 0);
  }
}

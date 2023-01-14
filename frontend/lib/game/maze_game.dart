import 'dart:math';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/enemy.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/player.dart';
import 'package:attention_game/game/sample.dart';
import 'package:attention_game/game/wall.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MazeGame extends FlameGame with HasKeyboardHandlerComponents {
  late MazeHelper mazeHelper;

  late Player player;
  List<Wall> mazeWalls = [];
  List<Enemy> enemies = [];

  @override
  Color backgroundColor() => const Color(MAZE_BACKGROUND_COLOR);

  void drawWalls(int positionX, int positionY) {
    removeAll(mazeWalls);
    mazeWalls = [];

    for (int y = max(positionY - 1, 0);
        y < min(positionY + 2, mazeHelper.positionMax);
        y++) {
      for (int x = max(positionX - 1, 0);
          x < min(positionX + 2, mazeHelper.positionMax);
          x++) {
        if (mazeHelper.hasTopWall(x, y)) {
          Wall wall = TopWall(mazeHelper, x, y);
          mazeWalls.add(wall);
        }

        if (mazeHelper.hasBottomWall(x, y)) {
          Wall wall = BottomWall(mazeHelper, x, y);
          mazeWalls.add(wall);
        }

        if (mazeHelper.hasLeftWall(x, y)) {
          Wall wall = LeftWall(mazeHelper, x, y);
          mazeWalls.add(wall);
        }

        if (mazeHelper.hasRightWall(x, y)) {
          Wall wall = RightWall(mazeHelper, x, y);
          mazeWalls.add(wall);
        }
      }
    }

    addAll(mazeWalls);
  }

  void drawEnemy(int positionX, int positionY) {
    removeAll(enemies);
    enemies = [];

    if ((positionX - player.positionX).abs() < 2 &&
        (positionY - player.positionY).abs() < 2) {
      enemies.add(Enemy(
          mazeHelper: mazeHelper, positionX: positionX, positionY: positionY));
    }

    addAll(enemies);
  }

  void spawnPlayer(int positionX, int positionY) {
    player = Player(
      mazeHelper: mazeHelper,
      positionX: positionX,
      positionY: positionY,
    );
    add(player);
  }

  @override
  Future<void> onLoad() async {
    double screenSize = min(size.x, size.y);

    mazeHelper = MazeHelper(
      vertical: vertical,
      horizontal: horizontal,
      screenSize: screenSize,
    );

    spawnPlayer(0, 0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    drawWalls(player.positionX, player.positionY);
    drawEnemy(10, 10);
  }
}

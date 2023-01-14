import 'dart:math';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/enemy.dart';
import 'package:attention_game/game/pickup.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/player.dart';
import 'package:attention_game/game/sample.dart';
import 'package:attention_game/game/wall.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../gameplay/handler.dart';
import '../utils/sockets.dart';

class MazeGame extends FlameGame with HasKeyboardHandlerComponents {
  late MazeHelper mazeHelper;

  late Player player;
  List<Wall> mazeWalls = [];
  List<Enemy> enemies = [];
  List<Pickup> pickups = [];

  int shrinkExtent = 0;

  @override
  Color backgroundColor() => const Color(MAZE_BACKGROUND_COLOR);

  void drawAllWalls() {
    mazeWalls = [];

    for (int y = 0; y < mazeHelper.positionMax; y++) {
      for (int x = 0; x < mazeHelper.positionMax; x++) {
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

  void shrinkMaze() {
    List<List<bool>> newVertical = List.from(mazeHelper.vertical);
    List<List<bool>> newHorizontal = List.from(mazeHelper.horizontal);

    // Delete rows
    for (int x = shrinkExtent; x < mazeHelper.positionMax - shrinkExtent; x++) {
      int oppositeShrinkExtent = mazeHelper.positionMax - shrinkExtent - 1;

      bool drawBorder = x != mazeHelper.positionMax - shrinkExtent - 1;

      // Top row
      newHorizontal[shrinkExtent][x] = false;
      newHorizontal[shrinkExtent + 1][x] = drawBorder;
      newVertical[shrinkExtent][x] = false;
      newVertical[shrinkExtent][x + 1] = false;

      // Bottom Row
      newHorizontal[oppositeShrinkExtent][x] = drawBorder;
      newHorizontal[oppositeShrinkExtent + 1][x] = false;
      newVertical[oppositeShrinkExtent][x] = false;
      newVertical[oppositeShrinkExtent][x + 1] = false;

      // Left Row
      newHorizontal[x][shrinkExtent] = false;
      newHorizontal[x + 1][shrinkExtent] = false;
      newVertical[x][shrinkExtent] = false;
      newVertical[x][shrinkExtent + 1] = drawBorder;

      // Right Row
      newHorizontal[x][oppositeShrinkExtent] = false;
      newHorizontal[x + 1][oppositeShrinkExtent] = false;
      newVertical[x][oppositeShrinkExtent] = drawBorder;
      newVertical[x][oppositeShrinkExtent + 1] = false;
    }

    mazeHelper.vertical = newVertical;
    mazeHelper.horizontal = newHorizontal;

    shrinkExtent++;
  }

  void spawnPickup(int positionX, int positionY) {
    KeyPickup key = KeyPickup(
      mazeHelper: mazeHelper,
      positionX: positionX,
      positionY: positionY,
    );

    pickups.add(key);
    add(key);
  }

  void spawnHeart(int positionX, int positionY) {
    HeartPickup heart = HeartPickup(
      mazeHelper: mazeHelper,
      positionX: positionX,
      positionY: positionY,
    );

    pickups.add(heart);
    add(heart);
  }

  void removePickup(int positionX, int positionY) {
    for (final pickup in pickups) {
      if (pickup.positionX == player.positionX &&
          pickup.positionY == player.positionY) {
        pickups.remove(pickup);
        remove(pickup);
        break;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    double screenSize = min(size.x, size.y);

    mazeHelper = MazeHelper(
      vertical: vertical,
      horizontal: horizontal,
      screenSize: screenSize,
    );

    spawnPlayer(Handler.ownLocation[0], Handler.ownLocation[1]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    drawWalls(player.positionX, player.positionY);
    // iterate map
    Handler.locations.forEach((key, value) {
      if (getSocket().id != key) drawEnemy(value[0], value[1]);
    });

    removePickup(player.positionX, player.positionY);
  }
}

import 'dart:math';

import 'package:attention_game/colors.dart';
import 'package:attention_game/game/danger_zone.dart';
import 'package:attention_game/game/earthquake.dart';
import 'package:attention_game/game/enemy.dart';
import 'package:attention_game/game/pickup.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/player.dart';
import 'package:attention_game/game/wall.dart';
import 'package:attention_game/screens/gameplay.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../gameplay/handler.dart';
import '../utils/sockets.dart';

// ignore: constant_identifier_names
const int DANGER_ZONE_SPEED = 20;

class MazeGame extends FlameGame with HasKeyboardHandlerComponents {
  late MazeHelper mazeHelper;
  late bool isSpectator;

  int frameCounter = 0;

  late Player player;
  List<Wall> mazeWalls = [];
  List<Enemy> enemies = [];
  List<Pickup> pickups = [];
  List<DangerZone> dangerZones = [];

  bool isShrinking = false;
  int shrinkExtent = 0;
  int timeToShrink = 0;

  @override
  Color backgroundColor() => const Color(MAZE_BACKGROUND_COLOR);

  void drawAllWalls() {
    removeAll(mazeWalls);
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

  void spawnPlayer(int positionX, int positionY) {
    player = Player(
      mazeHelper: mazeHelper,
      positionX: positionX,
      positionY: positionY,
    );
    add(player);
  }

  void shrinkMaze() {
    List<List<dynamic>> newVertical = List.from(mazeHelper.vertical);
    List<List<dynamic>> newHorizontal = List.from(mazeHelper.horizontal);

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

  void startShrinkCountdown(int milliseconds) {
    isShrinking = true;
    timeToShrink = milliseconds * 1000;
  }

  void showEarthquake() {
    Earthquake earthquake = Earthquake(mazeHelper: mazeHelper);
    earthquake.add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: EARTHQUAKE_ANIMATION_DURATION),
    ));
    earthquake.add(
      RemoveEffect(delay: EARTHQUAKE_COOLDOWN_MILLISECONDS.toDouble()),
    );
    add(earthquake);
  }

  void drawEnemies() {
    removeAll(enemies);
    enemies = [];

    Handler.locations.forEach((key, value) {
      String socketId = getSocket().id!;
      if (socketId != key) {
        int positionX = value[0];
        int positionY = value[1];

        if (isSpectator ||
            ((positionX - player.positionX).abs() < 2 &&
                (positionY - player.positionY).abs() < 2)) {
          enemies.add(Enemy(
              mazeHelper: mazeHelper,
              positionX: positionX,
              positionY: positionY));
        }
      }
    });

    addAll(enemies);
  }

  void drawDangerZones() {
    bool isDangerZone(int x, int y) {
      int opposite = mazeHelper.positionMax - shrinkExtent - 1;
      return x == shrinkExtent ||
          y == shrinkExtent ||
          x == opposite ||
          y == opposite;
    }

    for (int y = max(player.positionY - 1, 0);
        y < min(mazeHelper.positionMax, player.positionY + 2);
        y++) {
      for (int x = max(player.positionX - 1, 0);
          x < min(mazeHelper.positionMax, player.positionX + 2);
          x++) {
        if (isDangerZone(x, y)) {
          dangerZones.add(DangerZone(
            mazeHelper: mazeHelper,
            positionX: x,
            positionY: y,
            colorCode: RED_BORDER_COLORS[
                frameCounter ~/ DANGER_ZONE_SPEED % RED_BORDER_COLORS.length],
          ));
        }
      }
    }

    addAll(dangerZones);
  }

  void drawAllDangerZones() {
    int opposite = mazeHelper.positionMax - shrinkExtent - 1;
    for (int i = shrinkExtent; i < opposite + 1; i++) {
      if (i != shrinkExtent && i != opposite) {
        dangerZones.add(DangerZone(
          mazeHelper: mazeHelper,
          positionX: i,
          positionY: shrinkExtent,
          colorCode: RED_BORDER_COLORS[
              frameCounter ~/ DANGER_ZONE_SPEED % RED_BORDER_COLORS.length],
        ));

        dangerZones.add(DangerZone(
          mazeHelper: mazeHelper,
          positionX: i,
          positionY: opposite,
          colorCode: RED_BORDER_COLORS[
              frameCounter ~/ DANGER_ZONE_SPEED % RED_BORDER_COLORS.length],
        ));
      }

      dangerZones.add(DangerZone(
        mazeHelper: mazeHelper,
        positionX: shrinkExtent,
        positionY: i,
        colorCode: RED_BORDER_COLORS[
            frameCounter ~/ DANGER_ZONE_SPEED % RED_BORDER_COLORS.length],
      ));
      dangerZones.add(DangerZone(
        mazeHelper: mazeHelper,
        positionX: opposite,
        positionY: i,
        colorCode: RED_BORDER_COLORS[
            frameCounter ~/ DANGER_ZONE_SPEED % RED_BORDER_COLORS.length],
      ));
    }

    addAll(dangerZones);
  }

  void drawHearts() {
    removeAll(pickups);
    pickups = [];
    for (var p in Handler.hearts) {
      int x = p[0];
      int y = p[1];

      //     ((x - player.positionX).abs() < 2 &&
      //         (y - player.positionY).abs() < 2)) {
      pickups
          .add(HeartPickup(mazeHelper: mazeHelper, positionX: x, positionY: y));
      // }
    }

    addAll(pickups);
  }

  void drawEarthquake(String socketId) {
    if (socketId == getSocket().id!) {
      return;
    }

    var location = Handler.locations[socketId];
    Earthquake earthquake = Earthquake(
      mazeHelper: mazeHelper,
      positionX: location[0],
      positionY: location[1],
    );
    earthquake.add(ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: EARTHQUAKE_ANIMATION_DURATION),
    ));
    earthquake
        .add(RemoveEffect(delay: EARTHQUAKE_COOLDOWN_MILLISECONDS.toDouble()));
    add(earthquake);
  }

  @override
  Future<void> onLoad() async {
    await Future.delayed(const Duration(seconds: 1));

    isSpectator = Handler.isSpectator;

    double screenSize = min(size.x, size.y);
    //cast to bool;
    mazeHelper = MazeHelper(
      vertical: Handler.maze[1],
      horizontal: Handler.maze[0],
      screenSize: screenSize,
    );

    Handler.shrink(startShrinkCountdown);

    if (isSpectator) {
      drawAllWalls();
    } else {
      spawnPlayer(Handler.ownLocation[0], Handler.ownLocation[1]);
    }

    Handler.listenEarthquake(drawEarthquake);
  }

  void playerUpdate(double dt) {
    if (player.earthquakeOnCooldown) {
      player.cooldownTimer -= (dt * 1000000).toInt();

      if (player.cooldownTimer <= 0) {
        player.earthquakeOnCooldown = false;
        player.cooldownTimer = 0;
        player.remove(player.storedEarthquake!);
      }
    }

    drawWalls(player.positionX, player.positionY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    frameCounter++;

    removeAll(dangerZones);
    dangerZones = [];
    if (isShrinking) {
      timeToShrink -= (dt * 1000000).toInt();

      if (timeToShrink <= 0) {
        isShrinking = false;
        timeToShrink = 0;
        shrinkMaze();
        if (isSpectator) {
          drawAllWalls();
        }
      } else {
        if (isSpectator) {
          drawAllDangerZones();
        } else {
          drawDangerZones();
        }
      }
      globalUpdateTimeLeft(timeToShrink);
    }

    if (!isSpectator) {
      playerUpdate(dt);
    }

    drawHearts();
    drawEnemies();
  }
}

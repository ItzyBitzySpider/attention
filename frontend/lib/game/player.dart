import 'package:attention_game/game/earthquake.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/types/direction.dart';
import 'package:attention_game/gameplay/handler.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

// ignore: constant_identifier_names
const int EARTHQUAKE_COOLDOWN_MILLISECONDS = 1000;
// ignore: constant_identifier_names
const double EARTHQUAKE_ANIMATION_DURATION = 0.8;

class Player extends SpriteComponent with HasGameRef, KeyboardHandler {
  MazeHelper mazeHelper;

  late double playerMovementDistance;
  late int positionX;
  late int positionY;

  bool earthquakeOnCooldown = false;
  int cooldownTimer = 0;
  Earthquake? storedEarthquake;

  Player(
      {required this.mazeHelper,
      required this.positionX,
      required this.positionY,
      x})
      : super(size: Vector2.all(mazeHelper.playerSize)) {
    playerMovementDistance = mazeHelper.playerSize + mazeHelper.wallThickness;
  }

  void earthquake() {
    if (!earthquakeOnCooldown) {
      Handler.sendInput(1 << 4);

      cooldownTimer = EARTHQUAKE_COOLDOWN_MILLISECONDS * 1000;
      storedEarthquake = Earthquake(mazeHelper: mazeHelper);
      storedEarthquake!.add(ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: EARTHQUAKE_ANIMATION_DURATION),
      ));
      add(storedEarthquake!);

      earthquakeOnCooldown = true;
    }
  }

  void drawPlayerPosition() {
    position.setFrom(mazeHelper.positionToCoordinates(positionX, positionY) +
        Vector2(mazeHelper.wallThickness, mazeHelper.wallThickness));
  }

  void movePlayer(Direction direction) {
    switch (direction) {
      case Direction.up:
        if (!mazeHelper.hasTopWall(positionX, positionY)) {
          Handler.sendInput(1 << 2);
        }
        break;
      case Direction.down:
        if (!mazeHelper.hasBottomWall(positionX, positionY)) {
          Handler.sendInput(1 << 3);
        }
        break;
      case Direction.left:
        if (!mazeHelper.hasLeftWall(positionX, positionY)) {
          Handler.sendInput(1 << 0);
        }
        break;
      case Direction.right:
        if (!mazeHelper.hasRightWall(positionX, positionY)) {
          Handler.sendInput(1 << 1);
        }
        break;
    }
    var _loc = Handler.ownLocation;
    positionX = _loc[0];
    positionY = _loc[1];
    drawPlayerPosition();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('player_sprite.png');

    drawPlayerPosition();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent && !event.repeat) {
      // Handle movement keys
      if (logicalKeyboardKeyToDirection.containsKey(event.logicalKey)) {
        movePlayer(logicalKeyboardKeyToDirection[event.logicalKey]!);
      }

      // Handle spacebar
      if (event.logicalKey == LogicalKeyboardKey.space) {
        earthquake();
      }
    }

    return true;
  }
}

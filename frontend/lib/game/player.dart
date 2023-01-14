import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/types/direction.dart';
import 'package:attention_game/gameplay/handler.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent with HasGameRef, KeyboardHandler {
  MazeHelper mazeHelper;

  late double playerMovementDistance;
  late int positionX;
  late int positionY;

  Player({
    required this.mazeHelper,
    required this.positionX,
    required this.positionY,
  }) : super(size: Vector2.all(mazeHelper.playerSize)) {
    playerMovementDistance = mazeHelper.playerSize + mazeHelper.wallThickness;
  }

  void earthquake() {
    Handler.sendInput(1 << 4);
    // TODO handle earthquake here
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

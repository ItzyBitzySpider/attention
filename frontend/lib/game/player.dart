import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/types/direction.dart';
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
    // TODO handle earthquake here
  }

  void movePlayer(Direction direction) {
    switch (direction) {
      case Direction.up:
        if (!mazeHelper.hasTopWall(positionX, positionY)) {
          position.add(Vector2(0, -playerMovementDistance));
          positionY--;
        }
        break;
      case Direction.down:
        if (!mazeHelper.hasBottomWall(positionX, positionY)) {
          position.add(Vector2(0, playerMovementDistance));
          positionY++;
        }
        break;
      case Direction.left:
        if (!mazeHelper.hasLeftWall(positionX, positionY)) {
          position.add(Vector2(-playerMovementDistance, 0));
          positionX--;
        }
        break;
      case Direction.right:
        if (!mazeHelper.hasRightWall(positionX, positionY)) {
          position.add(Vector2(playerMovementDistance, 0));
          positionX++;
        }
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('player_sprite.png');

    position = mazeHelper.positionToCoordinates(positionX, positionY) +
        Vector2(mazeHelper.wallThickness, mazeHelper.wallThickness);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent && !event.repeat) {
      // Handle movement keys
      if (logicalKeyboardKeyToDirection.containsKey(event.logicalKey)) {
        movePlayer(logicalKeyboardKeyToDirection[event.logicalKey]!);
      }

      // Handle spacebar
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        earthquake();
      }
    }

    return true;
  }
}

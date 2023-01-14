import 'package:attention_game/game/types/direction.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

// ignore: constant_identifier_names
const double PLAYER_SIZE = 50.0;

// ignore: constant_identifier_names
const double PLAYER_SPEED = PLAYER_SIZE;

class Player extends SpriteComponent with HasGameRef, KeyboardHandler {
  Player() : super(size: Vector2.all(PLAYER_SIZE));

  void earthquake() {
    // TODO handle earthquake here
  }

  void movePlayer(Direction direction) {
    switch (direction) {
      case Direction.up:
        position.add(Vector2(0, -PLAYER_SPEED));
        break;
      case Direction.down:
        position.add(Vector2(0, PLAYER_SPEED));
        break;
      case Direction.left:
        position.add(Vector2(-PLAYER_SPEED, 0));
        break;
      case Direction.right:
        position.add(Vector2(PLAYER_SPEED, 0));
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('player_sprite.png');
    position = gameRef.size / 2;
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent && !event.repeat) {
      // Handle movement keys
      logicalKeyboardKeyToDirection.forEach((logicalKey, direction) {
        if (keysPressed.contains(logicalKey)) {
          movePlayer(direction);
        }
      });

      // Handle spacebar
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        earthquake();
      }
    }

    return true;
  }
}

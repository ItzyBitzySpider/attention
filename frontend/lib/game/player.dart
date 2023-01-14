import 'package:attention_game/game/types/direction.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

// ignore: constant_identifier_names
const double PLAYER_SIZE = 50.0;

// ignore: constant_identifier_names
const double PLAYER_SPEED = 300.0;

class Player extends SpriteComponent with HasGameRef, KeyboardHandler {
  Player() : super(size: Vector2.all(PLAYER_SIZE));

  List<Direction> directions = [];

  void movePlayer(double delta) {
    for (final direction in directions) {
      switch (direction) {
        case Direction.up:
          position.add(Vector2(0, delta * -PLAYER_SPEED));
          break;
        case Direction.down:
          position.add(Vector2(0, delta * PLAYER_SPEED));
          break;
        case Direction.left:
          position.add(Vector2(delta * -PLAYER_SPEED, 0));
          break;
        case Direction.right:
          position.add(Vector2(delta * PLAYER_SPEED, 0));
          break;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('player_sprite.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    movePlayer(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    directions = [];
    if (event is RawKeyDownEvent) {
      logicalKeyboardKeyToDirection.forEach((logicalKey, direction) {
        if (keysPressed.contains(logicalKey)) {
          directions.add(direction);
        }
      });
    }
    return true;
  }
}

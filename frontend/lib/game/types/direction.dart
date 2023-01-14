import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

final Map<LogicalKeyboardKey, Direction> logicalKeyboardKeyToDirection = {
  LogicalKeyboardKey.arrowUp: Direction.up,
  LogicalKeyboardKey.arrowDown: Direction.down,
  LogicalKeyboardKey.arrowLeft: Direction.left,
  LogicalKeyboardKey.arrowRight: Direction.right,
  LogicalKeyboardKey.keyW: Direction.up,
  LogicalKeyboardKey.keyS: Direction.down,
  LogicalKeyboardKey.keyA: Direction.left,
  LogicalKeyboardKey.keyD: Direction.right,
};

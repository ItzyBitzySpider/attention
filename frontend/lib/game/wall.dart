import 'dart:ui';

import 'package:attention_game/colors.dart';
import 'package:flame/components.dart';

RectangleComponent verticalWall({
  required double wallThickness,
  required double wallLength,
  required Vector2 coordinates,
}) {
  return RectangleComponent(
    position: coordinates,
    size: Vector2(wallThickness, wallLength + wallThickness),
    paint: Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(WALL_COLOR),
  );
}

RectangleComponent horizontalWall({
  required double wallThickness,
  required double wallLength,
  required Vector2 coordinates,
}) {
  return RectangleComponent(
    position: coordinates,
    size: Vector2(wallLength + wallThickness, wallThickness),
    paint: Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(WALL_COLOR),
  );
}

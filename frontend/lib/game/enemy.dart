import 'package:attention_game/game/maze_helper.dart';
import 'package:flame/components.dart';

class Enemy extends SpriteComponent with HasGameRef {
  MazeHelper mazeHelper;

  late int positionX;
  late int positionY;

  Enemy({
    required this.mazeHelper,
    required this.positionX,
    required this.positionY,
  }) : super(size: Vector2.all(mazeHelper.playerSize));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('enemy_sprite.png');

    position = mazeHelper.positionToCoordinates(positionX, positionY) +
        Vector2(mazeHelper.wallThickness, mazeHelper.wallThickness);
  }
}

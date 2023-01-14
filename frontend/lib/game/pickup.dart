import 'package:attention_game/game/maze_helper.dart';
import 'package:flame/components.dart';

class Pickup extends SpriteComponent with HasGameRef {
  late MazeHelper mazeHelper;
  late int positionX;
  late int positionY;
  late String spritePath;

  Pickup({
    required this.mazeHelper,
    required this.positionX,
    required this.positionY,
    required this.spritePath,
  }) : super(size: Vector2.all(mazeHelper.playerSize));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite(spritePath);
    position.setFrom(mazeHelper.positionToCoordinates(positionX, positionY));
  }
}

class KeyPickup extends Pickup {
  KeyPickup({
    required MazeHelper mazeHelper,
    required int positionX,
    required int positionY,
  }) : super(
          mazeHelper: mazeHelper,
          positionX: positionX,
          positionY: positionY,
          spritePath: 'key_icon.png',
        );
}

class HeartPickup extends Pickup {
  HeartPickup({
    required MazeHelper mazeHelper,
    required int positionX,
    required int positionY,
  }) : super(
          mazeHelper: mazeHelper,
          positionX: positionX,
          positionY: positionY,
          spritePath: 'ppt_heart.png',
        );
}

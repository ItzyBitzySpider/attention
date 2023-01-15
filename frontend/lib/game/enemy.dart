import 'package:attention_game/game/earthquake.dart';
import 'package:attention_game/game/maze_helper.dart';
import 'package:attention_game/game/player.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class Enemy extends SpriteComponent with HasGameRef {
  MazeHelper mazeHelper;

  late int positionX;
  late int positionY;

  Enemy({
    required this.mazeHelper,
    required this.positionX,
    required this.positionY,
  }) : super(size: Vector2.all(mazeHelper.playerSize));

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

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('enemy_sprite.png');

    position = mazeHelper.positionToCoordinates(positionX, positionY) +
        Vector2(mazeHelper.wallThickness, mazeHelper.wallThickness);
  }
}

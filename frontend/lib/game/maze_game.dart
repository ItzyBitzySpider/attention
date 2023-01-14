import 'package:attention_game/game/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class MazeGame extends FlameGame with HasKeyboardHandlerComponents {
  final Player _player = Player();

  @override
  Future<void> onLoad() async {
    add(_player);
  }
}

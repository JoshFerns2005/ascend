import 'package:flame/components.dart';
import 'constants.dart';

class Background extends SpriteComponent {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('game_images/background.jpg');
    size = Vector2(Constants.screenWidth, Constants.screenHeight);
    position = Vector2(0, 0);
  }
}
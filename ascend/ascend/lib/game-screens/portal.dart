import 'package:ascend/game-screens/levelselection.dart';
import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Portal extends SpriteAnimationComponent
    with HasGameRef<LobbyWorld>, TapCallbacks {
  final int unlockedLevels;

  Portal({
    required Vector2 position,
    required this.unlockedLevels,
  })      : super(position: position, size: Vector2(200, 200));

  @override
  Future<void> onLoad() async {
    try {
      // Load the portal sprite sheet (8 frames in a row)
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load('game_images/portal.png'),
        srcSize: Vector2(128, 128), // Assuming each frame is 100x100
      );

      // Create animation (8 frames)
      animation = spriteSheet.createAnimation(
        row: 0, // Assuming frames are in a single row
        stepTime: 0.1, // Adjust speed as needed
        to: 7, // 8 frames (0-7)
      );

      // Optional: Add hitbox if you want it to be interactive
      // add(RectangleHitbox());
    } catch (e) {
      debugPrint('Error loading portal: $e');
      // Fallback if image fails to load
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.blue,
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.add(LevelSelection(unlockedLevels: unlockedLevels));
  }
}

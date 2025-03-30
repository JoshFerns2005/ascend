import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Npc extends SpriteAnimationComponent with HasGameRef<LobbyWorld>, TapCallbacks {
  final List<String> dialogueMessages = [
    "Welcome to Ascend!",
    "In this game, you can fight mobs and bosses across different levels.",
    "Tap on the leaderboard signboard to see how you rank against others.",
    "You'll find portals that take you to different levels.",
    "Level 1 has 2 mobs to defeat. Level 2 has a powerful boss.",
    "Good luck, adventurer!"
  ];

  Npc({required Vector2 position})
      : super(
          size: Vector2(110, 100),
          position: position,
          priority: 1,
        );

  @override
  Future<void> onLoad() async {
    try {
      // Load the sprite sheet
      final spriteSheet = SpriteSheet(
        image: await gameRef.images.load('game_images/adventurer.png'),
        srcSize: Vector2(50, 50),
      );

      // Create idle animation
      animation = spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.15,
        to: 3,
      );

      // Add smaller hitbox (80% of NPC size)
      add(RectangleHitbox(
        size: Vector2(50, 50), // 110*0.8 = 88, 100*0.8 = 80
        position: Vector2(11, 10), // Center the smaller hitbox
      ));
    } catch (e) {
      debugPrint('Error loading NPC: $e');
      // Fallback solid color if sprite fails to load
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.purple,
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!gameRef.isDialogueActive) {
      gameRef.startDialogue(dialogueMessages);
    }
  }
}
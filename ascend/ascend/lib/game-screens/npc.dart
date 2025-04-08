import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Npc extends SpriteAnimationComponent
    with HasGameRef<LobbyWorld>, TapCallbacks {
  final List<String> dialogueMessages = [
    "Welcome to Ascend, adventurer.",
    "This is not just a game — it’s your journey to power.",
    "Across different levels, you’ll fight mobs, dodge projectiles, and face mighty bosses.",
    "Portals will take you to these levels. Just step in… if you dare.",
    "Tap on the leaderboard signboard to see how you rank against others.",
    "But here’s the catch...",
    "Your character is powered by *you* — your real-life workouts.",
    "No workouts? Then your character won’t move an inch.",
    "Ignore your fitness, and you’ll die a slow, pitiful death. Probably alone. Probably during a boss fight.",
    "Each rep you complete gives you strength — both in-game and out.",
    "Every squat, push-up, and jump fuels your fire.",
    "Slack off, and your enemies will crush you. The FireDemon shows no mercy.",
    "Train consistently, and you’ll rise through the ranks — maybe even reach the top of the leaderboard.",
    "Remember: in Ascend, the grind is real — literally.",
    "Are you ready to fight, train, and rise?",
    "Then step forward, warrior... and begin your ascent.",
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

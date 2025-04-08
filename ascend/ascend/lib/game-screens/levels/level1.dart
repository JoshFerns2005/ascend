import 'package:ascend/game-screens/Player.dart';
import 'package:ascend/game-screens/constants.dart';
import 'package:ascend/game-screens/firedemon.dart';
import 'package:ascend/game-screens/platform.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class Level1 extends World with HasGameRef, HasCollisionDetection {
  final BuildContext buildContext;
  final String selectedGender;
  final String selectedCharacter;

  late Player player;
  late Platform platform;
  late FireDemon fireDemon;
  late TextComponent healthText;

  bool isLeftPressed = false;
  bool isRightPressed = false;

  Level1({
    required this.selectedGender,
    required this.selectedCharacter,
    required this.buildContext,
  });

  @override
  Future<void> onLoad() async {
    // Background
    final background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('game_images/background.jpg')
      ..size = gameRef.size;
    add(background);

    // Platform
    platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, gameRef.size.y - 50);
    add(platform);

    // Player
    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90)
      ..position = Vector2(gameRef.size.x / 2 + 500, platform.y - 120)
      ..priority = 2;
    add(player);

    // Health Text
// Create a rounded rectangle background
    final healthBackground = RectangleComponent(
      size: Vector2(160, 40),
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill,
      priority: 99,
    );

// Optional: Add a border
    final healthBorder = RectangleComponent(
      size: Vector2(160, 40),
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 98,
    );

// Health text with slight adjustment
    healthText = TextComponent(
      text:
          'Health: ${player.currentHealth.toInt()}/${player.maxHealth.toInt()}',
      position: Vector2(20, 20),
      anchor: Anchor.topLeft,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(1, 1),
            )
          ],
        ),
      ),
    );

// Add all components
    add(healthBackground);
    add(healthBorder);
    add(healthText);

    // FireDemon
    final fireDemon = FireDemon(player,
        Vector2(gameRef.size.x - 300, platform.y - 150), this, buildContext);
    add(fireDemon);

    // Add on-screen buttons
    addButtons();

    debugPrint('Level 1 player created - no duplicates');
  }

  void addButtons() {
    final leftButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80),
        paint: Paint()..color = Colors.blue.withOpacity(0.5),
      ),
      onPressed: () => isLeftPressed = true,
      onReleased: () => isLeftPressed = false,
      position: Vector2(40, gameRef.size.y - 100),
    );

    final rightButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80),
        paint: Paint()..color = Colors.blue.withOpacity(0.5),
      ),
      onPressed: () => isRightPressed = true,
      onReleased: () => isRightPressed = false,
      position: Vector2(140, gameRef.size.y - 100),
    );

    final jumpButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80),
        paint: Paint()..color = Colors.green.withOpacity(0.5),
      ),
      onPressed: () {
        if (!player.isJumping) player.jump();
      },
      position: Vector2(gameRef.size.x - 180, gameRef.size.y - 100),
    );

    final attackButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80),
        paint: Paint()..color = Colors.red.withOpacity(0.5),
      ),
      onPressed: () => player.attack(),
      position: Vector2(gameRef.size.x - 90, gameRef.size.y - 100),
    );

    add(leftButton);
    add(rightButton);
    add(jumpButton);
    add(attackButton);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update health display
    healthText.text =
        '${player.currentHealth.toInt()} / ${player.maxHealth.toInt()}';

    // Handle movement
    Vector2 movement = Vector2.zero();
    if (isLeftPressed) movement.x -= 1;
    if (isRightPressed) movement.x += 1;
    player.move(movement);

    // Screen wrapping
    if (player.position.x > Constants.screenWidth) {
      player.position.x = -player.width;
    } else if (player.position.x + player.width < 0) {
      player.position.x = Constants.screenWidth;
    }
  }
}

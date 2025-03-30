import 'package:ascend/game-screens/Player.dart';
import 'package:ascend/game-screens/constants.dart';
import 'package:ascend/game-screens/platform.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class Level1 extends World with HasGameRef {
  final String selectedGender;
  final String selectedCharacter;
  late Player player;
  late Platform platform;
  
  bool isLeftPressed = false;
  bool isRightPressed = false;

  Level1({
    required this.selectedGender,
    required this.selectedCharacter,
  });

  @override
  Future<void> onLoad() async {
    // No need to remove player here since LobbyWorld already cleared everything
    
    // Background
    final background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('game_images/background.jpg')
      ..size = gameRef.size;
    add(background);

    // Platform
    platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, gameRef.size.y - 50);
    add(platform);

    // Create ONLY ONE player instance
    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90)
      ..position = Vector2(gameRef.size.x / 2 + 500, platform.y - 120)
      ..priority = 2;
    add(player);

    // Camera setup
    gameRef.camera.follow(player);

    // Add control buttons
    addButtons();

    debugPrint('Level 1 player created - no duplicates');
  }

  void addButtons() {
    // Left Button

    // Left Button
    final leftButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color = Colors.blue.withOpacity(0.5), // Semi-transparent blue color
      ),
      onPressed: () {
        isLeftPressed = true; // Set flag when button is pressed
      },
      onReleased: () {
        isLeftPressed = false; // Reset flag when button is released
      },
      position: Vector2(
          40, gameRef.size.y - 100), // Positioned horizontally at the bottom-left
    );

    // Right Button
    final rightButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color = Colors.blue.withOpacity(0.5), // Semi-transparent blue color
      ),
      onPressed: () {
        isRightPressed = true; // Set flag when button is pressed
      },
      onReleased: () {
        isRightPressed = false; // Reset flag when button is released
      },
      position:
          Vector2(140, gameRef.size.y - 100), // Positioned next to the Left button
    );

    // Jump Button
    final jumpButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color =
              Colors.green.withOpacity(0.5), // Semi-transparent green color
      ),
      onPressed: () {
        if (!player.isJumping) {
          player
              .jump(); // Call the jump method on the player only if not already jumping
        }
      },
      position: Vector2(
          gameRef.size.x - 180,
          gameRef.size.y -
              100), // Positioned horizontally at the bottom, opposite to the Left/Right buttons
    );

    // Hit Button
    final attackButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color = Colors.red.withOpacity(0.5), // Semi-transparent red color
      ),
      onPressed: () {
        player.attack(); // Call the attack method on the player
      },
      position: Vector2(
          gameRef.size.x - 90, gameRef.size.y - 100), // Positioned next to the Jump button
    );

    // Add buttons to the game
    add(leftButton);
    add(rightButton);
    add(jumpButton);
    add(attackButton);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Movement handling
    Vector2 movement = Vector2(0, 0);
    if (isLeftPressed) movement.x -= 1;
    if (isRightPressed) movement.x += 1;
    player.move(movement);

    // Screen wrapping
    if (player.position.x > Constants.screenWidth) {
      player.position.x = 0 - player.width;
    } else if (player.position.x + player.width < 0) {
      player.position.x = Constants.screenWidth;
    }
  }
}
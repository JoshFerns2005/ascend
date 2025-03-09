import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'platform.dart';
import 'constants.dart';

class LobbyWorld extends FlameGame {
  late Player player;
  final String selectedGender;
  final String selectedCharacter;

  // Buttons
  late ButtonComponent leftButton;
  late ButtonComponent rightButton;
  late ButtonComponent jumpButton;
  late ButtonComponent attackButton;
  late ButtonComponent hitButton;

  bool isLeftPressed = false;
  bool isRightPressed = false;

  // Reset counter
  int resetCounter = 0;

  // Parallax background
  late ParallaxComponent parallax;

  LobbyWorld({
    required this.selectedGender,
    required this.selectedCharacter,
  });

  @override
  Future<void> onLoad() async {
    // Reset the game state twice before loading components
    await resetGameTwice();

    // Add the parallax background
    await addParallaxBackground();

    // Load the platform
    final platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, size.y - 50)
      ..width = size.x;
    add(platform);

    // Initialize the player with reduced width
    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90) // Reduce the width of the player
      ..position = Vector2(size.x / 2, platform.y - 100); // Adjusted position
    add(player);

    // Add a camera that follows the player
    camera.follow(player);

    // Add Left, Right, Jump, and Hit buttons
    addButtons();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update player movement based on button states
    if (isLeftPressed) {
      player.move(Vector2(-1, 0)); // Move left
    } else if (isRightPressed) {
      player.move(Vector2(1, 0)); // Move right
    } else {
      player.move(Vector2(0, 0)); // Idle when no button is pressed
    }

    // Update parallax background based on player movement
    updateParallax(dt);
  }

  // Method to reset the game state twice
  Future<void> resetGameTwice() async {
    while (resetCounter < 2) {
      resetGame();
      resetCounter++;
      await Future.delayed(
          const Duration(milliseconds: 500)); // Delay between resets
    }
  }

  // Method to reset the game state
  void resetGame() {
    // Clear all existing components
    children.clear();

    // Reset any static or global state variables if needed
    // For example, reset player position, score, etc.
  }

  // Method to add Left, Right, Jump, and Hit buttons
  void addButtons() {
    // Left Button
    leftButton = ButtonComponent(
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
          40, size.y - 100), // Positioned horizontally at the bottom-left
    );

    // Right Button
    rightButton = ButtonComponent(
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
          Vector2(140, size.y - 100), // Positioned next to the Left button
    );

    // Jump Button
    jumpButton = ButtonComponent(
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
          size.x - 180,
          size.y -
              100), // Positioned horizontally at the bottom, opposite to the Left/Right buttons
    );

    // Hit Button
    attackButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color = Colors.red.withOpacity(0.5), // Semi-transparent red color
      ),
      onPressed: () {
        player.attack(); // Call the attack method on the player
      },
      position: Vector2(
          size.x - 90, size.y - 100), // Positioned next to the Jump button
    );

    hitButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(80, 80), // Size of the button
        paint: Paint()
          ..color = const Color.fromARGB(255, 0, 0, 0)
              .withOpacity(0.5), // Semi-transparent red color
      ),
      onPressed: () {
        player.attack(); // Call the attack method on the player
      },
      position: Vector2(
          size.x - 90, size.y - 200), // Positioned next to the Jump button
    );

    // Add buttons to the game
    add(leftButton);
    add(rightButton);
    add(jumpButton);
    add(attackButton);
    add(hitButton);
  }

 Future<void> addParallaxBackground() async {
  parallax = await loadParallaxComponent(
    [
      ParallaxImageData('game_images/background.jpg'), // Background layer
    ],
    baseVelocity: Vector2(0, 0), // Initial velocity
    repeat: ImageRepeat.repeat, // Repeat the background infinitely
  );

  add(parallax);
}

 void updateParallax(double dt) {
  double parallaxSpeed = 100; // Adjust the speed of the parallax effect

  // Update the parallax velocity based on player movement
  if (isLeftPressed) {
    parallax.parallax?.baseVelocity = Vector2(-parallaxSpeed, 0); // Move background right
  } else if (isRightPressed) {
    parallax.parallax?.baseVelocity = Vector2(parallaxSpeed, 0); // Move background left
  } else {
    parallax.parallax?.baseVelocity = Vector2(0, 0); // Stop parallax movement
  }
}
}

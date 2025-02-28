import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'platform.dart';
import 'constants.dart';
import 'background.dart'; // Import the Background class

class LobbyWorld extends FlameGame {
  late Player player;
  late JoystickComponent joystick;
  final String selectedGender;

  // Buttons
  late ButtonComponent jumpButton;
  late ButtonComponent hitButton;

  // Reset counter
  int resetCounter = 0;

  LobbyWorld({required this.selectedGender});

  @override
  Future<void> onLoad() async {
    // Reset the game state twice before loading components
    await resetGameTwice();

    // Add the background
    add(Background()); // Use the existing Background class

    // Load the platform
    final platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, size.y - 50)
      ..width = size.x;
    add(platform);

    // Initialize the player with reduced width
    player = Player(platform, selectedGender)
      ..size = Vector2(50, 120) // Reduce the width of the player
      ..position = Vector2(size.x / 2, platform.y - 100); // Adjusted position
    add(player);

    // Initialize the joystick
    final knobPaint = Paint()..color = Colors.blue.withOpacity(0.5);
    final backgroundPaint = Paint()..color = Colors.blue.withOpacity(0.2);
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    add(joystick);

    // Add Jump and Hit buttons
    addButtons();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update player movement based on joystick input
    if (joystick.direction != JoystickDirection.idle) {
      // Restrict movement to horizontal axis only
      player.move(Vector2(joystick.relativeDelta.x * dt, 0));
    }
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

  // Method to add Jump and Hit buttons
void addButtons() {
  // Jump Button
  jumpButton = ButtonComponent(
    button: RectangleComponent(
      size: Vector2(80, 80), // Size of the button
      paint: Paint()
        ..color = Colors.green.withOpacity(0.5), // Semi-transparent green color
    ),
    onPressed: () {
      player.jump(); // Call the jump method on the player
    },
    position: Vector2(size.x - 180, size.y - 100), // Positioned horizontally at the bottom, opposite to the joystick
  );

  // Hit Button
  hitButton = ButtonComponent(
    button: RectangleComponent(
      size: Vector2(80, 80), // Size of the button
      paint: Paint()
        ..color = Colors.red.withOpacity(0.5), // Semi-transparent red color
    ),
    onPressed: () {
      // Placeholder for hit functionality
      print('Hit button pressed');
    },
    position: Vector2(size.x - 90, size.y - 100), // Positioned next to the Jump button
  );

  // Add buttons to the game
  add(jumpButton);
  add(hitButton);
}
}

import 'package:ascend/game-screens/dialogue_box.dart';
import 'package:ascend/game-screens/leaderboard.dart';
import 'package:ascend/game-screens/levels/level1.dart';
import 'package:ascend/game-screens/levelselection.dart';
import 'package:ascend/game-screens/npc.dart';
import 'package:ascend/game-screens/portal.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
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
  int unlockedLevels = 1; // Start with only level 1 unlocked

  bool isLeftPressed = false;
  bool isRightPressed = false;

  // Reset counter
  int resetCounter = 0;

  // Boundaries (not needed for endless loop)
  final double leftBoundary = 0; // Left boundary of the game world
  late double rightBoundary; // Dynamically set right boundary

  LobbyWorld({
    required this.selectedGender,
    required this.selectedCharacter,
  });

  @override
  Future<void> onLoad() async {
    // Reset the game state twice before loading components
    await resetGameTwice();

    // Add the static background
    final background = SpriteComponent()
      ..sprite = await loadSprite('game_images/background.jpg')
      ..size = size; // Stretch the background to fit the screen
    add(background);

    // Load the platform
    final platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, size.y - 50)
      ..width = size.x;
    add(platform);

    final portal = Portal(
      position: Vector2(size.x - 200, size.y - 300),
      unlockedLevels: unlockedLevels,
      // Adjust position as needed
    );
    add(portal);

    // Initialize the player with reduced width
    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90)
      ..position = Vector2(size.x / 2, platform.y -90)
      ..priority = 2;
    add(player);

    // Set right boundary based on screen width and player width
    rightBoundary = Constants.screenWidth - 80;

    // Configure the camera to follow the player
    camera.follow(player);

    // Add Left, Right, Jump, and Hit buttons
    addButtons();

    // Add Leaderboard Signboard
    addLeaderboardSignboard();

    // Register the leaderboard overlay
    overlays.addEntry(
      'LeaderboardOverlay',
      (BuildContext context, Game game) =>
          LeaderboardOverlay(game: game as LobbyWorld),
    );

    // Add the NPC
    final npc = Npc(
      position: Vector2(size.x / 2 - 300, platform.y - 120),
    );
    add(npc);
  }

  Future<void> startLevel1() async {
    // Show loading overlay
    overlays.add('loading');

    // Wait for next frame to ensure clean transition
    await Future.delayed(Duration.zero);

    // Remove ALL components including the player
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    children.whereType<World>().forEach((w) => w.removeFromParent());
    children.whereType<CameraComponent>().forEach((c) => c.removeFromParent());

    // Create fresh level instance
    final level1 = Level1(
      selectedGender: selectedGender,
      selectedCharacter: selectedCharacter,
    );

    // Setup camera
    final camera = CameraComponent(world: level1)
      ..viewfinder.anchor = Anchor.topLeft;

    // Add new level
    addAll([level1, camera]);

    // Wait for level to fully load
    try {
      await level1.onLoad();
      debugPrint('Level 1 loaded successfully - no duplicates');
    } catch (e) {
      debugPrint('Error loading Level 1: $e');
      // Fallback: Return to lobby
      _returnToLobby();
    } finally {
      overlays.remove('loading');
    }
  }

  void _returnToLobby() {
    // Recreate lobby state if level fails to load
    final platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, size.y - 50);
    add(platform);

    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90)
      ..position = Vector2(size.x / 2, platform.y - 120)
      ..priority = 2;
    add(player);

    camera.follow(player);
    addButtons();
  }

  void completeLevel(int level) {
    if (level == unlockedLevels) {
      unlockedLevels++;
      // Save progress (you might want to use shared_preferences)
    }
  }

  // Method to add the leaderboard signboard
  void addLeaderboardSignboard() async {
    // Create the leaderboard signboard component
    final leaderboardSignboard = LeaderboardSignboard()
      ..sprite = await loadSprite(
          'game_images/leaderboard.png') // Load the leaderboard image
      ..size = Vector2(150, 100) // Set the size of the leaderboard signboard
      ..position = Vector2(size.x - 400, size.y / 2) // Position it
      ..priority = 1; // Ensure it's above the background but below the player

    // Add the leaderboard signboard to the game world
    add(leaderboardSignboard);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Calculate the intended movement vector
    Vector2 movement = Vector2(0, 0);
    if (isLeftPressed) {
      movement.x -= 1; // Move left
    }
    if (isRightPressed) {
      movement.x += 1; // Move right
    }

    // Apply the movement to the player
    player.move(movement);

    // Endless loop logic
    if (player.position.x > Constants.screenWidth) {
      // Player has moved past the right boundary
      player.position.x = 0 - player.width; // Teleport to the left side
    } else if (player.position.x + player.width < 0) {
      // Player has moved past the left boundary
      player.position.x = Constants.screenWidth; // Teleport to the right side
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

  bool isDialogueActive = false;
  void startDialogue(List<String> messages) {
    if (isDialogueActive) return;
    isDialogueActive = true;

    // Remove existing dialogue if any
    children.whereType<DialogueBox>().forEach((box) => box.removeFromParent());

    final dialogueBox = DialogueBox(messages: messages)
      ..anchor = Anchor.bottomCenter
      ..position = size / 2;

    add(dialogueBox);
  }

  void endDialogue() {
    isDialogueActive = false;
  }

  // Method to add Left, Right, Jump, and Hit buttons
  void addButtons() {
    // Close Button
    final closeButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(50, 50), // Size of the button
        paint: Paint()
          ..color =
              Colors.black.withOpacity(0.5), // Semi-transparent black color
      ),
      onPressed: () {
        // Close the game and navigate back to the home screen
        if (buildContext != null) {
          Navigator.of(buildContext!).pop();
        }
      },
      position: Vector2(size.x - 60, 20), // Positioned at the top-right corner
    );
    add(closeButton);

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

    // Add buttons to the game
    add(leftButton);
    add(rightButton);
    add(jumpButton);
    add(attackButton);
  }
}

class LeaderboardSignboard extends SpriteComponent
    with TapCallbacks, HasGameRef<LobbyWorld> {
  @override
  void onTapDown(TapDownEvent event) {
    // Show the leaderboard overlay
    if (gameRef is LobbyWorld) {
      // Use Navigator to push the Leaderboard page
      Navigator.of(gameRef.buildContext!).push(
        MaterialPageRoute(
          builder: (context) => Leaderboard(),
        ),
      );
    }
  }
}

class LeaderboardOverlay extends StatelessWidget {
  final LobbyWorld game;

  LeaderboardOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Leaderboard();
  }
}

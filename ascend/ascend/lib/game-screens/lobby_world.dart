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
  int unlockedLevels = 1; 
  bool isLeftPressed = false;
  bool isRightPressed = false;

  int resetCounter = 0;

  final double leftBoundary = 0; 
  late double rightBoundary;

  LobbyWorld({
    required this.selectedGender,
    required this.selectedCharacter,
  });

  @override
  Future<void> onLoad() async {
    await resetGameTwice();

    final background = SpriteComponent()
      ..sprite = await loadSprite('game_images/background.jpg')
      ..size = size; 
    add(background);

    final platform = Platform(Constants.screenWidth)
      ..position = Vector2(0, size.y - 50)
      ..width = size.x;
    add(platform);

    final portal = Portal(
      position: Vector2(size.x - 200, size.y - 300),
      unlockedLevels: unlockedLevels,
    );
    add(portal);

    player = Player(platform, selectedGender, selectedCharacter)
      ..size = Vector2(90, 90)
      ..position = Vector2(size.x / 2, platform.y - 90)
      ..priority = 2;
    add(player);

    rightBoundary = Constants.screenWidth - 80;

    camera.follow(player);

    addButtons();

    addLeaderboardSignboard();

    overlays.addEntry(
      'LeaderboardOverlay',
      (BuildContext context, Game game) =>
          LeaderboardOverlay(game: game as LobbyWorld),
    );

    final npc = Npc(
      position: Vector2(size.x / 2 - 300, platform.y - 120),
    );
    add(npc);
  }

  Future<void> startLevel1() async {
    overlays.add('loading');
    await Future.delayed(Duration.zero);

    children.whereType<World>().firstOrNull?.removeFromParent();

    final level1 = Level1(
      selectedGender: selectedGender,
      selectedCharacter: selectedCharacter,
      buildContext: buildContext!,
    );

    final camera = CameraComponent(world: level1)
      ..viewfinder.anchor = Anchor.topLeft;

    addAll([level1, camera]);

    overlays.remove('loading');
  }

  void _returnToLobby() {
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
    }
  }

  void addLeaderboardSignboard() async {
    final leaderboardSignboard = LeaderboardSignboard()
      ..sprite = await loadSprite(
          'game_images/leaderboard.png')
      ..size = Vector2(150, 100) 
      ..position = Vector2(size.x - 400, size.y / 2) 
      ..priority = 1;

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

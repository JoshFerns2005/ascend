import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';

class LevelSelection extends PositionComponent with HasGameRef<LobbyWorld> {
  final int unlockedLevels;

  LevelSelection({required this.unlockedLevels});

  @override
  Future<void> onLoad() async {
    size = Vector2(gameRef.size.x * 0.8, gameRef.size.y * 0.8);
    position = Vector2(gameRef.size.x * 0.1, gameRef.size.y * 0.1);
    priority = 1000;

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xDD000000),
    ));

    add(TextComponent(
      text: "SELECT LEVEL",
      position: Vector2(size.x / 2, 30),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    final backButton = TextButtonComponent(
      text: "BACK",
      position: Vector2(20, 20),
      size: Vector2(80, 40),
      onPressed: () {
        removeFromParent(); 
      },
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      button: RectangleComponent(
        size: Vector2(80, 40),
        paint: Paint()..color = Colors.red,
      ),
    );
    add(backButton);


final lobbyButton = TextButtonComponent(
  text: "LOBBY",
  position: Vector2(size.x - 100, 20),
  size: Vector2(80, 40),
  onPressed: () {
    if (gameRef.buildContext != null && gameRef.buildContext!.mounted) {
      Navigator.of(gameRef.buildContext!).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameWidget(
            game: LobbyWorld(
              selectedGender: gameRef.player.selectedGender,
              selectedCharacter: gameRef.player.selectedCharacter,
            ),
          ),
        ),
      );
    }
  },
  textRenderer: TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  button: RectangleComponent(
    size: Vector2(80, 40),
    paint: Paint()..color = Colors.green,
  ),
);
    add(lobbyButton);

    const levelCount = 10;
    const columns = 5;
    const buttonSize = 80.0;
    const spacing = 20.0;

    for (var i = 0; i < levelCount; i++) {
      final row = i ~/ columns;
      final col = i % columns;

      final x = spacing + col * (buttonSize + spacing);
      final y = 100 + row * (buttonSize + spacing);

      final isUnlocked = i + 1 <= unlockedLevels;
      final isComingSoon = i + 1 > unlockedLevels + 1;

      add(LevelButton(
        level: i + 1,
        position: Vector2(x, y),
        size: Vector2.all(buttonSize),
        isUnlocked: isUnlocked,
        isComingSoon: isComingSoon,
      ));
    }
  }
}

class TextButtonComponent extends PositionComponent with TapCallbacks {
  final String text;
  final TextPaint textRenderer;
  final PositionComponent button;
  final VoidCallback onPressed;

  TextButtonComponent({
    required this.text,
    required super.position,
    required super.size,
    required this.onPressed,
    required this.textRenderer,
    required this.button,
  });

  @override
  Future<void> onLoad() async {
    add(button);
    add(TextComponent(
      text: text,
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: textRenderer,
    ));
    add(RectangleHitbox());
  }

  @override
  void onTapDown(TapDownEvent event) => onPressed();
}

class LevelButton extends PositionComponent with TapCallbacks, HasGameRef {
  final int level;
  final bool isUnlocked;
  final bool isComingSoon;

  LevelButton({
    required this.level,
    required super.position,
    required super.size,
    required this.isUnlocked,
    required this.isComingSoon,
  });

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = isUnlocked ? Colors.blue : Colors.grey,
    ));

    add(TextComponent(
      text: isComingSoon ? "COMING\nSOON" : "$level",
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: isComingSoon ? 14 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    if (isUnlocked) {
      add(RectangleHitbox()..debugMode = false);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isUnlocked && !isComingSoon) {
      switch (level) {
        case 1:
          (gameRef as LobbyWorld).startLevel1();
          parent?.removeFromParent();
          break;
      }
    }
  }
}

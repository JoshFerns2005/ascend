import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class DialogueBox extends PositionComponent with HasGameRef<LobbyWorld>, TapCallbacks {
  final List<String> messages;
  int currentIndex = 0;
  late TextPainter textPainter;
  
  final textStyle = TextStyle(
    color: const Color.fromARGB(255, 255, 255, 255), 
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  DialogueBox({required this.messages}) {
    textPainter = TextPainter(
      text: TextSpan(text: messages.first, style: textStyle),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(gameRef.size.x, 120);
    position = Vector2(
      450,
      gameRef.size.y 
    );
    priority = 1000;
    
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color.fromARGB(123, 0, 0, 0),
      priority: 5
    );
    add(background);
    
    textPainter.layout(maxWidth: size.x - 40);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    textPainter.paint(
      canvas,
      Offset(
        20, 
        30,
      ),
    );
    
    final indicatorText = '${currentIndex + 1}/${messages.length}';
    final indicatorPainter = TextPainter(
      text: TextSpan(
        text: indicatorText,
        style: textStyle.copyWith(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    indicatorPainter.paint(
      canvas,
      Offset(
        size.x - indicatorPainter.width - 20,
        size.y - 30, 
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (currentIndex < messages.length - 1) {
      currentIndex++;
      textPainter.text = TextSpan(text: messages[currentIndex], style: textStyle);
      textPainter.layout(maxWidth: size.x - 40);
    } else {
      gameRef.endDialogue();
      removeFromParent();
    }
  }
}
import 'package:ascend/game-screens/lobby_world.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class DialogueBox extends PositionComponent with HasGameRef<LobbyWorld>, TapCallbacks {
  final List<String> messages;
  int currentIndex = 0;
  late TextPainter textPainter;
  
  // Text styling
  final textStyle = TextStyle(
    color: const Color.fromARGB(255, 255, 255, 255), // Solid black text
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  DialogueBox({required this.messages}) {
    // Initialize text painter with first message
    textPainter = TextPainter(
      text: TextSpan(text: messages.first, style: textStyle),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  Future<void> onLoad() async {
    // Set dialog box dimensions - full width and 120px tall
    size = Vector2(gameRef.size.x, 120); // Full screen width
    position = Vector2(
      450, // Start from left edge
      gameRef.size.y // Stick to bottom
    );
    priority = 1000; // Ensure it renders above other components
    
    // Create and add the semi-transparent background rectangle
    final background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color.fromARGB(123, 0, 0, 0), // More opaque
      priority: 5
    );
    add(background);
    
    // Layout the text with 20px margins on sides
    textPainter.layout(maxWidth: size.x - 40);
  }

  @override
  void render(Canvas canvas) {
    // First render the background (this will be underneath)
    super.render(canvas);
    
    // Then render the text ON TOP of everything
    textPainter.paint(
      canvas,
      Offset(
        20, // Left margin instead of centering
        30, // Fixed top margin within the box
      ),
    );
    
    // Add page indicator in bottom right
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
        size.x - indicatorPainter.width - 20, // Right margin
        size.y - 30, // Bottom margin
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (currentIndex < messages.length - 1) {
      currentIndex++;
      textPainter.text = TextSpan(text: messages[currentIndex], style: textStyle);
      textPainter.layout(maxWidth: size.x - 40); // Keep consistent margin
    } else {
      gameRef.endDialogue();
      removeFromParent();
    }
  }
}
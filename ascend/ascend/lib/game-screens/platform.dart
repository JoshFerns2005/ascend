import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Platform extends PositionComponent with CollisionCallbacks {
  final double screenWidth;
  final double platformHeight = 20;
  bool debugVisible = false; // Set to true to see platform during development

  Platform(this.screenWidth);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set platform dimensions and position
    size = Vector2(screenWidth + 100, platformHeight);
    position = Vector2(0, Constants.screenHeight * 0.8 - platformHeight);

    // Add visual representation (only visible if debugVisible is true)
    if (debugVisible) {
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(255, 139, 69, 19), // Brown
      ));
    }

    // Add collision hitbox (always present)
    add(RectangleHitbox(
      size: size,
      isSolid: true,
    )..debugMode = debugVisible);
  }
}

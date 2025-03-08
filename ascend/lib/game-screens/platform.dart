import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Platform extends PositionComponent {
  final double screenWidth;
  final double platformHeight = 20; // Instance member

  Platform(this.screenWidth) : super(); // Remove the size from the initializer

  @override
  Future<void> onLoad() async {
    // Set the size dynamically in onLoad
    size = Vector2(screenWidth, platformHeight);

    // Position the platform at the bottom of the screen
    position = Vector2(0, Constants.screenHeight * 0.8 - platformHeight);

    // Add a brown rectangle to represent the platform
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color.fromARGB(0, 139, 69, 19), // Brown color
    ));
  }
}
import 'package:flutter/material.dart';

class PoseLinePainter extends CustomPainter {
  final bool isPushUp;
  final bool isSquat;
  final double? pushUpYPosition; // Vertical line position for push-ups
  final double? squatXPosition;  // Horizontal line position for squats

  PoseLinePainter({
    required this.isPushUp,
    required this.isSquat,
    this.pushUpYPosition,
    this.squatXPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0;

    // Draw the vertical line for push-up position (if applicable)
    if (isPushUp && pushUpYPosition != null) {
      canvas.drawLine(
        Offset(0, pushUpYPosition!),
        Offset(size.width, pushUpYPosition!),
        linePaint,
      );
    }

    // Draw the horizontal line for squat position (if applicable)
    if (isSquat && squatXPosition != null) {
      canvas.drawLine(
        Offset(squatXPosition!, 0),
        Offset(squatXPosition!, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

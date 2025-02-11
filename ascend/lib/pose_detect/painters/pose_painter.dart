import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';
import 'joint_deg.dart';

enum NowPoses { pushup, squat, crunch }

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  static NowPoses nowPose = NowPoses.pushup; // Default to pushups

  // Static/global state variables for counting
  static int pushUpCounter = 0; // Counter for push-ups
  static bool hasGoneDown = false; // Flag to track bottom position
  static int transitionCount = 0; // Transition count
  static int transitionToOneCount = 0; // Transition to "1" count

  // Angle thresholds
  final double shoulderTopMin = 20.0;
  final double shoulderTopMax = 80.0;
  final double shoulderBottomMin = 0.0;
  final double shoulderBottomMax = 30.0;
  final double elbowTopMin = 140.0;
  final double elbowTopMax = 170.0;
  final double elbowBottomMin = 60.0;
  final double elbowBottomMax = 90.0;
  final double kneeTopMin = 165.0;
  final double kneeTopMax = 185.0;
  final double kneeBottomMin = 170.0;
  final double kneeBottomMax = 185.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      final JointDeg jointDeg = JointDeg(pose, cameraHeight: 1.6);

      // Retrieve angles for shoulders, elbows, and knees
      final String? rightShoulderAngle = jointDeg.getRightShoulder();
      final String? rightElbowAngle = jointDeg.getRightElbow();
      final String? rightKneeAngle = jointDeg.getRightKnee();

      // Convert angle strings to doubles
      double shoulderAngle = double.tryParse(rightShoulderAngle ?? '') ?? 0.0;
      double elbowAngle = double.tryParse(rightElbowAngle ?? '') ?? 0.0;
      double kneeAngle = double.tryParse(rightKneeAngle ?? '') ?? 0.0;

      // Print debug information
      print(
          'Shoulder Angle: $shoulderAngle, Elbow Angle: $elbowAngle, Knee Angle: $kneeAngle');

      // Detect position and update state
      if (isAtBottomPosition(shoulderAngle, elbowAngle, kneeAngle)) {
        if (!hasGoneDown) {
          hasGoneDown = true; // User has gone down
          print('User has gone to the bottom position.');
        }
      } else if (isAtTopPosition(shoulderAngle, elbowAngle, kneeAngle)) {
        if (hasGoneDown) {
          pushUpCounter++; // Increment push-up counter
          transitionCount++; // Increment transition count
          transitionToOneCount++; // Increment transition to "1" count
          hasGoneDown = false; // Reset flag so next down movement can be detected
          print(
              'User has gone up to top position. Push-ups: $pushUpCounter, Transitions: $transitionCount, Transition to 1 Count: $transitionToOneCount');
        }
      } else {
        print('User is in a transitional state.');
      }

      // Draw landmarks and lines
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, size, imageSize, rotation,
                cameraLensDirection, 1.6),
            translateY(landmark.y, size, imageSize, rotation,
                cameraLensDirection, 1.6),
          ),
          1,
          paint,
        );
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark? joint1 = pose.landmarks[type1];
        final PoseLandmark? joint2 = pose.landmarks[type2];
        if (joint1 != null && joint2 != null) {
          canvas.drawLine(
              Offset(
                  translateX(joint1.x, size, imageSize, rotation,
                      cameraLensDirection, 1.6),
                  translateY(joint1.y, size, imageSize, rotation,
                      cameraLensDirection, 1.6)),
              Offset(
                  translateX(joint2.x, size, imageSize, rotation,
                      cameraLensDirection, 1.6),
                  translateY(joint2.y, size, imageSize, rotation,
                      cameraLensDirection, 1.6)),
              paintType);
        }
      }

      void paintText(PoseLandmarkType type) {
        String? deg;
        switch (type) {
          case PoseLandmarkType.rightShoulder:
            deg = jointDeg.getRightShoulder();
            break;
          case PoseLandmarkType.rightElbow:
            deg = jointDeg.getRightElbow();
            break;
          case PoseLandmarkType.rightHip:
            deg = jointDeg.getRightHip();
            break;
          case PoseLandmarkType.rightKnee: // New: Handle knee angle
            deg = jointDeg.getRightKnee();
            break;
          default:
            return;
        }
        if (deg == null) {
          return;
        }
        drawText(
            canvas,
            translateX(pose.landmarks[type]!.x, size, imageSize, rotation,
                cameraLensDirection, 1.6),
            translateY(pose.landmarks[type]!.y, size, imageSize, rotation,
                cameraLensDirection, 1.6),
            deg);
      }

      // Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // Draw body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      // Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
          PoseLandmarkType.leftKnee, PoseLandmarkType.leftHeel, leftPaint);
      paintLine(
          PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(
          PoseLandmarkType.rightKnee, PoseLandmarkType.rightHeel, rightPaint);
      paintLine(PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex,
          rightPaint);

      // Display angles for push-ups
      if (NowPoses.pushup == NowPoses.pushup) {
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.rightElbow);
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightKnee); // New: Display knee angle

        // Draw push-up counter and feedback
        drawText(canvas, 80, 50, 'Push Ups: $pushUpCounter');
        drawText(canvas, 80, 80, 'Transitions: $transitionCount');
      }
    }

    // Draw feedback text
    drawText(canvas, 80, 110, 'In Progress...');
    // Draw transitionToOneCount in green
    drawTextInGreen(canvas, 80, 140, 'Transition to 1 Count: $transitionToOneCount');
  }

  bool isAtBottomPosition(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    return shoulderAngle >= shoulderBottomMin &&
        shoulderAngle <= shoulderBottomMax &&
        elbowAngle >= elbowBottomMin &&
        elbowAngle <= elbowBottomMax &&
        kneeAngle >= kneeBottomMin &&
        kneeAngle <= kneeBottomMax;
  }

  bool isAtTopPosition(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    bool result = shoulderAngle >= shoulderTopMin &&
        shoulderAngle <= shoulderTopMax &&
        elbowAngle >= elbowTopMin &&
        elbowAngle <= elbowTopMax &&
        kneeAngle >= kneeTopMin &&
        kneeAngle <= kneeTopMax;
    print(
        'Top Position Check → Shoulder: $shoulderAngle ($shoulderTopMin - $shoulderTopMax), '
        'Elbow: $elbowAngle ($elbowTopMin - $elbowTopMax), '
        'Knee: $kneeAngle ($kneeTopMin - $kneeTopMax) → Result: $result');
    return result;
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

  void drawText(Canvas canvas, double centerX, double centerY, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 18,
      ),
    );
    final textPainter = TextPainter()
      ..text = textSpan
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..layout();
    final xCenter = (centerX - textPainter.width / 2);
    final yCenter = (centerY - textPainter.height / 2);
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  // New: Method to draw text in green
  void drawTextInGreen(Canvas canvas, double centerX, double centerY, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.green,
        fontSize: 18,
      ),
    );
    final textPainter = TextPainter()
      ..text = textSpan
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..layout();
    final xCenter = (centerX - textPainter.width / 2);
    final yCenter = (centerY - textPainter.height / 2);
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }
}
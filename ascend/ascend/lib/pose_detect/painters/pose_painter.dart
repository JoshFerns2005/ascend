import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';
import 'joint_deg.dart';

enum NowPoses { pushup, squat, crunch, bicepCurl, plank }

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
  static bool hasGoneDownPushUp =
      false; // Flag to track bottom position for push-ups

  static int squatCounter = 0; // Counter for squats
  static bool hasGoneDownSquat =
      false; // Flag to track bottom position for squats

  static int crunchCounter = 0; // Counter for crunches
  static bool hasGoneDownCrunch =
      false; // Flag to track bottom position for crunches

  static int rightBicepCurlCounter = 0; // Counter for right bicep curls
  static bool hasGoneDownRightBicepCurl = false; // Flag for right bicep curls

  static int leftBicepCurlCounter = 0; // Counter for left bicep curls
  static bool hasGoneDownLeftBicepCurl = false; // Flag for left bicep curls

  static int plankCounter = 0; // Counter for planks
  static bool hasStartedPlank = false; // Flag to track plank start

  // Angle thresholds for push-ups
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

  // Angle thresholds for squats
  final double hipBottomMin = 70.0;
  final double hipBottomMax = 110.0;
  final double hipTopMin = 160.0;
  final double hipTopMax = 180.0;
  final double kneeSquatBottomMin = 70.0;
  final double kneeSquatBottomMax = 110.0;
  final double kneeSquatTopMin = 160.0;
  final double kneeSquatTopMax = 180.0;

// Angle thresholds for crunches
  final double hipCrunchBottomMin = 140.0; // Bottom position (lying down)
  final double hipCrunchBottomMax = 170.0;
  final double hipCrunchTopMin = 50.0; // Top position (sitting up)
  final double hipCrunchTopMax = 80.0;
  final double kneeCrunchBottomMin = 60.0;
  final double kneeCrunchBottomMax = 90.0;
  final double kneeCrunchTopMin = 60.0;
  final double kneeCrunchTopMax = 90.0;

  // Angle thresholds for bicep curls
  final double elbowBicepCurlBottomMin = 10.0;
  final double elbowBicepCurlBottomMax = 20.0;
  final double elbowBicepCurlTopMin = 140.0;
  final double elbowBicepCurlTopMax = 170.0;
  final double shoulderBicepCurlMin = 0.0;
  final double shoulderBicepCurlMax = 30.0;

  // Angle thresholds for planks
  final double hipPlankMin = 150.0;
  final double hipPlankMax = 180.0;
  final double shoulderPlankMin = 50.0;
  final double shoulderPlankMax = 90.0;
  final double kneePlankMin = 150.0;
  final double kneePlankMax = 180.0;
  // Timer for plank
  static Timer? _plankTimer; // Timer instance
  static bool _isPlankActive = false; // Flag to track if plank is active
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

      // Retrieve angles for shoulders, elbows, hips, and knees
      final String? rightShoulderAngle = jointDeg.getRightShoulder();
      final String? rightElbowAngle = jointDeg.getRightElbow();
      final String? rightHipAngle = jointDeg.getRightHip();
      final String? rightKneeAngle = jointDeg.getRightKnee();
      final String? leftShoulderAngle = jointDeg.getLeftShoulder();
      final String? leftElbowAngle = jointDeg.getLeftElbow();

      // Convert angle strings to doubles
      double shoulderAngle = double.tryParse(rightShoulderAngle ?? '') ?? 0.0;
      double elbowAngle = double.tryParse(rightElbowAngle ?? '') ?? 0.0;
      double hipAngle = double.tryParse(rightHipAngle ?? '') ?? 0.0;
      double kneeAngle = double.tryParse(rightKneeAngle ?? '') ?? 0.0;
      double rightShoulderAngleValue =
          double.tryParse(rightShoulderAngle ?? '') ?? 0.0;
      double rightElbowAngleValue =
          double.tryParse(rightElbowAngle ?? '') ?? 0.0;
      double leftShoulderAngleValue =
          double.tryParse(leftShoulderAngle ?? '') ?? 0.0;
      double leftElbowAngleValue = double.tryParse(leftElbowAngle ?? '') ?? 0.0;
      // Print debug information

      // Detect position and update state based on current pose
      if (nowPose == NowPoses.pushup) {
        handlePushUp(shoulderAngle, elbowAngle, kneeAngle);
      } else if (nowPose == NowPoses.squat) {
        handleSquat(hipAngle, kneeAngle);
      } else if (nowPose == NowPoses.crunch) {
        handleCrunch(hipAngle, kneeAngle);
      } else if (nowPose == NowPoses.bicepCurl) {
        handleRightBicepCurl(rightElbowAngleValue, rightShoulderAngleValue);
        handleLeftBicepCurl(leftElbowAngleValue, leftShoulderAngleValue);
      } else if (nowPose == NowPoses.plank) {
        handlePlank(hipAngle, shoulderAngle, kneeAngle);
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
                  cameraLensDirection, 1.6),
            ),
            Offset(
              translateX(joint2.x, size, imageSize, rotation,
                  cameraLensDirection, 1.6),
              translateY(joint2.y, size, imageSize, rotation,
                  cameraLensDirection, 1.6),
            ),
            paintType,
          );
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
          case PoseLandmarkType.rightKnee:
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
          deg,
        );
      }

      // Draw body parts
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      // Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

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

      // Display angles and counters based on current pose
      if (nowPose == NowPoses.pushup) {
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.rightElbow);
        drawText(canvas, 80, 50, 'Push-Ups: $pushUpCounter');
      } else if (nowPose == NowPoses.squat) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Squats: $squatCounter');
      } else if (nowPose == NowPoses.crunch) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Crunches: $crunchCounter');
      } else if (nowPose == NowPoses.bicepCurl) {
        paintText(PoseLandmarkType.rightElbow);
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.leftElbow);
        paintText(PoseLandmarkType.leftShoulder);
        drawText(canvas, 80, 50, 'Right Bicep Curls: $rightBicepCurlCounter');
        drawText(canvas, 80, 70, 'Left Bicep Curls: $leftBicepCurlCounter');
      } else if (nowPose == NowPoses.plank) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Plank: $plankCounter');
      }

      // Feedback text
      drawText(canvas, 80, 80, 'In Progress...');
    }
  }

  void handlePushUp(double shoulderAngle, double elbowAngle, double kneeAngle) {
    if (isAtBottomPositionPushUp(shoulderAngle, elbowAngle, kneeAngle)) {
      if (!hasGoneDownPushUp) {
        hasGoneDownPushUp = true;
        print('User has gone to the bottom position for push-ups.');
      }
    } else if (isAtTopPositionPushUp(shoulderAngle, elbowAngle, kneeAngle)) {
      if (hasGoneDownPushUp) {
        pushUpCounter++;
        hasGoneDownPushUp = false;
        print('User has completed a push-up. Push-Ups: $pushUpCounter');
      }
    }
  }

  void handleSquat(double hipAngle, double kneeAngle) {
    if (isAtBottomPositionSquat(hipAngle, kneeAngle)) {
      if (!hasGoneDownSquat) {
        hasGoneDownSquat = true;
        print('User has gone to the bottom position for squats.');
      }
    } else if (isAtTopPositionSquat(hipAngle, kneeAngle)) {
      if (hasGoneDownSquat) {
        squatCounter++;
        hasGoneDownSquat = false;
        print('User has completed a squat. Squats: $squatCounter');
      }
    }
  }

  void handleCrunch(double hipAngle, double kneeAngle) {
    if (isAtBottomPositionCrunch(hipAngle, kneeAngle)) {
      if (!hasGoneDownCrunch) {
        hasGoneDownCrunch = true; // User has gone to the bottom position
        print('User has gone to the bottom position for crunches.');
      }
    } else if (isAtTopPositionCrunch(hipAngle, kneeAngle)) {
      if (hasGoneDownCrunch) {
        crunchCounter++; // Increment the crunch counter
        hasGoneDownCrunch = false; // Reset the flag
        print('User has completed a crunch. Crunches: $crunchCounter');
      }
    }
  }

  void handleRightBicepCurl(double elbowAngle, double shoulderAngle) {
    if (isAtBottomPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (!hasGoneDownRightBicepCurl) {
        hasGoneDownRightBicepCurl = true;
        print('User has gone to the bottom position for right bicep curls.');
      }
    } else if (isAtTopPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (hasGoneDownRightBicepCurl) {
        rightBicepCurlCounter++;
        hasGoneDownRightBicepCurl = false;
        print(
            'User has completed a right bicep curl. Right Bicep Curls: $rightBicepCurlCounter');
      }
    }
  }

// Handle left bicep curls
  void handleLeftBicepCurl(double elbowAngle, double shoulderAngle) {
    if (isAtBottomPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (!hasGoneDownLeftBicepCurl) {
        hasGoneDownLeftBicepCurl = true;
        print('User has gone to the bottom position for left bicep curls.');
      }
    } else if (isAtTopPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (hasGoneDownLeftBicepCurl) {
        leftBicepCurlCounter++;
        hasGoneDownLeftBicepCurl = false;
        print(
            'User has completed a left bicep curl. Left Bicep Curls: $leftBicepCurlCounter');
      }
    }
  }

  void handlePlank(double hipAngle, double shoulderAngle, double kneeAngle) {
    // Check if the pose is within the plank thresholds
    bool isInPlankPosition = hipAngle >= hipPlankMin &&
        hipAngle <= hipPlankMax &&
        shoulderAngle >= shoulderPlankMin &&
        shoulderAngle <= shoulderPlankMax &&
        kneeAngle >= kneePlankMin &&
        kneeAngle <= kneePlankMax;

    if (isInPlankPosition) {
      // Start or continue the timer if the pose is valid
      if (!_isPlankActive) {
        _isPlankActive = true;
        _startPlankTimer();
      }
    } else {
      // Stop the timer if the pose is invalid
      if (_isPlankActive) {
        _isPlankActive = false;
        _stopPlankTimer();
      }
    }
  }

  void _startPlankTimer() {
    // Start a new timer if one isn't already running
    if (_plankTimer == null || !_plankTimer!.isActive) {
      _plankTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        plankCounter++; // Increment the plank counter every second
        print('Plank Timer: $plankCounter seconds');
      });
    }
  }

  void _stopPlankTimer() {
    // Stop and reset the timer
    _plankTimer?.cancel(); // Cancel the timer
    _plankTimer = null; // Clear the timer reference
  }

  bool isAtBottomPositionPushUp(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    return shoulderAngle >= shoulderBottomMin &&
        shoulderAngle <= shoulderBottomMax &&
        elbowAngle >= elbowBottomMin &&
        elbowAngle <= elbowBottomMax &&
        kneeAngle >= kneeBottomMin &&
        kneeAngle <= kneeBottomMax;
  }

  bool isAtTopPositionPushUp(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    return shoulderAngle >= shoulderTopMin &&
        shoulderAngle <= shoulderTopMax &&
        elbowAngle >= elbowTopMin &&
        elbowAngle <= elbowTopMax &&
        kneeAngle >= kneeTopMin &&
        kneeAngle <= kneeTopMax;
  }

  bool isAtBottomPositionSquat(double hipAngle, double kneeAngle) {
    return hipAngle >= hipBottomMin &&
        hipAngle <= hipBottomMax &&
        kneeAngle >= kneeSquatBottomMin &&
        kneeAngle <= kneeSquatBottomMax;
  }

  bool isAtTopPositionSquat(double hipAngle, double kneeAngle) {
    return hipAngle >= hipTopMin &&
        hipAngle <= hipTopMax &&
        kneeAngle >= kneeSquatTopMin &&
        kneeAngle <= kneeSquatTopMax;
  }

  bool isAtBottomPositionCrunch(double hipAngle, double kneeAngle) {
    return kneeAngle >= kneeCrunchBottomMin &&
        kneeAngle <= kneeCrunchBottomMax &&
        hipAngle >= hipCrunchBottomMin &&
        hipAngle <= hipCrunchBottomMax;
  }

  bool isAtTopPositionCrunch(double hipAngle, double kneeAngle) {
    return kneeAngle >= kneeCrunchTopMin &&
        kneeAngle <= kneeCrunchTopMax &&
        hipAngle >= hipCrunchTopMin &&
        hipAngle <= hipCrunchTopMax;
  }

  bool isAtBottomPositionBicepCurl(double elbowAngle, double shoulderAngle) {
    return elbowAngle >= elbowBicepCurlBottomMin &&
        elbowAngle <= elbowBicepCurlBottomMax &&
        shoulderAngle >= shoulderBicepCurlMin &&
        shoulderAngle <= shoulderBicepCurlMax;
  }

  bool isAtTopPositionBicepCurl(double elbowAngle, double shoulderAngle) {
    return elbowAngle >= elbowBicepCurlTopMin &&
        elbowAngle <= elbowBicepCurlTopMax &&
        shoulderAngle >= shoulderBicepCurlMin &&
        shoulderAngle <= shoulderBicepCurlMax;
  }

  bool isInPlankPosition(
      double hipAngle, double shoulderAngle, double kneeAngle) {
    return hipAngle >= hipPlankMin &&
        hipAngle <= hipPlankMax &&
        shoulderAngle >= shoulderPlankMin &&
        shoulderAngle <= shoulderPlankMax &&
        kneeAngle >= kneePlankMin &&
        kneeAngle <= kneePlankMax;
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

  void drawText(Canvas canvas, double x, double y, String text) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';
import 'joint_deg.dart';

enum NowPoses { pushup, standing, overheadDeepSquat, standingForwardBend }

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  static NowPoses nowPose = NowPoses.standing;

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
      final JointDeg jointDeg =
          JointDeg(pose, cameraHeight: 1.6); // Assuming camera height is 1.6m

      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
                1.6, // cameraHeight
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
                1.6, // cameraHeight
              ),
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
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

      bool isPoseCorrect(Pose pose) {
        final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
        final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
        final knee = pose.landmarks[PoseLandmarkType.rightKnee];

        // Example: Right shoulder should be at a specific height compared to elbow
        if (shoulder != null && elbow != null) {
          // Add logic based on the distance between these joints or angles
          return shoulder.y >
              elbow.y; // This is just an example; modify as needed
        }

        // Check other landmarks for additional checks
        if (knee != null) {
          return knee.y > 0.5; // Just as an example, modify as necessary
        }

        return false; // Default to false if landmarks are missing or conditions not met
      }

      void paintPoseFeedback(Canvas canvas, Pose pose) {
        final Paint feedbackPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = isPoseCorrect(pose) ? Colors.green : Colors.red;

        final posePosition = pose.landmarks[PoseLandmarkType.rightShoulder];
        if (posePosition != null) {
          canvas.drawCircle(
              Offset(
                  translateX(posePosition.x, size, imageSize, rotation,
                      cameraLensDirection, 1.6),
                  translateY(posePosition.y, size, imageSize, rotation,
                      cameraLensDirection, 1.6)),
              10,
              feedbackPaint);
        }
      }

      void drawVerticalThresholdLine(Canvas canvas, Size size) {
        final thresholdX = size.width *
            0.5; // Set this based on where you want the vertical line
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.red;
          print("Drawing Vertical Threshold Line");

        // Draw the vertical threshold line
        canvas.drawLine(
          Offset(thresholdX, 0),
          Offset(thresholdX, size.height),
          paint,
        );
      }

      void drawHorizontalThresholdLine(Canvas canvas, Size size) {
        final thresholdY =
            size.height * 0.7; // Adjust this value for squat threshold
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.blue;
          print("Drawing horizontal Threshold Line");

        // Draw the horizontal threshold line
        canvas.drawLine(
          Offset(0, thresholdY),
          Offset(size.width, thresholdY),
          paint,
        );
      }

      bool isCrossedThresholdVertical = false;

      void checkPushUpCrossing(Pose pose, Size size) {
        final thresholdX = size.width * 0.5; // Vertical line position

        final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

        if (shoulder != null) {
          bool isCurrentlyCrossed =
              shoulder.x > thresholdX; // Check if the shoulder crosses the line

          if (isCurrentlyCrossed && !isCrossedThresholdVertical) {
            isCrossedThresholdVertical = true;
            // Push-up completed, increment counter
            print("Push-up completed!");
          } else if (!isCurrentlyCrossed && isCrossedThresholdVertical) {
            isCrossedThresholdVertical = false;
          }
        }
      }

      bool isCrossedThresholdHorizontal = false;

      void checkSquatCrossing(Pose pose, Size size) {
        final thresholdY = size.height * 0.7; // Horizontal line position

        final hip = pose.landmarks[PoseLandmarkType.leftHip];

        if (hip != null) {
          bool isCurrentlyCrossed =
              hip.y > thresholdY; // Check if the hip crosses the line

          if (isCurrentlyCrossed && !isCrossedThresholdHorizontal) {
            isCrossedThresholdHorizontal = true;
            // Squat completed, increment counter
            print("Squat completed!");
          } else if (!isCurrentlyCrossed && isCrossedThresholdHorizontal) {
            isCrossedThresholdHorizontal = false;
          }
        }
      }

      void paintText(PoseLandmarkType type) {
        String? deg;
        switch (type) {
          case PoseLandmarkType.leftHip:
            deg = jointDeg.getLeftHip();
            break;
          case PoseLandmarkType.rightHip:
            deg = jointDeg.getRightHip();
            break;
          case PoseLandmarkType.rightKnee:
            deg = jointDeg.getRightKnee();
            break;
          case PoseLandmarkType.rightHeel:
            deg = jointDeg.getRightHeel();
            break;
          case PoseLandmarkType.rightShoulder:
            deg = jointDeg.getRightShoulder();
            break;
          case PoseLandmarkType.rightEar:
            deg = jointDeg.getRightNeck();
            type = PoseLandmarkType.rightShoulder;
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

      switch (nowPose) {
        case NowPoses.overheadDeepSquat:
          paintText(PoseLandmarkType.rightHip);
          paintText(PoseLandmarkType.rightKnee);
          paintText(PoseLandmarkType.rightHeel);
          paintText(PoseLandmarkType.rightShoulder);
          break;
        case NowPoses.standingForwardBend:
          paintText(PoseLandmarkType.leftHip);
          break;
        case NowPoses.standing:
          paintText(PoseLandmarkType.rightKnee);
          paintText(PoseLandmarkType.rightHip);
          paintText(PoseLandmarkType.rightEar);
          break;
        case NowPoses.pushup:
          paintText(PoseLandmarkType.leftShoulder);
          paintText(PoseLandmarkType.rightShoulder);
          paintText(PoseLandmarkType.leftElbow);
          paintText(PoseLandmarkType.rightElbow);
          paintText(PoseLandmarkType.leftWrist);
          paintText(PoseLandmarkType.rightWrist);
          paintText(PoseLandmarkType.leftHip);
          paintText(PoseLandmarkType.rightHip);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

  void drawText(Canvas canvas, centerX, centerY, text) {
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
    final offset = Offset(xCenter, yCenter);

    textPainter.paint(canvas, offset);
  }
}

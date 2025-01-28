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
                translateX(
                  joint1.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  1.6
                ),
                translateY(
                  joint1.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  1.6
                )),
            Offset(
                translateX(
                  joint2.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  1.6
                ),
                translateY(
                  joint2.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                  1.6
                )),
            paintType);
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
            translateX(
              pose.landmarks[type]!.x,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
              1.6
            ),
            translateY(
              pose.landmarks[type]!.y,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
              1.6
            ),
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

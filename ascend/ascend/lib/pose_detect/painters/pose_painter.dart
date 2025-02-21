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
    this.exerciseName, // Add this parameter
    this.sets, // Add this parameter
    this.reps, // Add this parameter
    this.completedReps, // Pass completed reps from parent widget
    this.completedSets,
    this.onRepCompleted, // Callback for rep completion
    this.onExerciseCompleted,
  );

  final List poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final String exerciseName; // Name of the current exercise
  final int sets; // Total sets for the exercise
  final int reps; // Reps per set
  final VoidCallback onRepCompleted; // Callback to notify parent widget
  final int completedReps; // Completed reps passed from parent
  final VoidCallback onExerciseCompleted; // Callback for navigation
  final int completedSets;

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

  static int currentSet = 0; // Track the current set

  // Method to dynamically determine the current pose
  static NowPoses getPoseFromName(String exerciseName) {
    switch (exerciseName) {
      case 'Push Ups':
        return NowPoses.pushup;
      case 'Squats':
        return NowPoses.squat;
      case 'Crunches':
        return NowPoses.crunch;
      case 'Bicep Curls':
        return NowPoses.bicepCurl;
      case 'Plank':
        return NowPoses.plank;
      default:
        return NowPoses.pushup; // Default to push-ups
    }
  }

  // Reset counters when starting a new exercise
  void resetCounters() {
    pushUpCounter = 0;
    hasGoneDownPushUp = false;

    squatCounter = 0;
    hasGoneDownSquat = false;

    crunchCounter = 0;
    hasGoneDownCrunch = false;

    rightBicepCurlCounter = 0;
    hasGoneDownRightBicepCurl = false;

    leftBicepCurlCounter = 0;
    hasGoneDownLeftBicepCurl = false;

    plankCounter = 0;
    hasStartedPlank = false;

    currentSet = 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    nowPose = getPoseFromName(exerciseName); // Dynamically set the pose

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
        drawText(canvas, 80, 50, 'Push-Ups: $pushUpCounter / $reps');
        drawText(canvas, 80, 70, 'Sets: $currentSet / $sets');
      } else if (nowPose == NowPoses.squat) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Squats: $squatCounter / $reps');
        drawText(canvas, 80, 70, 'Sets: $currentSet / $sets');
      } else if (nowPose == NowPoses.crunch) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Crunches: $crunchCounter / $reps');
        drawText(canvas, 80, 70, 'Sets: $currentSet / $sets');
      } else if (nowPose == NowPoses.bicepCurl) {
        paintText(PoseLandmarkType.rightElbow);
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.leftElbow);
        paintText(PoseLandmarkType.leftShoulder);
        drawText(canvas, 80, 50,
            'Right Bicep Curls: $rightBicepCurlCounter / $reps');
        drawText(
            canvas, 80, 70, 'Left Bicep Curls: $leftBicepCurlCounter / $reps');
        drawText(canvas, 80, 100, 'Sets: $currentSet / $sets');
      } else if (nowPose == NowPoses.plank) {
        paintText(PoseLandmarkType.rightHip);
        paintText(PoseLandmarkType.rightShoulder);
        paintText(PoseLandmarkType.rightKnee);
        drawText(canvas, 80, 50, 'Plank: $plankCounter');
      }

      // Feedback text
      drawText(canvas, 80, 30, 'In Progress...');
    }
  }

  void handlePushUp(double shoulderAngle, double elbowAngle, double kneeAngle) {
    if (isAtBottomPositionPushUp(shoulderAngle, elbowAngle, kneeAngle)) {
      if (!hasGoneDownPushUp) {
        hasGoneDownPushUp = true;
        print('User has gone to the bottom position for push-ups.');
      }
    } else if (isAtTopPositionPushUp(shoulderAngle, elbowAngle, kneeAngle)) {
      if (hasGoneDownPushUp && pushUpCounter < reps) {
        pushUpCounter++;
        hasGoneDownPushUp = false;
        print('User has completed a push-up. Push-Ups: $pushUpCounter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRepCompleted();
        });
        // Check if all reps are completed
        if (pushUpCounter == reps) {
          print('Set $currentSet completed.');
          currentSet++; // Move to the next set
          pushUpCounter = 0; // Reset rep counter for the new set

          // Check if all sets are completed
          if (currentSet == sets) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          }
        }
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
      if (hasGoneDownSquat && squatCounter < reps) {
        squatCounter++;
        hasGoneDownSquat = false;
        print('User has completed a squat. Squats: $squatCounter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRepCompleted();
        });
        // Check if all reps are completed
        if (squatCounter == reps) {
          print('Set $currentSet completed.');
          currentSet++; // Move to the next set
          squatCounter = 0; // Reset rep counter for the new set

          // Check if all sets are completed
          if (currentSet == sets) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          }
        }
      }
    }
  }

  void handleCrunch(double hipAngle, double kneeAngle) {
    if (isAtBottomPositionCrunch(hipAngle, kneeAngle)) {
      if (!hasGoneDownCrunch) {
        hasGoneDownCrunch = true;
        print('User has gone to the bottom position for crunches.');
      }
    } else if (isAtTopPositionCrunch(hipAngle, kneeAngle)) {
      if (hasGoneDownCrunch && crunchCounter < reps) {
        crunchCounter++;
        hasGoneDownCrunch = false;
        print('User has completed a crunch. Crunches: $crunchCounter / $reps');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRepCompleted();
        });

        // Check if all reps for the current set are completed
        if (crunchCounter == reps) {
          print('Set $currentSet completed.');
          currentSet++; // Move to the next set
          crunchCounter = 0; // Reset rep counter for the new set

          // Check if all sets are completed
          if (currentSet == sets) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          }
        }
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
      if (hasGoneDownRightBicepCurl && rightBicepCurlCounter < reps) {
        rightBicepCurlCounter++;
        hasGoneDownRightBicepCurl = false;
        print(
            'User has completed a right bicep curl. Right Bicep Curls: $rightBicepCurlCounter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRepCompleted();
        });
        if (leftBicepCurlCounter == reps && rightBicepCurlCounter == reps) {
          print('Set $currentSet completed.');
          currentSet++; // Move to the next set
          rightBicepCurlCounter = 0; // Reset rep counter for the new set

          // Check if all sets are completed
          if (currentSet == sets) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          }
        }
      }
    }
  }

  void handleLeftBicepCurl(double elbowAngle, double shoulderAngle) {
    if (isAtBottomPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (!hasGoneDownLeftBicepCurl) {
        hasGoneDownLeftBicepCurl = true;
        print('User has gone to the bottom position for left bicep curls.');
      }
    } else if (isAtTopPositionBicepCurl(elbowAngle, shoulderAngle)) {
      if (hasGoneDownLeftBicepCurl && leftBicepCurlCounter < reps) {
        leftBicepCurlCounter++;
        hasGoneDownLeftBicepCurl = false;
        print(
            'User has completed a left bicep curl. Left Bicep Curls: $leftBicepCurlCounter');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRepCompleted();
        });
        if (leftBicepCurlCounter == reps && rightBicepCurlCounter == reps) {
          print('Set $currentSet completed.');
          currentSet++; // Move to the next set
          leftBicepCurlCounter = 0; // Reset rep counter for the new set

          // Check if all sets are completed
          if (currentSet == sets) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          }
        }
      }
    }
  }

  void handlePlank(double hipAngle, double shoulderAngle, double kneeAngle) {
    if (!hasStartedPlank &&
        isAtPlankPosition(hipAngle, shoulderAngle, kneeAngle)) {
      hasStartedPlank = true;
      print('User has started the plank.');
    }
    if (hasStartedPlank) {
      plankCounter++;
      print('Plank time: ${plankCounter ~/ 30} seconds'); // Assuming 30 FPS

      // Check if plank duration matches target reps
      if ((plankCounter ~/ 30) >= reps) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onExerciseCompleted();
        });
      }
    }
  }

  // Helper methods to check positions
  bool isAtBottomPositionPushUp(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    return shoulderAngle >= 0 &&
        shoulderAngle <= 30 &&
        elbowAngle >= 60 &&
        elbowAngle <= 90 &&
        kneeAngle >= 170 &&
        kneeAngle <= 185;
  }

  bool isAtTopPositionPushUp(
      double shoulderAngle, double elbowAngle, double kneeAngle) {
    return shoulderAngle >= 20 &&
        shoulderAngle <= 80 &&
        elbowAngle >= 140 &&
        elbowAngle <= 170 &&
        kneeAngle >= 165 &&
        kneeAngle <= 185;
  }

  bool isAtBottomPositionSquat(double hipAngle, double kneeAngle) {
    return hipAngle >= 70 &&
        hipAngle <= 110 &&
        kneeAngle >= 70 &&
        kneeAngle <= 110;
  }

  bool isAtTopPositionSquat(double hipAngle, double kneeAngle) {
    return hipAngle >= 160 &&
        hipAngle <= 180 &&
        kneeAngle >= 160 &&
        kneeAngle <= 180;
  }

  bool isAtBottomPositionCrunch(double hipAngle, double kneeAngle) {
    return hipAngle >= 140 &&
        hipAngle <= 170 &&
        kneeAngle >= 60 &&
        kneeAngle <= 90;
  }

  bool isAtTopPositionCrunch(double hipAngle, double kneeAngle) {
    return hipAngle >= 50 &&
        hipAngle <= 80 &&
        kneeAngle >= 60 &&
        kneeAngle <= 90;
  }

  bool isAtBottomPositionBicepCurl(double elbowAngle, double shoulderAngle) {
    return elbowAngle >= 10 &&
        elbowAngle <= 20 &&
        shoulderAngle >= 0 &&
        shoulderAngle <= 30;
  }

  bool isAtTopPositionBicepCurl(double elbowAngle, double shoulderAngle) {
    return elbowAngle >= 140 &&
        elbowAngle <= 170 &&
        shoulderAngle >= 0 &&
        shoulderAngle <= 30;
  }

  bool isAtPlankPosition(
      double hipAngle, double shoulderAngle, double kneeAngle) {
    return hipAngle >= 150 &&
        hipAngle <= 180 &&
        shoulderAngle >= 50 &&
        shoulderAngle <= 90 &&
        kneeAngle >= 150 &&
        kneeAngle <= 180;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
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

import 'dart:math';
import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushUpPage extends StatefulWidget {
  @override
  _PushUpPageState createState() => _PushUpPageState();
}

class _PushUpPageState extends State<PushUpPage> {
  int pushUpCounter = 0;
  bool isGoodForm = true;
  bool isPushingUp = false; // To track if the user is going up
  double lowerThreshold = 90.0; // Angle threshold for the down position
  double upperThreshold = 160.0; // Angle threshold for the up position

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  void updatePushUpCounter(double elbowAngle) {
    setState(() {
      if (elbowAngle < lowerThreshold && !isPushingUp) {
        isPushingUp = true; // The user has reached the lowest point
      } else if (elbowAngle > upperThreshold && isPushingUp) {
        pushUpCounter++; // The user has completed a push-up
        isPushingUp = false; // The user is returning up
      }
    });
  }

  @override
  void dispose() async {
    await _poseDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PosePainter.nowPose = NowPoses.pushup; // Set the current pose to push-up
  }

  // Function to calculate the angle between three points (shoulder, elbow, wrist)
  double calculateAngle(Offset shoulder, Offset elbow, Offset wrist) {
    final shoulderToElbow =
        Offset(elbow.dx - shoulder.dx, elbow.dy - shoulder.dy);
    final elbowToWrist = Offset(wrist.dx - elbow.dx, wrist.dy - elbow.dy);

    final dotProduct = shoulderToElbow.dx * elbowToWrist.dx +
        shoulderToElbow.dy * elbowToWrist.dy;
    final magnitudeShoulderToElbow =
        sqrt(pow(shoulderToElbow.dx, 2) + pow(shoulderToElbow.dy, 2));
    final magnitudeElbowToWrist =
        sqrt(pow(elbowToWrist.dx, 2) + pow(elbowToWrist.dy, 2));

    final cosineTheta =
        dotProduct / (magnitudeShoulderToElbow * magnitudeElbowToWrist);
    return acos(cosineTheta) * (180.0 / pi); // Return angle in degrees
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push-Up Pose Detector'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: PoseDetectorView(onImage: (inputImage) async {
              // Process the inputImage with PoseDetector to extract pose
              final poses = await _poseDetector.processImage(inputImage);

              if (poses.isNotEmpty) {
                // Retrieve the joint positions (shoulder, elbow, wrist) using PoseLandmarkType
                final shoulder =
                    poses[0].landmarks[PoseLandmarkType.leftShoulder];
                final elbow = poses[0].landmarks[PoseLandmarkType.leftElbow];
                final wrist = poses[0].landmarks[PoseLandmarkType.leftWrist];

                // Ensure landmarks are not null before using them
                if (shoulder != null && elbow != null && wrist != null) {
                  // Calculate the elbow angle
                  final angle = calculateAngle(
                    Offset(shoulder.x, shoulder.y),
                    Offset(elbow.x, elbow.y),
                    Offset(wrist.x, wrist.y),
                  );

                  // Update the push-up counter based on the angle
                  updatePushUpCounter(angle);
                } else {
                  // Handle the case where landmarks are missing
                  print('Missing one or more landmarks.');
                }
              }
            })),
            SizedBox(height: 20),
            Text(
              'Push-Up Counter: $pushUpCounter',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              isGoodForm ? 'Good Form' : 'Bad Form',
              style: TextStyle(
                fontSize: 20,
                color: isGoodForm ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CrunchPage extends StatefulWidget {
  @override
  _CrunchPageState createState() => _CrunchPageState();
}

class _CrunchPageState extends State<CrunchPage> {
  int crunchCounter = 0;
  bool isGoodForm = true;
  bool isCrunchingUp = false; // Track if the user is crunching up
  double lowerThreshold = 30.0; // Torso angle threshold for crunch completion
  double upperThreshold = 70.0; // Torso angle threshold to reset

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  void updateCrunchCounter(double torsoAngle) {
    setState(() {
      if (torsoAngle < lowerThreshold && !isCrunchingUp) {
        isCrunchingUp = true; // User is crunching up
      } else if (torsoAngle > upperThreshold && isCrunchingUp) {
        crunchCounter++; // Crunch completed
        isCrunchingUp = false;
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
    PosePainter.nowPose = NowPoses.crunch; // Set current pose to crunch
  }

  // Calculate torso angle (shoulder, hip, knee)
  double calculateAngle(Offset shoulder, Offset hip, Offset knee) {
    final shoulderToHip = Offset(hip.dx - shoulder.dx, hip.dy - shoulder.dy);
    final hipToKnee = Offset(knee.dx - hip.dx, knee.dy - hip.dy);

    final dotProduct = shoulderToHip.dx * hipToKnee.dx + shoulderToHip.dy * hipToKnee.dy;
    final magnitudeShoulderToHip = sqrt(pow(shoulderToHip.dx, 2) + pow(shoulderToHip.dy, 2));
    final magnitudeHipToKnee = sqrt(pow(hipToKnee.dx, 2) + pow(hipToKnee.dy, 2));

    final cosineTheta = dotProduct / (magnitudeShoulderToHip * magnitudeHipToKnee);
    return acos(cosineTheta) * (180.0 / pi); // Return angle in degrees
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crunch Pose Detector'),
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
              final poses = await _poseDetector.processImage(inputImage);

              if (poses.isNotEmpty) {
                final shoulder = poses[0].landmarks[PoseLandmarkType.leftShoulder];
                final hip = poses[0].landmarks[PoseLandmarkType.leftHip];
                final knee = poses[0].landmarks[PoseLandmarkType.leftKnee];

                if (shoulder != null && hip != null && knee != null) {
                  final angle = calculateAngle(
                    Offset(shoulder.x, shoulder.y),
                    Offset(hip.x, hip.y),
                    Offset(knee.x, knee.y),
                  );
                  updateCrunchCounter(angle);
                } else {
                  print('Missing one or more landmarks.');
                }
              }
            })),
            SizedBox(height: 20),
            Text(
              'Crunch Counter: $crunchCounter',
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
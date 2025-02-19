import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushUpPage extends StatefulWidget {
  @override
  _PushUpPageState createState() => _PushUpPageState();
}

class _PushUpPageState extends State<PushUpPage> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

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
            Expanded(
              child: PoseDetectorView(
                onImage: (InputImage inputImage, InputImageRotation rotation) async {
                  if (inputImage == null) {
                    print("Input image is null. Skipping pose detection.");
                    return;
                  }
                  try {
                    final poses = await _poseDetector.processImage(inputImage);
                    if (poses.isNotEmpty) {
                      // No need to calculate angles here; PosePainter handles it
                    }
                  } catch (e) {
                    print("Error processing image: $e");
                  }
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
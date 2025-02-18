import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SquatPage extends StatefulWidget {
  @override
  _SquatPageState createState() => _SquatPageState();
}

class _SquatPageState extends State<SquatPage> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());

  @override
  void dispose() async {
    await _poseDetector.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PosePainter.nowPose = NowPoses.squat; // Set the current pose to squat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Squat Pose Detector'),
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
                onImage: (inputImage) async {
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
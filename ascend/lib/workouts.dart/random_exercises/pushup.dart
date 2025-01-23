import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';

class PushUpPage extends StatefulWidget {
  @override
  _PushUpPageState createState() => _PushUpPageState();
}

class _PushUpPageState extends State<PushUpPage> {
  int pushUpCounter = 0;
  bool isGoodForm = true;

  void updatePushUpCounter(bool isGood) {
    setState(() {
      if (isGood) {
        pushUpCounter++;
      } else {
        pushUpCounter = 0;
      }
      isGoodForm = isGood;
    });
  }

  @override
  void initState() {
    super.initState();
    // Set the initial pose for push-ups when this page loads
    PosePainter.nowPose = NowPoses.pushup;
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
            Expanded(child: PoseDetectorView()),  // Ensures PoseDetectorView takes up available space
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

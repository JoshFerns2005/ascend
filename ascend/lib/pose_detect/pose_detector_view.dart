import 'package:ascend/exercise/exercise.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'detector_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  final Function(InputImage inputImage)? onImage; // Add this line

  const PoseDetectorView({super.key, this.onImage}); // Add this parameter

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}


class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  // Create instances of the exercise classes
  final PushUpExercise pushUpExercise = PushUpExercise();
  final SquatExercise squatExercise = SquatExercise();

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage, InputImageRotation rotation) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    // Process the image using the pose detector
    final poses = await _poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      // Create a painter with updated rotation
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        rotation, // Use the rotation passed here
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

      // Process the pose data for specific exercises
      for (Pose pose in poses) {
        // Check if the pose belongs to a specific exercise (e.g., push-up or squat)
        // Example: Check for push-up rep
        if (pushUpExercise.checkRep(pose)) {
          setState(() {
            _text = 'Push-Ups: ${pushUpExercise.repCount}';
          });
        }
        // Example: Check for squat rep
        else if (squatExercise.checkRep(pose)) {
          setState(() {
            _text = 'Squats: ${squatExercise.repCount}';
          });
        }
      }
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
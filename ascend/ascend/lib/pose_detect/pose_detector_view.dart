import 'package:ascend/exercise/exercise.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  final Function(InputImage inputImage, InputImageRotation rotation)? onImage;

  const PoseDetectorView({super.key, this.onImage});

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
  void dispose() {
    _canProcess = false; // Prevent further processing
    _poseDetector.close(); // Close the pose detector
    super.dispose(); // Always call super.dispose()
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
    if (!_canProcess || !mounted) return; // Ensure the widget is still mounted and can process
    if (_isBusy) return; // Prevent overlapping processing
    _isBusy = true;

    try {
      setState(() {
        _text = ''; // Clear previous text
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
          if (pushUpExercise.checkRep(pose)) {
            if (mounted) {
              setState(() {
                _text = 'Push-Ups: ${pushUpExercise.repCount}';
              });
            }
          } else if (squatExercise.checkRep(pose)) {
            if (mounted) {
              setState(() {
                _text = 'Squats: ${squatExercise.repCount}';
              });
            }
          }
        }
      } else {
        _text = 'Poses found: ${poses.length}\n\n';
        _customPaint = null; // No custom paint if no valid metadata
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        setState(() {
          _text = 'Error processing image';
        });
      }
    } finally {
      _isBusy = false; // Reset busy flag
    }
  }
}
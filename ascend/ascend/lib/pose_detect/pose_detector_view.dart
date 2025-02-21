import 'package:ascend/exercise/exercise.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  final Function(InputImage inputImage, InputImageRotation rotation)? onImage;
  final String exerciseName; // Name of the current exercise
  final int sets; // Total sets for the exercise
  final int reps; // Reps per set
  final VoidCallback onExerciseCompleted; // Callback for navigation

  const PoseDetectorView({
    super.key,
    this.onImage,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.onExerciseCompleted,
  });

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

  int completedReps = 0; // Counter for completed reps
  int completedSets = 0;
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
      onImage: (inputImage, rotation) => _processImage(inputImage, rotation),
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage, InputImageRotation rotation) async {
    if (!_canProcess || !mounted) return;
    if (_isBusy) return;
    _isBusy = true;

    try {
      setState(() {
        _text = ''; // Clear previous text
      });

      final poses = await _poseDetector.processImage(inputImage);
      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          rotation,
          _cameraLensDirection,
          widget.exerciseName, // Pass the exercise name
          widget.sets,         // Pass the total sets
          widget.reps,         // Pass the reps per set
          completedReps,
          completedSets,       // Pass the completed reps counter
          () {
            // Callback for rep completion
            setState(() {
              completedReps++;
              _text = '${widget.exerciseName}: $completedReps / ${widget.reps}';
            });

            // Check if all reps are completed
            if (completedSets == widget.sets) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onExerciseCompleted(); // Navigate back to DailyWorkoutPage
              });
            }
          },
          () {
            // Callback for exercise completion
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onExerciseCompleted(); // Navigate back to DailyWorkoutPage
            });
          },
        );

        _customPaint = CustomPaint(painter: painter);
      } else {
        _text = 'Poses found: ${poses.length}\n\n';
        _customPaint = null;
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        setState(() {
          _text = 'Error processing image';
        });
      }
    } finally {
      _isBusy = false;
    }
  }
}
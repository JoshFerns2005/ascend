import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';

class PlankPage extends StatelessWidget {
  final String exerciseName = "plank"; // Name of the exercise
  final int sets = 3; // Total sets for the exercise
  final int reps = 1; // Reps per set (for plank, this can represent duration)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plank Pose Detector'),
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
                exerciseName: exerciseName, // Pass the exercise name
                sets: sets, // Pass the total sets
                reps: reps,
                onExerciseCompleted: () {
                  Navigator.pop(context);
                }, // Pass the reps/duration
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

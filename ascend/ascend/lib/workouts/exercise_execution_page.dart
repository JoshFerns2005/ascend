import 'package:ascend/pose_detect/camera_view.dart';
import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ExerciseExecutionPage extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final List<Map<String, dynamic>> remainingExercises;

  const ExerciseExecutionPage({
    required this.exercise,
    required this.remainingExercises,
  });

  @override
  _ExerciseExecutionPageState createState() => _ExerciseExecutionPageState();
}

class _ExerciseExecutionPageState extends State<ExerciseExecutionPage> {
  int currentSet = 1;
  int currentRep = 0;

  void incrementRep() {
    setState(() {
      if (currentRep < widget.exercise['reps']) {
        currentRep++;
      } else {
        startCooldown();
      }
    });
  }

  void startCooldown() {
    Future.delayed(Duration(seconds: 30), () {
      setState(() {
        if (currentSet < widget.exercise['sets']) {
          currentSet++;
          currentRep = 0; // Reset reps for the next set
        } else {
          // Move to the next exercise or finish workout
          if (widget.remainingExercises.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseExecutionPage(
                  exercise: widget.remainingExercises[0],
                  remainingExercises: widget.remainingExercises.sublist(1),
                ),
              ),
            );
          } else {
            Navigator.pop(context); // End workout
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      appBar: AppBar(
        title: Text(widget.exercise['name']),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraView(
              customPaint: CustomPaint(
                painter: PosePainter(
                  [], // Replace with actual pose data
                  Size(640, 480), // Replace with actual image size
                  InputImageRotation.rotation0deg, // Rotation value
                  CameraLensDirection.back, // Camera lens direction
                ),
              ),
              onImage: (inputImage, rotation) {
                // Handle pose detection here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'Set $currentSet / ${widget.exercise['sets']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Rep $currentRep / ${widget.exercise['reps']}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: incrementRep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 1, 28, 51),
                  ),
                  child: Text('Complete Rep'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

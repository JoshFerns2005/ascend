import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ExerciseTracker {
  final double lowerThreshold;
  final double upperThreshold;
  bool isInProgress = false; // To track if the user is performing the exercise
  int exerciseCounter = 0; // To track the number of completed exercises
  bool isGoodForm = true; // To track if the form is correct

  ExerciseTracker({
    required this.lowerThreshold,
    required this.upperThreshold,
  });

  // Function to calculate angle between three points (shoulder, elbow, wrist)
  double calculateAngle(Offset shoulder, Offset elbow, Offset wrist) {
    final shoulderToElbow = Offset(elbow.dx - shoulder.dx, elbow.dy - shoulder.dy);
    final elbowToWrist = Offset(wrist.dx - elbow.dx, wrist.dy - elbow.dy);

    final dotProduct = shoulderToElbow.dx * elbowToWrist.dx + shoulderToElbow.dy * elbowToWrist.dy;
    final magnitudeShoulderToElbow = sqrt(pow(shoulderToElbow.dx, 2) + pow(shoulderToElbow.dy, 2));
    final magnitudeElbowToWrist = sqrt(pow(elbowToWrist.dx, 2) + pow(elbowToWrist.dy, 2));

    final cosineTheta = dotProduct / (magnitudeShoulderToElbow * magnitudeElbowToWrist);
    return acos(cosineTheta) * (180.0 / pi); // Return angle in degrees
  }

  // Function to update exercise counter and form status based on angle
  void updateCounter(double elbowAngle) {
    if (elbowAngle < lowerThreshold && !isInProgress) {
      isInProgress = true; // User has reached the lowest point
    } else if (elbowAngle > upperThreshold && isInProgress) {
      exerciseCounter++; // Exercise completed
      isInProgress = false; // User is returning up
    }
  }

  void updateFormStatus(double elbowAngle) {
    // Update the form status based on the angle, and check if it's within valid range
    isGoodForm = elbowAngle >= lowerThreshold && elbowAngle <= upperThreshold;
  }
}

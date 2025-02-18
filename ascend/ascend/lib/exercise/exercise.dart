// exercise.dart
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushUpExercise {
  int repCount = 0;
  bool isInPushUpPosition(Pose pose) {
    // Define the logic for when the user is in the push-up position
    // For example, check if the chest is near the ground, and if the arms are straight when up
    final chestY = pose.landmarks[PoseLandmarkType.leftShoulder]?.y ?? 0.0;
    final handsY = pose.landmarks[PoseLandmarkType.leftWrist]?.y ?? 0.0;
    return chestY < handsY;
  }

  bool checkRep(Pose pose) {
    if (isInPushUpPosition(pose)) {
      repCount++;
      return true;
    }
    return false;
  }
}

class SquatExercise {
  int repCount = 0;
  bool isInSquatPosition(Pose pose) {
    // Define squat position check logic
    final hipY = pose.landmarks[PoseLandmarkType.leftHip]?.y ?? 0.0;
    final kneeY = pose.landmarks[PoseLandmarkType.leftKnee]?.y ?? 0.0;
    return kneeY < hipY; // Check if knees are lower than hips (i.e., squatting)
  }

  bool checkRep(Pose pose) {
    if (isInSquatPosition(pose)) {
      repCount++;
      return true;
    }
    return false;
  }
}

import 'package:ascend/pose_detect/painters/joint_deg.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
class ExerciseLogic {
  // Define thresholds for different exercises
  static const double pushupShoulderAngleThreshold = 160.0;
  static const double pushupElbowAngleThreshold = 160.0;
  static const double pushupHipAngleThreshold = 160.0;

  static const double squatKneeAngleThreshold = 90.0;
  static const double lungeKneeAngleThreshold = 90.0;

  static bool checkPushupCorrectness(Pose pose) {
    JointDeg jointDeg = JointDeg(pose);

    double leftShoulderAngle = double.parse(jointDeg.getLeftShoulder() ?? '0');
    double rightShoulderAngle = double.parse(jointDeg.getRightShoulder() ?? '0');
    double leftElbowAngle = double.parse(jointDeg.getLeftElbow() ?? '0');
    double rightElbowAngle = double.parse(jointDeg.getRightElbow() ?? '0');
    double leftHipAngle = double.parse(jointDeg.getLeftHip() ?? '0');
    double rightHipAngle = double.parse(jointDeg.getRightHip() ?? '0');

    return leftShoulderAngle <= pushupShoulderAngleThreshold &&
           rightShoulderAngle <= pushupShoulderAngleThreshold &&
           leftElbowAngle <= pushupElbowAngleThreshold &&
           rightElbowAngle <= pushupElbowAngleThreshold &&
           leftHipAngle <= pushupHipAngleThreshold &&
           rightHipAngle <= pushupHipAngleThreshold;
  }

static bool checkSquatCorrectness(Pose pose) {
    JointDeg jointDeg = JointDeg(pose);

    double leftKneeAngle = double.parse(jointDeg.getLeftKnee() ?? '0');
    double rightKneeAngle = double.parse(jointDeg.getRightKnee() ?? '0');

    return leftKneeAngle >= squatKneeAngleThreshold &&
           rightKneeAngle >= squatKneeAngleThreshold;
  }

  static bool checkLungeCorrectness(Pose pose) {
    JointDeg jointDeg = JointDeg(pose);

    double leftKneeAngle = double.parse(jointDeg.getLeftKnee() ?? '0');
    double rightKneeAngle = double.parse(jointDeg.getRightKnee() ?? '0');

    return leftKneeAngle >= lungeKneeAngleThreshold &&
           rightKneeAngle >= lungeKneeAngleThreshold;
  }
}

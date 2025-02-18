import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class JointDeg {
  final Pose pose;
  final double cameraHeight; // Add camera height to adjust angles

  JointDeg(this.pose, {this.cameraHeight = 1.6});

  String? getLeftHip() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.leftKnee],
        pose.landmarks[PoseLandmarkType.leftHip],
        pose.landmarks[PoseLandmarkType.leftShoulder]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightHip() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightKnee],
        pose.landmarks[PoseLandmarkType.rightHip],
        pose.landmarks[PoseLandmarkType.rightShoulder]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightKnee() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightAnkle],
        pose.landmarks[PoseLandmarkType.rightKnee],
        pose.landmarks[PoseLandmarkType.rightHip]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightHeel() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightKnee],
        pose.landmarks[PoseLandmarkType.rightHeel],
        pose.landmarks[PoseLandmarkType.rightFootIndex]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightShoulder() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightHip],
        pose.landmarks[PoseLandmarkType.rightShoulder],
        pose.landmarks[PoseLandmarkType.rightElbow]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightNeck() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightHip],
        pose.landmarks[PoseLandmarkType.rightShoulder],
        pose.landmarks[PoseLandmarkType.rightEar]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getLeftShoulder() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.leftHip],
        pose.landmarks[PoseLandmarkType.leftShoulder],
        pose.landmarks[PoseLandmarkType.leftElbow]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getLeftElbow() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.leftShoulder],
        pose.landmarks[PoseLandmarkType.leftElbow],
        pose.landmarks[PoseLandmarkType.leftWrist]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getRightElbow() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.rightShoulder],
        pose.landmarks[PoseLandmarkType.rightElbow],
        pose.landmarks[PoseLandmarkType.rightWrist]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getLeftKnee() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.leftAnkle],
        pose.landmarks[PoseLandmarkType.leftKnee],
        pose.landmarks[PoseLandmarkType.leftHip]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  String? getLeftHeel() {
    double? deg = findAngle(
        pose.landmarks[PoseLandmarkType.leftKnee],
        pose.landmarks[PoseLandmarkType.leftHeel],
        pose.landmarks[PoseLandmarkType.leftFootIndex]);
    return (deg == null) ? null : deg.toStringAsFixed(1);
  }

  // Function to find the angle between three landmarks
  double? findAngle(PoseLandmark? A, PoseLandmark? B, PoseLandmark? C) {
    if (A == null || B == null || C == null) {
      return null;
    }

    // Adjust for camera position before calculating the angle
    double adjustedAX = translateX(A.x, cameraHeight);
    double adjustedAY = translateY(A.y, cameraHeight);
    double adjustedBX = translateX(B.x, cameraHeight);
    double adjustedBY = translateY(B.y, cameraHeight);
    double adjustedCX = translateX(C.x, cameraHeight);
    double adjustedCY = translateY(C.y, cameraHeight);

    // Vector AB and BC calculations
    double AB_x = adjustedAX - adjustedBX;
    double AB_y = adjustedAY - adjustedBY;
    double BC_x = adjustedCX - adjustedBX;
    double BC_y = adjustedCY - adjustedBY;

    // Dot product of vectors AB and BC
    double dot = dotProduct(AB_x, AB_y, BC_x, BC_y);

    // Magnitude of vectors AB and BC
    double magnitudeAB = vectorMagnitude(AB_x, AB_y);
    double magnitudeBC = vectorMagnitude(BC_x, BC_y);

    // Calculating angle using dot product formula
    double cosTheta = dot / (magnitudeAB * magnitudeBC);

    // Calculating angle in radians
    double angleRadians = acos(cosTheta);

    // Converting radians to degrees
    double angleDegrees = angleRadians * (180.0 / pi);

    return angleDegrees;
  }

  // Function to calculate dot product
  double dotProduct(double x1, double y1, double x2, double y2) {
    return x1 * x2 + y1 * y2;
  }

  // Function to calculate vector magnitude
  double vectorMagnitude(double x, double y) {
    return sqrt(x * x + y * y);
  }

// Translate X based on camera height
// Adjusts the X-coordinate based on the camera height
  double translateX(double x, double cameraHeight) {
    // Assuming x is in the range [0, 1] for normalized coordinates
    return x * cameraHeight; // Adjust based on the camera's scaling
  }

// Adjusts the Y-coordinate based on the camera height
  double translateY(double y, double cameraHeight) {
    // Assuming y is in the range [0, 1] for normalized coordinates
    return y * cameraHeight; // Adjust based on the camera's scaling
  }
}

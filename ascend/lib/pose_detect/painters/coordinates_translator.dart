import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
  double cameraHeight // Added camera height parameter
) {
  // Adjust for camera height (floor or raised)
  double adjustmentFactor = 1.0;

  if (cameraHeight < 1.5) { // If camera is closer to the ground, more horizontal adjustments
    adjustmentFactor = 1.2;  // This is a rough factor to adjust based on the camera's height.
  } else if (cameraHeight > 2.0) { // If camera is raised
    adjustmentFactor = 0.8;
  }

  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return (x * canvasSize.width / (Platform.isIOS ? imageSize.width : imageSize.height)) * adjustmentFactor;
    case InputImageRotation.rotation270deg:
      return (canvasSize.width - x * canvasSize.width / (Platform.isIOS ? imageSize.width : imageSize.height)) * adjustmentFactor;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return (x * canvasSize.width / imageSize.width) * adjustmentFactor;
        default:
          return (canvasSize.width - x * canvasSize.width / imageSize.width) * adjustmentFactor;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
  double cameraHeight // Added camera height parameter
) {
  // Adjust for camera height
  double adjustmentFactor = 1.0;

  if (cameraHeight < 1.5) { // If camera is closer to the ground
    adjustmentFactor = 1.2;
  } else if (cameraHeight > 2.0) { // If camera is raised
    adjustmentFactor = 0.8;
  }

  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return (y * canvasSize.height / (Platform.isIOS ? imageSize.height : imageSize.width)) * adjustmentFactor;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return (y * canvasSize.height / imageSize.height) * adjustmentFactor;
  }
}

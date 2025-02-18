import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'camera_view.dart';

enum DetectorViewMode { liveFeed, gallery }

// In DetectorView:
class DetectorView extends StatefulWidget {
  DetectorView({
    Key? key,
    required this.title,
    required this.onImage, // Update this to accept both InputImage and InputImageRotation
    this.customPaint,
    this.text,
    this.initialDetectionMode = DetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode initialDetectionMode;
  final Function(InputImage inputImage, InputImageRotation rotation) onImage; // Updated here
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  late DetectorViewMode _mode;

  // Variable to track the current camera lens direction
  late CameraLensDirection _cameraLensDirection;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialDetectionMode;
    _cameraLensDirection = widget.initialCameraLensDirection;
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: widget.customPaint,
      onImage: widget.onImage, // This now accepts both InputImage and InputImageRotation
      onCameraFeedReady: widget.onCameraFeedReady,
      onDetectorViewModeChanged: _onDetectorViewModeChanged,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: _onCameraLensDirectionChanged,
    );
  }

  void _onDetectorViewModeChanged() {
    if (_mode == DetectorViewMode.liveFeed) {
      _mode = DetectorViewMode.gallery;
    } else {
      _mode = DetectorViewMode.liveFeed;
    }
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    setState(() {});
  }

  void _onCameraLensDirectionChanged(CameraLensDirection direction) {
    setState(() {
      _cameraLensDirection = direction;
    });

    if (widget.onCameraLensDirectionChanged != null) {
      widget.onCameraLensDirectionChanged!(direction);
    }
  }
}

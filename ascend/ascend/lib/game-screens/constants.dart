import 'package:flutter/material.dart';

class Constants {
  // Dynamically fetch screen width
  static double get screenWidth {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
  }

  // Dynamically fetch screen height
  static double get screenHeight {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
  }
}
import 'package:flutter/material.dart';

class Constants {
  static double get screenWidth {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
  }

  static double get screenHeight {
    return MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
  }
}
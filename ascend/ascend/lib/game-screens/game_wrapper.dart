import 'package:ascend/game-screens/GameScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome

class GameScreenWrapper extends StatefulWidget {
  final String selectedGender;

  GameScreenWrapper({required this.selectedGender});

  @override
  _GameScreenWrapperState createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends State<GameScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Switch to landscape mode when entering the game screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Revert to portrait mode when leaving the game screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(selectedGender: widget.selectedGender);
  }
}
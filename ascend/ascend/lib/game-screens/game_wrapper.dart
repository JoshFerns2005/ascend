import 'package:ascend/game-screens/GameScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome

class GameScreenWrapper extends StatefulWidget {
  final String selectedCharacter;
  final String selectedGender;
  GameScreenWrapper({required this.selectedCharacter, required this.selectedGender});

  @override
  _GameScreenWrapperState createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends State<GameScreenWrapper> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(selectedCharacter: widget.selectedCharacter, selectedGender: widget.selectedGender);
  }
}
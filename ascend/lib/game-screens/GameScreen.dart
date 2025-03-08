import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'lobby_world.dart'; // Import your LobbyWorld class

class GameScreen extends StatelessWidget {
  final String selectedCharacter; // Add this field
  final String selectedGender;
  const GameScreen({required this.selectedCharacter, required this.selectedGender}); // Constructor accepts selected gender

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: LobbyWorld(selectedCharacter: selectedCharacter, selectedGender: selectedGender), // Pass the selected gender to LobbyWorld
      ),
    );
  }
}
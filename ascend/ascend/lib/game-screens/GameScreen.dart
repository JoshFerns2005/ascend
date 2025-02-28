import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'lobby_world.dart'; // Import your LobbyWorld class

class GameScreen extends StatelessWidget {
  final String selectedGender; // Add this field
  const GameScreen({required this.selectedGender}); // Constructor accepts selected gender

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: LobbyWorld(selectedGender: selectedGender), // Pass the selected gender to LobbyWorld
      ),
    );
  }
}
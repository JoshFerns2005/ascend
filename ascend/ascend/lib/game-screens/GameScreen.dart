import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'lobby_world.dart'; // Import your LobbyWorld class

class GameScreen extends StatefulWidget {
  final String selectedCharacter;
  final String selectedGender;

  const GameScreen({
    required this.selectedCharacter,
    required this.selectedGender,
    Key? key,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LobbyWorld game;

  @override
  void initState() {
    super.initState();
    game = LobbyWorld(
      selectedCharacter: widget.selectedCharacter,
      selectedGender: widget.selectedGender,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        overlayBuilderMap: {
          'loading': (context, _) => const Center(
                child: CircularProgressIndicator(),
              ),
        },
      ),
    );
  }
}

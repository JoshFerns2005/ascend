import 'package:ascend/game-screens/GameScreen.dart';
import 'package:ascend/game-screens/game_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lobby_world.dart'; // Import your LobbyWorld game
import 'character_selection.dart'; // Import the new screen

class GameNavigator {
  static Future<void> navigateToGame(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('No user is currently logged in.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to start the game.')),
      );
      return;
    }

    final userId = user.id;

    try {
      // Check if the user has already selected a character
      final response = await supabase
          .from('user_character')
          .select('gender')
          .eq('user_id', userId);

      if (response.isEmpty) {
        // User has not selected a character yet
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterSelectionScreen(
              onGenderSelected: (gender) async {
                try {
                  // Save the selected gender to the database
                  await supabase.from('user_character').insert({
                    'user_id': userId,
                    'gender': gender,
                  });

                  // Navigate to the game after selecting a character
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(selectedGender: gender),
                    ),
                  );
                } catch (e) {
                  print('Error saving character selection: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to save character selection. Please try again.')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // User has already selected a character, go directly to the game
        final selectedGender = response.first['gender'] as String? ?? 'male';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreenWrapper(selectedGender: 'male'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching user character data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load character data. Please try again.')),
      );
    }
  }
}

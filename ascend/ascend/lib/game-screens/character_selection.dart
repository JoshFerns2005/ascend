import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final Function(String gender) onGenderSelected;

  const CharacterSelectionScreen({required this.onGenderSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 43, 79), // Customizable screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title Text
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Choose your character',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCharacterOption(
                  context,
                  'assets/images/game_images/male/male_idle.png', // Replace with your male image path
                  () => onGenderSelected('male'),
                ),
                _buildCharacterOption(
                  context,
                  'assets/images/game_images/female/female_idle.png', // Replace with your female image path
                  () => onGenderSelected('female'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterOption(BuildContext context, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8, // Shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Color.fromARGB(255, 30, 60, 90), // Customizable card background color
        child: Container(
          width: 150,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded corners for the image
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain, // Ensures the image fits within the card
            ),
          ),
        ),
      ),
    );
  }
}
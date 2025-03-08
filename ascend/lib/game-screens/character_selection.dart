import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final supabase = Supabase.instance.client;

  // Update the callback to accept both character and gender
  final Function(String character, String gender) onCharacterSelected;

  CharacterSelectionScreen({required this.onCharacterSelected});

  @override
  Widget build(BuildContext context) {
    // List of characters (male and female)
    final List<Map<String, String>> characters = [
      {'name': 'Archer', 'image': 'assets/images/game_images/male/Archer/Archer.png', 'gender': 'male'},
      {'name': 'Swordsman', 'image': 'assets/images/game_images/male/Swordsman/Swordsman.png', 'gender': 'male'},
      {'name': 'Wizard', 'image': 'assets/images/game_images/male/Wizard/Wizard.png', 'gender': 'male'},
      {'name': 'Enchantress', 'image': 'assets/images/game_images/female/Enchantress/Enchantress.png', 'gender': 'female'},
      {'name': 'Knight', 'image': 'assets/images/game_images/female/Knight/Knight.png', 'gender': 'female'},
      {'name': 'Musketeer', 'image': 'assets/images/game_images/female/Musketeer/Musketeer.png', 'gender': 'female'},
    ];

    // Split characters into male and female lists
    final List<Map<String, String>> maleCharacters =
        characters.where((character) => character['gender'] == 'male').toList();
    final List<Map<String, String>> femaleCharacters =
        characters.where((character) => character['gender'] == 'female').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Character'),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
      ),
      body: Container(
        color: Color.fromARGB(200, 0, 43, 79),
        child: Column(
          children: [
            // Title above the grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Choose Your Character',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Male and Female Characters with Divider
            Expanded(
              child: Row(
                children: [
                  // Male Characters Section
                  Expanded(
                    child: _buildCharacterColumn(maleCharacters, context),
                  ),
                  // Vertical Divider
                  Container(
                    width: 2,
                    color: Colors.white,
                  ),
                  // Female Characters Section
                  Expanded(
                    child: _buildCharacterColumn(femaleCharacters, context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a column of character cards
  Widget _buildCharacterColumn(List<Map<String, String>> characters, BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Card(
          color: Color.fromARGB(255, 0, 43, 79),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: InkWell(
            onTap: () async {
              // Pass both character name and gender to the callback
              onCharacterSelected(character['name']!, character['gender']!);

              final user = supabase.auth.currentUser;
              if (user != null) {
                try {
                  await supabase
                      .from('user_character')
                      .update({
                        'character': character['name'],
                        'gender': character['gender'],
                      })
                      .eq('id', user.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${character['name']} selected!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Navigator.pop(context); // Go back to the previous screen
                } catch (e) {
                  print('Error saving character: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to select character')),
                  );
                }
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character image
                  Image.asset(
                    character['image']!,
                    fit: BoxFit.contain,
                    width: 120, // Increased size
                    height: 120, // Increased size
                  ),
                  SizedBox(height: 10),
                  // Character name
                  Text(
                    character['name'] ?? 'Unknown Character',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
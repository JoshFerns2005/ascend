import 'package:ascend/game-screens/GameScreen.dart';
import 'package:ascend/game-screens/game_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CharacterSelectionScreen extends StatefulWidget {
  final Function(String character, String gender) onCharacterSelected;

  CharacterSelectionScreen({required this.onCharacterSelected});

  @override
  _CharacterSelectionScreenState createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameAvailable = true;

  // List of characters (male and female)
  final List<Map<String, String>> characters = [
    {
      'name': 'Archer',
      'image': 'assets/images/game_images/male/Archer/Archer.png',
      'gender': 'male'
    },
    {
      'name': 'Swordsman',
      'image': 'assets/images/game_images/male/Swordsman/Swordsman.png',
      'gender': 'male'
    },
    {
      'name': 'Wizard',
      'image': 'assets/images/game_images/male/Wizard/Wizard.png',
      'gender': 'male'
    },
    {
      'name': 'Enchantress',
      'image': 'assets/images/game_images/female/Enchantress/Enchantress.png',
      'gender': 'female'
    },
    {
      'name': 'Knight',
      'image': 'assets/images/game_images/female/Knight/Knight.png',
      'gender': 'female'
    },
    {
      'name': 'Musketeer',
      'image': 'assets/images/game_images/female/Musketeer/Musketeer.png',
      'gender': 'female'
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // Check if the username is unique
  Future<bool> _checkUsernameAvailability(String username) async {
    final response = await supabase
        .from('user_character')
        .select()
        .eq('username', username)
        .maybeSingle();

    return response == null; // If response is null, username is available
  }

  // Save character, gender, and username to the database
Future<void> _saveCharacterAndUsername(
    String character, String gender, String username) async {
  final user = supabase.auth.currentUser;
  if (user != null) {
    try {
      print('Step 1: Username: $username');
      if (username.isEmpty) {
        throw Exception('Username cannot be empty');
      }

      print('Step 2: Preparing payload');
      final payload = {
        'user_id': user.id,
        'character': character,
        'gender': gender,
        'username': username,
      };
      print('Step 3: Upsert Payload: $payload');

      print('Step 4: Performing upsert');
      final response = await supabase.from('user_character').upsert(
        payload,
      );
      print('Step 5: Supabase Response: $response');

      print('Step 6: Showing success snackbar');
      if (!mounted) return; // Ensure the widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$character selected with username: $username!'),
            duration: Duration(seconds: 2),
          ),
        );
      });

      print('Step 7: Navigating to GameScreenWrapper');
      if (!mounted) return; // Ensure the widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreenWrapper(
              selectedCharacter: character,
              selectedGender: gender,
            ),
          ),
        );
      });
      print('Step 8: Navigation completed');
    } catch (e) {
      print('Error caught: $e');
      if (!mounted) return; // Ensure the widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {

      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Split characters into male and female lists
    final List<Map<String, String>> maleCharacters =
        characters.where((character) => character['gender'] == 'male').toList();
    final List<Map<String, String>> femaleCharacters = characters
        .where((character) => character['gender'] == 'female')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Character'),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
      ),
      body: Container(
        color: Color.fromARGB(200, 0, 43, 79),
        child: Column(
          children: [
            // Username Input Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter Username',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  errorText:
                      _isUsernameAvailable ? null : 'Username already taken',
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) async {
                  final isAvailable = await _checkUsernameAvailability(value);
                  setState(() {
                    _isUsernameAvailable = isAvailable;
                  });
                },
              ),
            ),
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
  Widget _buildCharacterColumn(
      List<Map<String, String>> characters, BuildContext context) {
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
              final username = _usernameController.text.trim();
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a username')),
                );
                return;
              }

              if (!_isUsernameAvailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Username is already taken')),
                );
                return;
              }

              // Pass both character name and gender to the callback
              widget.onCharacterSelected(
                  character['name']!, character['gender']!);

              // Save character, gender, and username to the database
              await _saveCharacterAndUsername(
                character['name']!,
                character['gender']!,
                username,
              );
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

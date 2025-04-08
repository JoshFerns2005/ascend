import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Leaderboard extends StatelessWidget {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    final userCharactersResponse =
        await _supabase.from('user_character').select();
    final userCharacters = userCharactersResponse as List<dynamic>;

    final statisticsResponse = await _supabase.from('statistics').select();
    final statistics = statisticsResponse as List<dynamic>;

    final Map<String, int> cumulativeStats = {};

    for (final stat in statistics) {
      final userId = stat['user_id'] as String;
      final strength = stat['strength'] as int;
      final stamina = stat['stamina'] as int;
      final jumpStrength = stat['jump_strength'] as int;
      final flexibility = stat['flexibility'] as int;
      final endurance = stat['endurance'] as int;

      final totalStats =
          strength + stamina + jumpStrength + flexibility + endurance;
      cumulativeStats[userId] = (cumulativeStats[userId] ?? 0) + totalStats;
    }

    final List<Map<String, dynamic>> userData = [];
    for (final userCharacter in userCharacters) {
      final userId = userCharacter['user_id'] as String;
      final username = userCharacter['username'] as String;
      final totalStats = cumulativeStats[userId] ?? 0;

      userData.add({
        'username': username,
        'stats': totalStats,
      });
    }

    userData.sort((a, b) => b['stats'].compareTo(a['stats']));

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 0, 19, 33),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () {
            Navigator.of(context).pop(); 
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Players',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 28, 50),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Power',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: userData.length,
                    itemBuilder: (context, index) {
                      final user = userData[index];
                      final username = user['username'];
                      final stats = user['stats'];

                      final isEvenRow = index % 2 == 0;
                      final rowColor = isEvenRow
                          ? Color.fromARGB(255, 0, 28, 50)
                          : Colors.transparent;

                      return Container(
                        color: rowColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$stats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

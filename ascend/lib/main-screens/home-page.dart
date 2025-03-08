import 'package:ascend/game-screens/GameScreen.dart';
import 'package:ascend/game-screens/Navigator.dart';
import 'package:ascend/workouts/dailyworkout.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  final String username;

  HomePage({required this.username});
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? characterName;
  String? gender;
  Map<String, int> stats = {};
  void initState() {
    super.initState();
    _fetchCharacterAndStats();
  }

  Future<void> _fetchCharacterAndStats() async {
    try {
      // Fetch user ID
      final user = supabase.auth.currentUser;
      final userId = user?.id;

      if (userId == null) {
        print('User not logged in.');
        return;
      }
      print('Fetching data for user ID: $userId');

      // Fetch character details
      final characterResponse = await supabase
          .from('user_character')
          .select('character, gender')
          .eq('user_id', userId)
          .single();

      if (characterResponse == null) {
        print('No character data found for user ID: $userId');
        return;
      }

      setState(() {
        characterName = characterResponse['character'];
        gender = characterResponse['gender'];
      });
      print('Character Name: $characterName, Gender: $gender');

      // Fetch statistics
      final statsResponse = await supabase
          .from('statistics')
          .select('strength, stamina, jump_strength, flexibility, endurance')
          .eq('user_id', userId)
          .single();

      if (statsResponse == null) {
        print('No statistics data found for user ID: $userId');
        return;
      }

      setState(() {
        stats = {
          'Strength': statsResponse['strength'] ?? 0,
          'Stamina': statsResponse['stamina'] ?? 0,
          'Jump Strength': statsResponse['jump_strength'] ?? 0,
          'Flexibility': statsResponse['flexibility'] ?? 0,
          'Endurance': statsResponse['endurance'] ?? 0,
        };
      });
      print('Statistics: $stats');
    } catch (e) {
      print('Error fetching character or stats: $e');
    }
  }

  final supabase = Supabase.instance.client;
  final PageController _pageController = PageController();

  // Dummy data for game character and motivational quote
  final String gameCharacter = 'Your Game Character';
  final String motivationalQuote =
      '“Keep going. You’re getting better every day!”';

  // Fetch user schedule from Supabase or a dummy API
  Future<List<Map<String, dynamic>>> fetchUserSchedule(String userId) async {
    try {
      final response = await supabase
          .from('workout_schedule')
          .select('day_of_week, exercises')
          .eq('user_id', userId);

      if (response != null && response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching user schedule: $e');
      return [];
    }
  }

  // Helper function to order the schedule by day
  List<Map<String, dynamic>> _getOrderedSchedule(
      List<Map<String, dynamic>> schedule) {
    final dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return dayOrder.map((day) {
      return schedule.firstWhere(
        (item) => item['day_of_week'] == day,
        orElse: () => {'exercises': []},
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the user session to get userId
    final user = supabase.auth.currentUser;
    final userId = user?.id ?? ''; // Get userId from Supabase session

    // Determine today's day
    final today = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 43, 79),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchUserSchedule(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final schedule = snapshot.data!;
                        final orderedSchedule = _getOrderedSchedule(schedule);

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              // Workout schedule page
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: orderedSchedule.map((item) {
                                    final isToday =
                                        item['day_of_week'] == today;
                                    // Convert exercises to a readable string
                                    String exercisesString = '';
                                    if (item['exercises'] is List) {
                                      exercisesString = (item['exercises']
                                              as List)
                                          .map((exercise) =>
                                              exercise['exercise'] ?? 'Unknown')
                                          .join(', ');
                                    } else {
                                      exercisesString =
                                          'No exercises scheduled';
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text.rich(
                                        TextSpan(
                                          text: '${item['day_of_week']}: ',
                                          style: TextStyle(
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: exercisesString.isEmpty
                                                  ? 'No exercises scheduled'
                                                  : exercisesString,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              // Game character page
                              // Replace the existing "Game character page" section with this:
                              // Game character page
                              Container(
                                color: Color.fromARGB(255, 0, 43, 79),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(0,20.0,20,20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left: Full-Body Game Character Image
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: 400, // Full width for the image
                                          height:
                                              500, // Adjust height as needed
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                'assets/images/game_images/$gender/$characterName/$characterName.png',
                                              ),
                                              fit: BoxFit
                                                  .contain, // Ensure the image covers the container
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Right: Statistics Section
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10,vertical: 30),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Strength: ${stats['Strength']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Stamina: ${stats['Stamina']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Jump Strength: ${stats['Jump Strength']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Flexibility: ${stats['Flexibility']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Endurance: ${stats['Endurance']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ), // Motivational quote page
                              Center(
                                child: Text(
                                  motivationalQuote,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No schedule found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // New Button: "The Game"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  GameNavigator.navigateToGame(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.blue, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionCard(
                        'Start Workout',
                        Icons.play_arrow,
                        Colors.white,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DailyWorkoutPage(),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Set Schedule',
                        Icons.calendar_month,
                        Colors.white,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutSchedulePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Section: Recommendations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildRecommendationCard(
                      'Full Body HIIT', 'Burn 400 kcal in 20 minutes!'),
                  _buildRecommendationCard(
                      'Morning Yoga', 'Improve flexibility and relax.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build individual statistic cards
  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to build quick action cards
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTapAction,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTapAction,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 43, 79),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build recommendation cards
  Widget _buildRecommendationCard(String title, String subtitle) {
    return Card(
      color: Color.fromARGB(255, 0, 43, 79),
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.recommend, color: Colors.white),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () {
          // Add functionality for recommendation click
        },
      ),
    );
  }
}

import 'package:ascend/game-screens/GameScreen.dart';
import 'package:ascend/game-screens/Navigator.dart';
import 'package:ascend/main-screens/AiQuote.dart';
import 'package:ascend/workouts/dailyworkout.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  String _motivationalQuote =
      "Loading motivational quote..."; // Initialize with default value
  final QuoteGenerator _quoteGenerator =  QuoteGenerator(
    geminiApiKey: 'AIzaSyBmScpYT1HKfP1cuGu9l3xEj693OKZ9w04',
  );
  bool _isLoadingQuote = true;

  void initState() {
    super.initState();
    _fetchCharacterAndStats();
    _loadNewQuote();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload quote when app resumes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNewQuote();
    });
  }

  Future<void> _loadNewQuote() async {
    setState(() => _isLoadingQuote = true);
    try {
      final newQuote = await _quoteGenerator.generateExerciseQuote();
      if (mounted) {
        setState(() {
          _motivationalQuote = newQuote;
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      print('Error loading quote: $e');
      if (mounted) {
        setState(() {
          _motivationalQuote = 'Failed to load quote.';
          _isLoadingQuote = false;
        });
      }
    }
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
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height *
                    0.02, // Responsive vertical padding
                horizontal: MediaQuery.of(context).size.width *
                    0.05, // Responsive horizontal padding
              ),
              margin: EdgeInsets.all(MediaQuery.of(context).size.width *
                  0.04), // Responsive margin
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 43, 79),
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width *
                        0.04), // Responsive border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: MediaQuery.of(context).size.width *
                        0.02, // Responsive blur radius
                    offset: Offset(
                        0,
                        MediaQuery.of(context).size.height *
                            0.01), // Responsive shadow offset
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
                              fontSize: MediaQuery.of(context).size.width *
                                  0.05, // Responsive font size
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
                              fontSize: MediaQuery.of(context).size.width *
                                  0.06, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final schedule = snapshot.data!;
                        final orderedSchedule = _getOrderedSchedule(schedule);
                        return Container(
                          height: MediaQuery.of(context).size.height *
                              0.4, // Responsive height
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01), // Responsive vertical padding
                                      child: Text.rich(
                                        TextSpan(
                                          text: '${item['day_of_week']}: ',
                                          style: TextStyle(
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.045, // Responsive font size
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
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04, // Responsive font size
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
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    MediaQuery.of(context).size.height *
                                        0.02, // Responsive top padding
                                    MediaQuery.of(context).size.width *
                                        0.04, // Responsive right padding
                                    MediaQuery.of(context).size.height *
                                        0.02, // Responsive bottom padding
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left: Full-Body Game Character Image
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4, // 40% of screen width
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4 *
                                              1.25, // Maintain aspect ratio
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
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03, // Responsive horizontal padding
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03, // Responsive vertical padding
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Strength: ${stats['Strength']}',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01), // Responsive spacing
                                              Text(
                                                'Stamina: ${stats['Stamina']}',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01), // Responsive spacing
                                              Text(
                                                'Jump Strength: ${stats['Jump Strength']}',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01), // Responsive spacing
                                              Text(
                                                'Flexibility: ${stats['Flexibility']}',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01), // Responsive spacing
                                              Text(
                                                'Endurance: ${stats['Endurance']}',
                                                style: TextStyle(
                                                  fontSize: MediaQuery.of(
                                                              context)
                                                          .size
                                                          .width *
                                                      0.04, // Responsive font size
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
                              // Motivational quote page
                              _isLoadingQuote
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                        child: Text(
                                          _motivationalQuote,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
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
                              fontSize: MediaQuery.of(context).size.width *
                                  0.06, // Responsive font size
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

            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.02, // Responsive spacing
            ),
            // New Button: "The Game"
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width *
                    0.05, // Responsive horizontal padding
              ),
              child: GestureDetector(
                onTap: () {
                  GameNavigator.navigateToGame(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height *
                        0.02, // Responsive vertical padding
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width *
                          0.03, // Responsive border radius
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: MediaQuery.of(context).size.width *
                            0.02, // Responsive blur radius
                        offset: Offset(
                          0,
                          MediaQuery.of(context).size.height *
                              0.01, // Responsive shadow offset
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: Colors.blue,
                        size: MediaQuery.of(context).size.width *
                            0.08, // Responsive icon size
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.02, // Responsive spacing
                      ),
                      Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.02, // Responsive spacing
            ),

            // Quick Actions Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width *
                    0.05, // Responsive horizontal padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width *
                          0.045, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.01, // Responsive spacing
                  ),
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

            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.02, // Responsive spacing
            ),
          ],
        ),
      ),
    );
  }

  // Function to build individual statistic cards
  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height *
            0.005, // Responsive vertical margin
      ),
      padding: EdgeInsets.all(
          MediaQuery.of(context).size.width * 0.02), // Responsive padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          MediaQuery.of(context).size.width * 0.02, // Responsive border radius
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: MediaQuery.of(context).size.width *
                0.01, // Responsive blur radius
            offset: Offset(
              0,
              MediaQuery.of(context).size.height *
                  0.005, // Responsive shadow offset
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: MediaQuery.of(context).size.width *
                0.06, // Responsive icon size
          ),
          SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.02, // Responsive spacing
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.035, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.04, // Responsive font size
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
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width *
                0.01, // Responsive horizontal margin
          ),
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.03), // Responsive padding
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 0, 43, 79),
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width *
                  0.03, // Responsive border radius
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: MediaQuery.of(context).size.width *
                    0.08, // Responsive icon size
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.01, // Responsive spacing
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.035, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

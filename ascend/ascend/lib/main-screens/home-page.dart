import 'package:ascend/workouts/dailyworkout.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  final String username;

  HomePage({required this.username});

  final supabase = Supabase.instance.client;
  final PageController _pageController = PageController();

  // Dummy data for game character and motivational quote
  final String gameCharacter = 'Your Game Character';
  final String motivationalQuote = '“Keep going. You’re getting better every day!”';

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
  List<Map<String, dynamic>> _getOrderedSchedule(List<Map<String, dynamic>> schedule) {
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
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final schedule = snapshot.data!;
                        final orderedSchedule = _getOrderedSchedule(schedule);

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              // Workout schedule page
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: orderedSchedule.map((item) {
                                  final isToday = item['day_of_week'] == today;

                                  // Convert exercises to a readable string
                                  String exercisesString = '';
                                  if (item['exercises'] is List) {
                                    exercisesString = (item['exercises'] as List)
                                        .map((exercise) => exercise['exercise'] ?? 'Unknown')
                                        .join(', ');
                                  } else {
                                    exercisesString = 'No exercises scheduled';
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text.rich(
                                      TextSpan(
                                        text: '${item['day_of_week']}: ',
                                        style: TextStyle(
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              // Game character page
                              Center(
                                child: Text(
                                  gameCharacter,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Motivational quote page
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
                              builder: (context) => DailyWorkoutPage(
                                dailyExercises: [],
                              ),
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
                  _buildRecommendationCard('Full Body HIIT', 'Burn 400 kcal in 20 minutes!'),
                  _buildRecommendationCard('Morning Yoga', 'Improve flexibility and relax.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build individual statistic cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 120,
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
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.arrow_forward, color: Colors.white),
        onTap: () {
          // Add functionality for recommendation click
        },
      ),
    );
  }
}
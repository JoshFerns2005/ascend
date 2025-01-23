import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

class HomePage extends StatelessWidget {
  final String username; // Declare a final variable for the username
  HomePage({required this.username}); // Constructor to accept username

  final supabase = Supabase.instance.client; // Initialize Supabase client

  // Function to fetch the user schedule using userId
  Future<List<Map<String, dynamic>>> fetchUserSchedule(String userId) async {
    try {
      final response = await supabase
          .from('workout_schedule')
          .select('day_of_week, exercises')
          .eq('user_id', userId); // Use userId to filter results

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

  @override
  Widget build(BuildContext context) {
    // Retrieve the userId from Hive
    final userBox = Hive.box<String>('userBox');
    final userId = userBox.get('userId') ?? '';

    // Define the desired order of days
    final dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Container with rounded corners and shadow
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5), // Shadow position
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchUserSchedule(userId), // Pass userId here
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
                      final today = DateFormat('EEEE').format(DateTime.now());

                      // Map the schedule to the desired day order
                      final orderedSchedule = dayOrder.map((day) {
                        return schedule.firstWhere(
                          (item) => item['day_of_week'] == day,
                          orElse: () => {'exercises': 'No exercises scheduled'},
                        );
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orderedSchedule.map((item) {
                          final isToday = item['day_of_week'] == today;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                    text: item['exercises'],
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
          // Section: User Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Workouts', '0 this week', Icons.fitness_center,
                    Colors.orange),
                _buildStatCard('Calories', '0 kcal',
                    Icons.local_fire_department, Colors.red),
                _buildStatCard('Points', '0 pts', Icons.star, Colors.purple),
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
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionCard(
                        'Start Workout', Icons.play_arrow, Colors.blue),
                    _buildQuickActionCard(
                        'Set Schedule', Icons.calendar_month, Colors.green),
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
                    color: Colors.black87,
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
    );
  }

  // Function to build individual statistic cards
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Function to build quick action cards
  Widget _buildQuickActionCard(String title, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Add functionality for the quick action
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
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

  // Function to build recommendation cards
  Widget _buildRecommendationCard(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.recommend, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward, color: Colors.blue),
        onTap: () {
          // Add functionality for recommendation click
        },
      ),
    );
  }
}

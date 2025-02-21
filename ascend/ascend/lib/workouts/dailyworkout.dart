import 'package:ascend/workouts/random_exercises/bicep_curl.dart';
import 'package:ascend/workouts/random_exercises/crunch.dart';
import 'package:ascend/workouts/random_exercises/plank.dart';
import 'package:ascend/workouts/random_exercises/pushup.dart';
import 'package:ascend/workouts/random_exercises/squat.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyWorkoutPage extends StatelessWidget {
  final List<dynamic> dailyExercises;

  DailyWorkoutPage({required this.dailyExercises});

  final supabase = Supabase.instance.client;

  // Fetch user schedule from Supabase
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

  final Map<String, Widget Function(BuildContext)> exercisePageMap = {
    'Push Ups': (context) => PushUpPage(),
    'Squat': (context) => SquatPage(),
    'Crunches': (context) => CrunchPage(),
    'Bicep Curls': (context) => BicepCurlPage(),
    'Plank': (context) => PlankPage(),
  };

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
    final userId = user?.id ?? '';

    // Determine today's day
    final today = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Workout',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color.fromARGB(
            255, 0, 43, 79), // Set background color for the entire page
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchUserSchedule(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
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

              // Find today's exercises
              final todaysExercises = orderedSchedule.firstWhere(
                    (item) => item['day_of_week'] == today,
                    orElse: () => {'exercises': []},
                  )['exercises'] ??
                  [];

              if (todaysExercises.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No exercises scheduled for today',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (todaysExercises.isNotEmpty) {
                            final firstExercise = todaysExercises.first;
                            final exerciseName =
                                firstExercise['exercise'] ?? 'Unknown Exercise';
                            final sets = firstExercise['sets'] ?? 0;
                            final reps = firstExercise['reps'] ?? 0;

                            // Check if the exercise exists in the mapping
                            final exercisePageBuilder =
                                exercisePageMap[exerciseName];
                            if (exercisePageBuilder != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      exercisePageBuilder(context),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Exercise "$exerciseName" is not implemented yet.'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('No exercises scheduled for today'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 0, 43, 79),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Start Workout',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: todaysExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = todaysExercises[index];
                        return ListTile(
                          title: Text(
                            exercise['exercise'] ?? 'Unknown Exercise',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Sets: ${exercise['sets'] ?? 0}, Reps: ${exercise['reps'] ?? 0}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          tileColor: Color.fromARGB(255, 0, 43, 79),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (todaysExercises.isNotEmpty) {
                          final firstExercise = todaysExercises.first;
                          final exerciseName =
                              firstExercise['exercise'] ?? 'Unknown Exercise';
                          final sets = firstExercise['sets'] ?? 0;
                          final reps = firstExercise['reps'] ?? 0;

                          // Check if the exercise exists in the mapping
                          final exercisePageBuilder =
                              exercisePageMap[exerciseName];
                          if (exercisePageBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    exercisePageBuilder(context),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Exercise "$exerciseName" is not implemented yet.'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No exercises scheduled for today'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Start Workout',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No schedule found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutSchedulePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Set Schedule',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

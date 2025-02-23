import 'package:ascend/main-screens/home-page.dart';
import 'package:ascend/main-screens/home-screen.dart';
import 'package:ascend/workouts/random_exercises/bicep_curl.dart';
import 'package:ascend/workouts/random_exercises/crunch.dart';
import 'package:ascend/workouts/random_exercises/pushup.dart';
import 'package:ascend/workouts/random_exercises/squat.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyWorkoutPage extends StatefulWidget {
  @override
  _DailyWorkoutPageState createState() => _DailyWorkoutPageState();
}

class _DailyWorkoutPageState extends State<DailyWorkoutPage> {
  final supabase = Supabase.instance.client;

  // Map exercises to their respective pages
  final Map<String, WidgetBuilder> exercisePageMap = {
    'Push Ups': (context) => PushUpPage(),
    'Squats': (context) => SquatPage(),
    'Crunches': (context) => CrunchPage(),
    'Bicep Curls': (context) => BicepCurlPage(),
  };

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
        color: Color.fromARGB(255, 0, 43, 79),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRemainingExercises(userId, today),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading schedule',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final remainingExercises = snapshot.data!;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: remainingExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = remainingExercises[index];
                        return ListTile(
                          title: Text(
                            exercise['exercise'] ?? 'Unknown Exercise',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Sets: ${exercise['sets'] ?? 0}, Reps: ${exercise['reps'] ?? 0}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16),
                          ),
                          tileColor: Color.fromARGB(255, 0, 43, 79),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (remainingExercises.isNotEmpty) {
                          final firstExercise = remainingExercises.first;
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
                                      exercisePageBuilder(context)),
                            ).then((_) async {
                              // Mark exercise as completed after returning from the exercise page
                              await markExerciseAsCompleted(
                                  userId, today, exerciseName);

                              // Trigger a rebuild to fetch updated data
                              setState(() {});
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Exercise "$exerciseName" is not implemented yet.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('No exercises scheduled for today')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                      'All exercises completed for today!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                  username:
                                      user.userMetadata?['username'] ?? 'Guest'),
                            ),
                          );
                        } else {
                          // Handle case where user is not logged in
                          print('No user is currently logged in.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Go to Home',
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

// Function to mark an exercise as completed
Future<void> markExerciseAsCompleted(
    String userId, String dayOfWeek, String exerciseName) async {
  try {
    // Fetch the current completed_exercises for the user on the specific day
    final response = await Supabase.instance.client
        .from('workout_schedule')
        .select('completed_exercises')
        .eq('user_id', userId)
        .eq('day_of_week', dayOfWeek) // Add this line to filter by day
        .single();

    Map<String, dynamic> completedExercises =
        Map<String, dynamic>.from(response['completed_exercises'] ?? {});

    // Update the completed exercises for the specific day
    List<dynamic> completedToday =
        List<dynamic>.from(completedExercises[dayOfWeek] ?? []);
    if (!completedToday.contains(exerciseName)) {
      completedToday.add(exerciseName);
    }
    completedExercises[dayOfWeek] = completedToday;

    // Update the database
    await Supabase.instance.client
        .from('workout_schedule')
        .update({'completed_exercises': completedExercises})
        .eq('user_id', userId)
        .eq('day_of_week', dayOfWeek); // Add this line to target the specific day

    print('Successfully marked exercise as completed: $exerciseName');
  } catch (e) {
    print('Error marking exercise as completed: $e');
  }
}

// Function to reset weekly progress
Future<void> resetWeeklyProgress(String userId) async {
  try {
    await Supabase.instance.client
        .from('workout_schedule')
        .update({'completed_exercises': {}})
        .eq('user_id', userId);
  } catch (e) {
    print('Error resetting weekly progress: $e');
  }
}

// Function to fetch remaining exercises for the day
Future<List<Map<String, dynamic>>> fetchRemainingExercises(
    String userId, String dayOfWeek) async {
  try {
    // Fetch the user's workout schedule
    final response = await Supabase.instance.client
        .from('workout_schedule')
        .select('exercises, completed_exercises')
        .eq('user_id', userId)
        .eq('day_of_week', dayOfWeek)
        .single();

    List<dynamic> todaysExercises = List<dynamic>.from(response['exercises']);
    Map<String, dynamic> completedExercises =
        Map<String, dynamic>.from(response['completed_exercises'] ?? {});
    List<dynamic> completedToday =
        List<dynamic>.from(completedExercises[dayOfWeek] ?? []);

    // Filter out completed exercises
    List<Map<String, dynamic>> remainingExercises = todaysExercises
        .where((exercise) => !completedToday.contains(exercise['exercise']))
        .toList()
        .cast<Map<String, dynamic>>();

    return remainingExercises;
  } catch (e) {
    print('Error fetching remaining exercises: $e');
    return [];
  }
}
import 'package:ascend/main-screens/home-page.dart';
import 'package:ascend/main-screens/home-screen.dart';
import 'package:ascend/workouts/feedback.dart';
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
  List<Map<String, int>> _calculateStatsPerExercise(
      List<Map<String, dynamic>> exercises) {
    return exercises.map((exercise) {
      final exerciseName = exercise['exercise'] ?? 'Unknown Exercise';
      final reps = exercise['reps'] ?? 0;

      // Initialize stats for this exercise
      Map<String, int> stats = {
        'strength': 0,
        'stamina': 0,
        'jump_strength': 0,
        'flexibility': 0,
        'endurance': 0,
      };

      // Calculate points based on total reps divided by 2
      double points = reps / 2;

      // Update stats based on the exercise
      switch (exerciseName.toLowerCase()) {
        case 'push ups':
          stats['strength'] = points.toInt();
          break;
        case 'squats':
          stats['stamina'] = points.toInt();
          stats['jump_strength'] = points.toInt();
          break;
        case 'crunches':
          stats['flexibility'] = points.toInt();
          break;
        case 'bicep curls':
          stats['strength'] = points.toInt();
          break;
        case 'plank':
          stats['endurance'] = points.toInt();
          break;
        default:
          print('Unknown exercise: $exerciseName');
      }

      return stats;
    }).toList();
  }

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
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              // Handle rest day
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Today is a rest day.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Taking rest is essential for growth!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Enjoy your rest day!'),
                          ),
                        );
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
                        'Rest Day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (remainingExercises.isNotEmpty) {
                          // Start the first remaining exercise
                          final firstExercise = remainingExercises.first;
                          final exerciseName =
                              firstExercise['exercise'] ?? 'Unknown Exercise';
                          final sets = firstExercise['sets'] ?? 0;
                          final reps = firstExercise['reps'] ?? 0;

                          final exercisePageBuilder =
                              exercisePageMap[exerciseName];
                          if (exercisePageBuilder != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    exercisePageBuilder(context),
                              ),
                            ).then((result) async {
                              if (result == true) {
                                await markExerciseAsCompleted(
                                    userId, today, exerciseName, reps);
                                setState(() {}); // Refresh the UI
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Exercise "$exerciseName" is not implemented yet.'),
                              ),
                            );
                          }
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
                      onPressed: () async {
                        try {
                          // Fetch completed exercises
                          final response = await Supabase.instance.client
                              .from('workout_schedule')
                              .select('exercises, completed_exercises')
                              .eq('user_id', userId)
                              .eq('day_of_week', today)
                              .single();

                          final todaysExercises =
                              List<Map<String, dynamic>>.from(
                                  response['exercises']);
                          final completedExercises = List<String>.from(
                              response['completed_exercises'][today] ?? []);

                          // Filter completed exercises
                          final completedExerciseDetails = todaysExercises
                              .where((exercise) => completedExercises
                                  .contains(exercise['exercise']))
                              .toList();

                          // Fetch stats gained
                          final statsResponse = await Supabase.instance.client
                              .from('statistics')
                              .select('*')
                              .eq('user_id', userId)
                              .single();

                          final Map<String, dynamic> stats =
                              Map<String, dynamic>.from(statsResponse);

                          final Map<String, int> statsGained = {
                            'strength': stats['strength'] ?? 0,
                            'stamina': stats['stamina'] ?? 0,
                            'jump_strength': stats['jump_strength'] ?? 0,
                            'flexibility': stats['flexibility'] ?? 0,
                            'endurance': stats['endurance'] ?? 0,
                          };

                          // Navigate to the feedback page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackPage(
                                completedExercises: completedExerciseDetails,
                                statsGainedPerExercise:
                                    _calculateStatsPerExercise(
                                        completedExerciseDetails),
                              ),
                            ),
                          );
                        } catch (e) {
                          print(
                              'Error fetching completed exercises or stats: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error loading feedback. Please try again later.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'View Feedback',
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
    String userId, String dayOfWeek, String exerciseName, int reps) async {
  try {
    // Fetch the current completed_exercises for the user
    final response = await Supabase.instance.client
        .from('workout_schedule')
        .select('completed_exercises')
        .eq('user_id', userId)
        .eq('day_of_week', dayOfWeek);

    if (response.isEmpty) {
      print('No workout schedule found for user: $userId');
      return;
    }

    Map<String, dynamic> completedExercises =
        Map<String, dynamic>.from(response.first['completed_exercises'] ?? {});

    // Update the completed exercises for the specific day
    List<String> completedToday =
        List<String>.from(completedExercises[dayOfWeek] ?? []);
    if (!completedToday.contains(exerciseName)) {
      completedToday.add(exerciseName);
    }
    completedExercises[dayOfWeek] = completedToday;

    // Update the database
    await Supabase.instance.client
        .from('workout_schedule')
        .update({'completed_exercises': completedExercises})
        .eq('user_id', userId)
        .eq('day_of_week', dayOfWeek);

    print('Successfully marked exercise as completed: $exerciseName');

    // Update the user's stats
    await updateStats(userId, exerciseName, reps);
  } catch (e) {
    print('Error marking exercise as completed: $e');
  }
}

Future<void> updateStats(String userId, String exerciseName, int reps) async {
  try {
    // Fetch the current stats for the user
    final response = await Supabase.instance.client
        .from('statistics')
        .select('*')
        .eq('user_id', userId);

    Map<String, dynamic> stats;
    if (response.isEmpty) {
      // No stats found for the user, initialize default stats
      stats = {
        'user_id': userId,
        'strength': 0,
        'stamina': 0,
        'jump_strength': 0,
        'flexibility': 0,
        'endurance': 0,
      };
      // Insert a new row with default stats
      await Supabase.instance.client.from('statistics').insert(stats);
    } else {
      // Stats found, use the existing stats
      stats = Map<String, dynamic>.from(response.first);
    }

    // Initialize stats variables
    int strength = stats['strength'] ?? 0;
    int stamina = stats['stamina'] ?? 0;
    int jumpStrength = stats['jump_strength'] ?? 0;
    int flexibility = stats['flexibility'] ?? 0;
    int endurance = stats['endurance'] ?? 0;

    // Calculate points based on total reps divided by 2
    double points = reps / 2;

    // Update stats based on the exercise
    switch (exerciseName.toLowerCase()) {
      case 'push ups':
        strength += points.toInt(); // Add half the reps as strength points
        break;
      case 'squats':
        stamina +=
            points.toInt(); // Example: Each rep increases stamina by 1.5x
        jumpStrength +=
            points.toInt(); // Example: Each rep increases jump strength by 0.5x
        break;
      case 'crunches':
        flexibility +=
            points.toInt(); // Example: Each rep increases flexibility by 1x
        break;
      case 'bicep curls':
        strength += points.toInt(); // Add half the reps as strength points
        break;
      case 'plank':
        endurance += points
            .toInt(); // Example: Each second of plank increases endurance by 2.5x
        break;
      default:
        print('Unknown exercise: $exerciseName');
    }

    // Update the database with the new stats
    await Supabase.instance.client.from('statistics').upsert({
      'user_id': userId,
      'strength': strength,
      'stamina': stamina,
      'jump_strength': jumpStrength,
      'flexibility': flexibility,
      'endurance': endurance,
    });

    print('Successfully updated stats for user: $userId');
  } catch (e) {
    print('Error updating stats: $e');
  }
}

// Function to reset weekly progress
Future<void> resetWeeklyProgress(String userId) async {
  try {
    await Supabase.instance.client
        .from('workout_schedule')
        .update({'completed_exercises': {}}).eq('user_id', userId);
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

    List<dynamic> todaysExercises = List.from(response['exercises']);
    Map<String, dynamic> completedExercises =
        Map.from(response['completed_exercises'] ?? {});
    List<dynamic> completedToday =
        List.from(completedExercises[dayOfWeek] ?? []);

    // Check if today is a rest day
    if (todaysExercises.isEmpty ||
        (todaysExercises.length == 1 &&
            todaysExercises.first['exercise'] == 'Rest')) {
      return []; // Return an empty list for rest days
    }

    // Filter out completed exercises
    List<Map<String, dynamic>> remainingExercises = todaysExercises
        .where((exercise) => !completedToday.contains(exercise['exercise']))
        .cast<Map<String, dynamic>>()
        .toList();

    return remainingExercises;
  } catch (e) {
    print('Error fetching remaining exercises: $e');
    return [];
  }
}

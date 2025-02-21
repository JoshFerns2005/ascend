import 'package:ascend/pose_detect/painters/pose_painter.dart';
import 'package:ascend/pose_detect/pose_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the current day
import 'package:supabase_flutter/supabase_flutter.dart';

class CrunchPage extends StatelessWidget {
  final String exerciseName = "Crunches"; // Name of the exercise

  @override
  Widget build(BuildContext context) {
    // Retrieve the user session to get userId
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';

    // Determine today's day
    final today = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Crunch Pose Detector'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchExerciseDetails(userId, exerciseName, today),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading exercise details',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final exerciseDetails = snapshot.data!;
            final sets = exerciseDetails['sets'] ?? 3; // Default to 3 sets
            final reps = exerciseDetails['reps'] ?? 20; // Default to 20 reps

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PoseDetectorView(
                      exerciseName: exerciseName, // Pass the exercise name
                      sets: sets, // Dynamically fetched sets
                      reps: reps, // Dynamically fetched reps
                      onExerciseCompleted: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'No exercise details found for today',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }

  // Fetch exercise details from Supabase for the current day
  Future<Map<String, dynamic>?> _fetchExerciseDetails(String userId, String exerciseName, String today) async {
    try {
      // Fetch the workout schedule for the user
      final response = await Supabase.instance.client
          .from('workout_schedule')
          .select('day_of_week, exercises')
          .eq('user_id', userId)
          .eq('day_of_week', today);

      // Print the entire response for debugging
      print('Fetched response from Supabase: $response');

      if (response != null && response.isNotEmpty) {
        // Extract the exercises for today
        final todaysSchedule = response.first;
        final List<dynamic> exercises = todaysSchedule['exercises'];

        // Print the exercises for today
        print('Exercises for today ($today): $exercises');

        // Find the specific exercise by name
        final exercise = exercises.firstWhere(
          (exercise) => exercise['exercise'] == exerciseName,
          orElse: () => null,
        );

        // Print the found exercise for debugging
        print('Found exercise "$exerciseName": $exercise');

        return exercise as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching exercise details: $e');
      return null;
    }
  }
}
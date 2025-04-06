import 'package:ascend/main-screens/home-screen.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final List<Map<String, dynamic>> completedExercises;
  final List<Map<String, int>> statsGainedPerExercise;

  FeedbackPage({
    required this.completedExercises,
    required this.statsGainedPerExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Summary',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color.fromARGB(255, 0, 43, 79),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Workout Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing
              Expanded(
                child: ListView.builder(
                  itemCount: completedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = completedExercises[index];
                    final exerciseName =
                        exercise['exercise'] ?? 'Unknown Exercise';
                    final sets = exercise['sets'] ?? 0;
                    final reps = exercise['reps'] ?? 0;
                    final bodyParts = _getBodyParts(exerciseName);

                    // Get stats for this specific exercise
                    final statsForExercise = statsGainedPerExercise[index];

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02), // Responsive padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                            Text(
                              '$sets sets, $reps reps',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                            Text(
                              'Body Parts: ${bodyParts.join(", ")}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                            Text(
                              'Stats Gained:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...statsForExercise.entries.map((entry) {
                              if (entry.value > 0) {
                                return Text(
                                  '${entry.key.capitalize()}: +${entry.value}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: MediaQuery.of(context).size.width * 0.04, // Responsive font size
                                  ),
                                );
                              }
                              return SizedBox.shrink(); // Skip stats with zero value
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(username: 'Guest'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color.fromARGB(255, 0, 43, 79),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1, // Responsive horizontal padding
                    vertical: MediaQuery.of(context).size.height * 0.02, // Responsive vertical padding
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(MediaQuery.of(context).size.width * 0.02), // Responsive border radius
                  ),
                ),
                child: Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to map exercises to body parts
  List<String> _getBodyParts(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'push ups':
        return ['Chest', 'Arms'];
      case 'squats':
        return ['Legs', 'Core'];
      case 'crunches':
        return ['Core'];
      case 'bicep curls':
        return ['Arms'];
      case 'plank':
        return ['Core'];
      default:
        return ['Unknown'];
    }
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
import 'package:ascend/main-screens/home-screen.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final List<Map<String, dynamic>> completedExercises;
  final Map<String, int> statsGained;

  FeedbackPage({
    required this.completedExercises,
    required this.statsGained,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout Summary',
          style: TextStyle(
            fontSize: 20,
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Workout Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: completedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = completedExercises[index];
                    final exerciseName = exercise['exercise'] ?? 'Unknown Exercise';
                    final sets = exercise['sets'] ?? 0;
                    final reps = exercise['reps'] ?? 0;
                    final bodyParts = _getBodyParts(exerciseName);

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exerciseName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '$sets sets, $reps reps',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Body Parts: ${bodyParts.join(", ")}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Stats Gained:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...statsGained.entries.map((entry) {
                              return Text(
                                '${entry.key.capitalize()}: +${entry.value}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
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
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: 20,
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
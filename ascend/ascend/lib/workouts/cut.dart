import 'package:flutter/material.dart';

class CutDetailPage extends StatelessWidget {
  // List of workout routines for "cut"
  final List<Map<String, String>> cutWorkouts = [
    {'title': 'Cardio Blast', 'description': '30 minutes of high-intensity cardio.'},
    {'title': 'Bodyweight Circuit', 'description': 'Push-ups, squats, and planks for 3 rounds.'},
    {'title': 'HIIT Training', 'description': '20 minutes of High-Intensity Interval Training.'},
    {'title': 'Core Strength', 'description': 'Plank variations and abdominal exercises.'},
    {'title': 'Fat Burner', 'description': 'Combination of jump rope and burpees.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cut Workout Routines',style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,  // Removes the leading arrow

      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: cutWorkouts.length,
        itemBuilder: (context, index) {
          final workout = cutWorkouts[index];
          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                workout['title']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 43, 79),
                ),
              ),
              subtitle: Text(
                workout['description']!,
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.fitness_center, color: Color.fromARGB(255, 0, 43, 79)),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class FitDetailPage extends StatelessWidget {
  // List of workout routines for staying fit
  final List<Map<String, String>> fitWorkouts = [
    {'title': 'Morning Yoga', 'description': 'Sun salutations, warrior poses, and breathing exercises.'},
    {'title': 'HIIT Circuit', 'description': 'Jumping jacks, burpees, and mountain climbers in intervals.'},
    {'title': 'Full-Body Workout', 'description': 'Bodyweight squats, push-ups, and planks.'},
    {'title': 'Cardio Blast', 'description': 'Jogging, cycling, and skipping rope for endurance.'},
    {'title': 'Core Strength', 'description': 'Russian twists, leg raises, and side planks.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fit Workout Routines',style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,  // Removes the leading arrow

      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: fitWorkouts.length,
        itemBuilder: (context, index) {
          final workout = fitWorkouts[index];
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
              trailing: Icon(Icons.directions_run, color: Color.fromARGB(255, 0, 43, 79)),
            ),
          );
        },
      ),
    );
  }
}

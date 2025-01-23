import 'package:flutter/material.dart';

class BulkDetailPage extends StatelessWidget {
  // List of workout routines for "bulk"
  final List<Map<String, String>> bulkWorkouts = [
    {'title': 'Chest Day', 'description': 'Bench press, incline press, and dumbbell flys.'},
    {'title': 'Leg Day', 'description': 'Squats, lunges, and leg presses for heavy reps.'},
    {'title': 'Back & Biceps', 'description': 'Deadlifts, pull-ups, and barbell curls.'},
    {'title': 'Shoulder Power', 'description': 'Overhead presses, lateral raises, and shrugs.'},
    {'title': 'Triceps Focus', 'description': 'Skull crushers, dips, and close-grip bench press.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk Workout Routines',style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,  // Removes the leading arrow

      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: bulkWorkouts.length,
        itemBuilder: (context, index) {
          final workout = bulkWorkouts[index];
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

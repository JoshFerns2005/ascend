import 'package:ascend/main-screens/home-page.dart';
import 'package:ascend/start-screen/splashHomeScreen.dart';
import 'package:ascend/workouts/bulk.dart';
import 'package:ascend/workouts/cut.dart';
import 'package:ascend/workouts/fit.dart';
import 'package:ascend/workouts/random_exercises/crunch.dart';
import 'package:ascend/workouts/workoutschedule.dart';
import 'package:flutter/material.dart';

import '../workouts/random_exercises/pushup.dart';
import '../workouts/random_exercises/squat.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<String> _exercises = [
    'Push-ups',
    'Squats',
    'Crunches',
    'Plank',
    'Burpees',
  ];

  final Map<String, List<String>> _workouts = {
    'Cut': ['Cardio', 'Bodyweight Exercises'],
    'Bulk': ['Heavy Lifting', 'Strength Training'],
    'Stay Fit': ['Circuit Training', 'High-Intensity Interval Training'],
  };

  List<String> _customWorkout = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Section 1: Random Exercise
            buildCard(
              title: 'Random Exercise',
              content: Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) =>
                      ExerciseCardWithImage(exercise: _exercises[index]),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Section 2: Ready-made Workouts
            buildCard(
              title: 'Ready-made Workouts',
              content: Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _workouts.keys.length,
                  itemBuilder: (context, index) {
                    String category = _workouts.keys.elementAt(index);
                    return GestureDetector(
                      onTap: () =>
                          _navigateToWorkoutCategory(context, category),
                      child: WorkoutCategoryCard(category: category),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Section 3: Make Your Own Workout Plan
            buildCard(
              title: 'Make Your Own Workout Plan',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Add Exercise',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: _customWorkout
                        .map((exercise) => ExerciseCard(name: exercise))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Section 4: Workout Schedule
            buildCard(
              title: 'Workout Schedule',
              content: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WorkoutSchedulePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 28, 51),
                ),
                child: Text(
                  'View Workout Schedule',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({required String title, required Widget content}) {
    return Card(
      color: Color.fromARGB(255, 0, 43, 79),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  void _navigateToWorkoutCategory(BuildContext context, String category) {
    Widget targetPage;
    switch (category) {
      case 'Cut':
        targetPage = CutDetailPage();
        break;
      case 'Bulk':
        targetPage = BulkDetailPage();
        break;
      case 'Stay Fit':
        targetPage = FitDetailPage();
        break;
      default:
        targetPage = Splashhomescreen(); // Fallback for unknown categories
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }
}

class ExerciseCardWithImage extends StatelessWidget {
  final String exercise;

  ExerciseCardWithImage({required this.exercise});

  @override
  Widget build(BuildContext context) {
    // Determine image path based on exercise
    String imagePath;
    switch (exercise) {
      case 'Push-ups':
        imagePath = 'assets/images/pushups.png';
        break;
      case 'Squats':
        imagePath = 'assets/images/squats.jpg';
        break;
      case 'Crunches':
        imagePath = 'assets/images/deadlifts.png';
        break;
      case 'Plank':
        imagePath = 'assets/images/planks.png';
        break;
      case 'Burpees':
        imagePath = 'assets/images/burpees.jpg';
        break;
      default:
        imagePath = 'assets/images/default.png';
    }

    return GestureDetector(
      onTap: () {
        // Navigate to the specific exercise page
        switch (exercise) {
          case 'Push-ups':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PushUpPage()),
            );
            break;
          case 'Squats':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SquatPage()),
            );
            break;
          case 'Crunches':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  CrunchPage()),
            );            break;
          case 'Plank':
            // Add Plank page navigation
            break;
          case 'Burpees':
            // Add Burpees page navigation
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Page not implemented yet for $exercise')),
            );
        }
      },
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8),
            elevation: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 120,
                height: 120,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            exercise,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class WorkoutCategoryCard extends StatelessWidget {
  final String category;

  WorkoutCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    String imagePath;
    switch (category) {
      case 'Cut':
        imagePath = 'assets/images/CutGuy.jpg';
        break;
      case 'Bulk':
        imagePath = 'assets/images/bulkgym.png';
        break;
      case 'Stay Fit':
        imagePath = 'assets/images/fitgirl.png';
        break;
      default:
        imagePath = 'assets/images/default.png';
    }

    return Column(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 8),
          elevation: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          category,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String name;

  ExerciseCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          name,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}

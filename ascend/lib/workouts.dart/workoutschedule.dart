import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutSchedulePage extends StatefulWidget {
  @override
  _WorkoutSchedulePageState createState() => _WorkoutSchedulePageState();
}

class _WorkoutSchedulePageState extends State<WorkoutSchedulePage> {
  final supabase = Supabase.instance.client; // Supabase client instance

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String selectedDay = 'Monday'; // Default selected day

  final List<String> exercises = [
    'Squats',
    'Bicep Curls',
    'Push Ups',
    'Plank',
    'Lunges',
    'Deadlifts',
    'Burpees',
    'Crunches',
  ]; // Predefined exercises list

  Map<String, List<String>> workoutSchedule =
      {}; // Store exercises for each day
  String? userId; // Variable to store the current user's ID

  @override
  void initState() {
    super.initState();
    loadUserIdAndSchedule(); // Fetch user-specific ID and schedule on init
  }

  // Function to fetch the user's ID and schedule
  Future<void> loadUserIdAndSchedule() async {
    try {
      final userBox = Hive.box<String>('userBox'); // Open the user box
      userId = userBox.get('userId'); // Retrieve user ID from Hive

      if (userId == null) {
        print('No user logged in');
        return;
      }

      await fetchUserSchedule(); // Fetch the schedule for this user
    } catch (e) {
      print('Error loading user ID or schedule: $e');
    }
  }

  // Fetch the user's current schedule from Supabase
  Future<void> fetchUserSchedule() async {
    try {
      if (userId == null) {
        print('No user logged in'); // Handle the null case explicitly
        return;
      }

      final response = await supabase
          .from('workout_schedule')
          .select('day_of_week, exercises')
          .eq('user_id', userId!); // Use the non-null assertion operator (!)

      if (response.isNotEmpty) {
        for (var item in response) {
          final day = item['day_of_week'];
          final exercises = item['exercises'].split(',').toList();
          workoutSchedule[day] = exercises;
        }
      }
      setState(() {}); // Update the UI
    } catch (e) {
      print('Error fetching user schedule: $e');
    }
  }

  // Update the selected exercises for a specific day
  void updateSelectedExercises(String exercise, bool isSelected) {
    setState(() {
      workoutSchedule[selectedDay] ??= [];
      if (isSelected) {
        workoutSchedule[selectedDay]!.add(exercise);
      } else {
        workoutSchedule[selectedDay]!.remove(exercise);
      }
    });
  }

  // Save the schedule to the database for the current user
  Future<void> saveToDatabase() async {
    try {
      // Check if userId is null
      final userId =
          Hive.box<String>('userBox').get('userId'); // Retrieve userId
      if (userId == null) {
        print('No user logged in');
        return;
      }

      // Iterate through the workout schedule map
      for (var day in workoutSchedule.keys) {
        final exercises = workoutSchedule[day]!.join(',');

        // Check if a schedule already exists for this user and day
        final existingSchedule = await supabase
            .from('workout_schedule')
            .select()
            .eq('user_id', userId) // userId is now non-null
            .eq('day_of_week', day)
            .maybeSingle();

        if (existingSchedule != null) {
          // If schedule exists, update it
          await supabase
              .from('workout_schedule')
              .update({'exercises': exercises})
              .eq('user_id', userId) // userId is now non-null
              .eq('day_of_week', day);
        } else {
          // If schedule doesn't exist, insert a new row
          await supabase.from('workout_schedule').insert({
            'user_id': userId, // userId is now non-null
            'day_of_week': day,
            'exercises': exercises,
          });
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout schedule saved successfully!')),
      );
    } catch (e) {
      print('Error saving workout schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout schedule.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Schedule'),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
      ),
      body: Row(
        children: [
          // Left-hand side: Days of the week
          Container(
            width:
                MediaQuery.of(context).size.width * 0.4, // 40% of screen width
            color: Color.fromARGB(255, 240, 240, 240),
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                return ListTile(
                  title: Text(
                    day,
                    style: TextStyle(
                      fontWeight: selectedDay == day
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selectedDay == day ? Colors.blue : Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedDay = day; // Update selected day
                    });
                  },
                );
              },
            ),
          ),

          // Right-hand side: Exercise selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercises for $selectedDay:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        // Dynamically set the checkbox state based on the schedule
                        final isSelected =
                            workoutSchedule[selectedDay]?.contains(exercise) ??
                                false;
                        return CheckboxListTile(
                          title: Text(exercise),
                          value: isSelected,
                          onChanged: (bool? value) {
                            updateSelectedExercises(exercise, value ?? false);
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await saveToDatabase();
                      },
                      child: Text('Save Schedule'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 0, 43, 79),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

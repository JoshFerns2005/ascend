import 'package:flutter/material.dart';
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

  // Function to fetch the user's current schedule
  Future<void> fetchUserSchedule() async {
    try {
      final userId = 1; // Replace with the actual user ID
      final response = await supabase
          .from('workout_schedule')
          .select('day_of_week, exercises')
          .eq('user_id', userId);

      if (response.isNotEmpty) {
        for (var item in response) {
          final day = item['day_of_week'];
          final exercises = item['exercises'].split(',').toList();
          workoutSchedule[day] = exercises;
        }
      }
    } catch (e) {
      print('Error fetching user schedule: $e');
    }
  }

  // Function to update the selected exercises for a day
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

  Future<void> saveToDatabase() async {
    try {
      final userId = 1; // Replace with the actual user ID

      // Iterate through the workout schedule map
      for (var day in workoutSchedule.keys) {
        final exercises = workoutSchedule[day]!.join(',');

        // Check if a schedule already exists for this user and day
        final existingSchedule = await supabase
            .from('workout_schedule')
            .select()
            .eq('user_id', userId)
            .eq('day_of_week', day)
            .single();

        if (existingSchedule != null) {
          // If schedule exists, update it
          await supabase
              .from('workout_schedule')
              .update({'exercises': exercises})
              .eq('user_id', userId)
              .eq('day_of_week', day);
        } else {
          // If schedule doesn't exist, insert a new row
          await supabase.from('workout_schedule').insert({
            'user_id': userId,
            'day_of_week': day,
            'exercises': exercises,
          });
        }
      }

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
  void initState() {
    super.initState();
    fetchUserSchedule(); // Fetch user's existing schedule
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

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
    'Lunges',
    'Deadlifts',
    'Burpees',
    'Crunches',
    'Rest',
  ]; // Predefined exercises list

  Map<String, List<Map<String, dynamic>>> workoutSchedule =
      {}; // Store exercises with sets, reps, or time limit for each day

  String? userId; // Variable to store the current user's ID

  @override
  void initState() {
    super.initState();
    loadUserIdAndSchedule(); // Fetch user-specific ID and schedule on init
  }

  // Function to fetch the user's ID and schedule
  Future<void> loadUserIdAndSchedule() async {
    try {
      final user =
          supabase.auth.currentUser; // Get current user from Supabase auth
      if (user == null) {
        print('No user logged in');
        return;
      }
      userId = user.id; // Retrieve user ID from Supabase auth
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
          .eq('user_id', userId!); // Use the current user's ID
      if (response.isNotEmpty) {
        for (var item in response) {
          final day = item['day_of_week'];
          final exercises = List<Map<String, dynamic>>.from(item['exercises']);
          workoutSchedule[day] = exercises;
        }
      }
      setState(() {}); // Update the UI
    } catch (e) {
      print('Error fetching user schedule: $e');
    }
  }

  // Update the selected exercises for a specific day
  void updateSelectedExercises(String exercise, bool isSelected,
      {int sets = 0, int reps = 0, int timeLimit = 0}) {
    setState(() {
      workoutSchedule[selectedDay] ??= [];
      if (isSelected) {
        workoutSchedule[selectedDay]!.add({
          'exercise': exercise,
          'sets': sets,
          'reps': reps,
          'time_limit': timeLimit,
        });
      } else {
        workoutSchedule[selectedDay]!
            .removeWhere((item) => item['exercise'] == exercise);
      }
    });
  }

  // Save the schedule to the database for the current user
  Future<void> saveToDatabase() async {
    try {
      if (userId == null) {
        print('No user logged in');
        return;
      }
      // Iterate through the workout schedule map
      for (var day in workoutSchedule.keys) {
        final exercises = workoutSchedule[day]!;
        // Check if a schedule already exists for this user and day
        final existingSchedule = await supabase
            .from('workout_schedule')
            .select()
            .eq('user_id', userId!) // userId is now non-null
            .eq('day_of_week', day)
            .maybeSingle();
        if (existingSchedule != null) {
          // If schedule exists, update it
          await supabase
              .from('workout_schedule')
              .update({'exercises': exercises})
              .eq('user_id', userId!) // userId is now non-null
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
        title: Text(
          'Workout Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width *
                0.05, // Responsive font size
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 43, 79),
        automaticallyImplyLeading: false,
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
                      fontSize: MediaQuery.of(context).size.width *
                          0.04, // Responsive font size
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
              padding: EdgeInsets.all(MediaQuery.of(context).size.width *
                  0.04), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercises for $selectedDay:',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width *
                          0.045, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // Responsive spacing
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        // Dynamically set the checkbox state based on the schedule
                        final isSelected = workoutSchedule[selectedDay]
                                ?.any((item) => item['exercise'] == exercise) ??
                            false;
                        return ExpansionTile(
                          title: Text(
                            exercise,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width *
                                  0.04, // Responsive font size
                            ),
                          ),
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == true) {
                                showDialog(
                                  context: context,
                                  builder: (context) => _ExerciseDetailsDialog(
                                    exercise: exercise,
                                    onSave: (sets, reps, timeLimit) {
                                      updateSelectedExercises(
                                        exercise,
                                        true,
                                        sets: sets,
                                        reps: reps,
                                        timeLimit: timeLimit,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                updateSelectedExercises(exercise, false);
                              }
                            },
                          ),
                          children: workoutSchedule[selectedDay]
                                  ?.where(
                                      (item) => item['exercise'] == exercise)
                                  .map((item) => ListTile(
                                        title: Text(
                                          'Sets: ${item['sets']}, Reps: ${item['reps']}',
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035, // Responsive font size
                                          ),
                                        ),
                                      ))
                                  .toList() ??
                              [],
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

// Dialog to input sets, reps, or time limit
class _ExerciseDetailsDialog extends StatelessWidget {
  final String exercise;
  final Function(int sets, int reps, int timeLimit) onSave;

  _ExerciseDetailsDialog({required this.exercise, required this.onSave});

  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController timeLimitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details for $exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (exercise != 'Rest') ...[
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Sets'),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Reps'),
            ),
          ]
          // No input fields for "Rest"
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final sets = int.tryParse(setsController.text) ?? 0;
            final reps = int.tryParse(repsController.text) ?? 0;
            final timeLimit = int.tryParse(timeLimitController.text) ?? 0;
            onSave(sets, reps, timeLimit);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

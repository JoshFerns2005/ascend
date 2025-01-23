import 'package:flutter/material.dart';
import 'package:ascend/navbar.dart'; // Import BottomNavBar
import 'workout.dart';
import 'nutrition.dart';
import 'profile.dart';
import 'package:ascend/main-screens/home-page.dart';

class HomeScreen extends StatefulWidget {
  final String username; // Add username property

  HomeScreen({required this.username}); // Constructor to accept username

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Updated screens list to pass username
  late final List<Widget> _screens = [
    HomePage(username: widget.username), // Pass the username
    WorkoutPage(),
    NutritionPage(),
    ProfileScreen(),
  ];

  // BottomNavBar items
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.fitness_center),
      label: 'Workouts',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_dining),
      label: 'Nutrition',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username}"), // Display username in the title
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: const Color.fromARGB(255, 0, 43, 79),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings or perform any action
              print('Settings icon pressed');
            },
          ),
        ],
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: _screens[_selectedIndex], // Display content based on selected tab
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _bottomNavItems, // Using the items list
      ),
    );
  }
}

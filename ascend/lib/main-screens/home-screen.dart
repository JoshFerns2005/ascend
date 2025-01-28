import 'package:ascend/main-screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:ascend/navbar.dart'; // Import BottomNavBar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'workout.dart';
import 'nutrition.dart';
import 'profile.dart';
import 'package:ascend/main-screens/home-page.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Check if the user is authenticated before navigating to ProfileScreen
  late final List<Widget> _screens = [
    HomePage(username: widget.username), // Pass the username to HomePage
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome, ${widget.username}",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        toolbarHeight: 75,
        backgroundColor: Color.fromARGB(255, 0, 28, 50),
        iconTheme:
            IconThemeData(color: Colors.white), // Update icon theme color
        automaticallyImplyLeading: false, // Remove the back button
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Add your desired icon
            onPressed: () {
              // Define the action for the icon, e.g., navigate to settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _bottomNavItems,
      ),
    );
  }
}

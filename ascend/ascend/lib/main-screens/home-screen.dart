import 'package:ascend/main-screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:ascend/navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'workout.dart';
import 'package:ascend/main-screens/nutrition.dart'; // Updated import
import 'profile.dart';
import 'package:ascend/main-screens/home-page.dart';
import 'package:ascend/main.dart'; // Import main to access aiNutritionService

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

  // Updated screens list with NutritionPage
  late final List<Widget> _screens = [
    HomePage(username: widget.username),
    NutritionPage(), // Now properly initialized
    ProfileScreen(),
  ];

  // BottomNavBar items (unchanged)
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
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
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 0, 43, 79),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Do you want to close the app?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Your progress will be saved.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome",
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width *
                  0.05, // Responsive font size
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height *
              0.1, // Responsive toolbar height
          backgroundColor: Color.fromARGB(255, 0, 28, 50),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: MediaQuery.of(context).size.width *
                0.06, // Responsive icon size
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
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
      ),
    );
  }
}

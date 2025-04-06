import 'package:ascend/main-screens/home-screen.dart';
import 'package:ascend/start-screen/account.dart';
import 'package:ascend/start-screen/splashHomeScreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check session immediately after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    try {
      // Retrieve the current session
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // User is logged in, retrieve username from metadata or use a default value
        final userMetadata = session.user?.userMetadata;
        final username = userMetadata?['full_name'] ?? 'Guest'; // Default to 'Guest'

        // Navigate to HomePage with the username
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
        );
      } else {
        // User is not logged in, navigate to Splashhomescreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Splashhomescreen()),
        );
      }
    } catch (e) {
      // Handle any errors during session check
      print('Error checking session: $e');
      // Fallback: Navigate to Splashhomescreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Splashhomescreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 31, 55), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Ascend.png', // App logo
              height: MediaQuery.of(context).size.width * 0.6, // Responsive image height
              width: MediaQuery.of(context).size.width * 0.6, // Responsive image width
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02, // Responsive spacing
            ),
          ],
        ),
      ),
    );
  }
}
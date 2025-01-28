import 'package:ascend/main-screens/home-screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ascend/registrations/userbodydetails.dart'; // Import the user details form screen

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Supabase instance initialization
  late final SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
  }

  // Google Sign-In method
  Future<void> _googleSignIn(BuildContext context) async {
    try {
      // Add your webClientId here for Google Sign-In configuration
      const webClientId = '1057307033858-qfvliijtf970eu6i210ttj9b1it7gn3r.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId, // Set the serverClientId to your webClientId
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In was canceled.')),
        );
        return;
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missing tokens.')),
        );
        return;
      }

      // Use Supabase to sign in with the Google tokens
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user != null) {
        // Check if user details already exist
        final userId = authResponse.user!.id;
        final response = await supabase.from('userdetails').select().eq('user_id', userId).maybeSingle();

        if (response == null) {
          // User doesn't have details, navigate to the UserDetailsForm page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsForm(), // Navigate to the form screen
            ),
          );
        } else {
          // User already has details, proceed to the main page or dashboard
          final username = authResponse.user!.userMetadata?['full_name'] ?? 'User';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(username: username), // Pass username to HomeScreen
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed.')),
        );
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 55),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/Ascend.png',
                    height: 300,
                    width: 300,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15), // Reduced padding
                      minimumSize: Size(double.infinity, 50), // Increased width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90), // Rounded corners
                      ),
                    ),
                    onPressed: () => _googleSignIn(context), // Google Sign-In button
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 31, 55), // Text color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

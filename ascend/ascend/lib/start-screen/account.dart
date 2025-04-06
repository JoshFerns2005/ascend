import 'package:ascend/main-screens/home-screen.dart';
import 'package:ascend/start-screen/privacypolicy.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ascend/registrations/userbodydetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final SupabaseClient supabase;
  final GoogleSignIn _googleSignInInstance = GoogleSignIn(
    // Renamed this
    serverClientId:
        '1057307033858-qfvliijtf970eu6i210ttj9b1it7gn3r.apps.googleusercontent.com',
  );

  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
  }

  Future<void> _handleNavigation(BuildContext context, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final isPolicyAccepted = prefs.getBool('privacy_policy_accepted') ?? false;
    final hasUserDetails = await _checkUserDetails(userId);

    if (!isPolicyAccepted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrivacyPolicyScreen(
            onAccept: () =>
                _navigateAfterPolicy(context, userId, hasUserDetails),
          ),
        ),
      );
    } else {
      _navigateToAppropriateScreen(context, userId, hasUserDetails);
    }
  }

  Future<bool> _checkUserDetails(String userId) async {
    final response = await supabase
        .from('userdetails')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  void _navigateAfterPolicy(
      BuildContext context, String userId, bool hasUserDetails) {
    if (!hasUserDetails) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetailsForm()),
      );
    } else {
      _navigateToHome(context, userId);
    }
  }

  void _navigateToAppropriateScreen(
      BuildContext context, String userId, bool hasUserDetails) {
    if (!hasUserDetails) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDetailsForm()),
      );
    } else {
      _navigateToHome(context, userId);
    }
  }

  void _navigateToHome(BuildContext context, String userId) async {
  try {
    // Fetch the user's authentication data
    final userData = await supabase.auth.getUser();

    // Extract the display_name (username) from the user's metadata
    final username = userData.user?.userMetadata?['full_name'] ??
        userData.user?.email ??
        'User'; // Fallback to email or "User" if no display_name exists

    // Navigate to the HomeScreen with the username
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(username: username),
      ),
    );
  } catch (error) {
    debugPrint('Error fetching user data: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch user data: $error')),
    );
  }
}

  Future<void> _initializeUserStats(String userId) async {
    try {
      // Check if the user already has a row in the statistics table
      final response = await supabase
          .from('statistics')
          .select()
          .eq('user_id', userId)
          .limit(1);

      if (response.isEmpty) {
        // No stats exist for the user, so create a new row
        await supabase.from('statistics').insert({
          'user_id': userId,
          'strength': 0,
          'stamina': 0,
          'jump_strength': 0,
          'flexibility': 0,
          'endurance': 0,
        });
        debugPrint('New stats row created for user: $userId');
      } else {
        debugPrint('Stats row already exists for user: $userId');
      }
    } catch (error) {
      debugPrint('Error initializing stats: $error');
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Authenticate the user with Google
      final GoogleSignInAccount? googleUser =
          await _googleSignInInstance.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Missing Google tokens');
      }

      // Sign in with Supabase
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user != null) {
        final userId = authResponse.user!.id;

        // Initialize the user's stats in the statistics table
        await _initializeUserStats(userId);

        // Handle navigation based on privacy policy and user details
        await _handleNavigation(context, userId);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 55),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Ascend.png',
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  minimumSize: Size(double.infinity,
                      MediaQuery.of(context).size.height * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.05),
                  ),
                ),
                onPressed: () =>
                    _signInWithGoogle(context), // Updated reference
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Color.fromARGB(255, 1, 31, 55),
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onAccept;
  final bool showOnlyPolicy; // Add this parameter

  const PrivacyPolicyScreen({
    Key? key,
    required this.onAccept,
    this.showOnlyPolicy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 55),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 31, 55),
        title: const Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false, // Disable automatic back button
        leading: showOnlyPolicy
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Navigate back manually
                },
              )
            : null, // No back button if showOnlyPolicy is false
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy & Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Removed `const` here because DateTime.now() is not constant
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Collection and Usage',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The Ascend Fitness App is committed to protecting the personal information of its users. '
              'We collect and store data such as user profiles, workout progress, and selected game '
              'characters securely via Supabase. Information like height, weight, age, and BMI is used '
              'strictly for providing personalized fitness recommendations and improving the app experience. '
              'All data is encrypted and will never be sold or shared with third parties without consent.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'User Agreement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'By using the Ascend App, users agree to provide accurate information during sign-up and '
              'use the app in accordance with health guidelines. The app is not a substitute for '
              'professional medical advice. Users are responsible for their health while performing '
              'exercises. Any misuse, attempt to exploit the game mechanics, or violation of data '
              'integrity policies may result in restricted access or termination of service. Continued '
              'use of the application constitutes acceptance of these terms.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            if (!showOnlyPolicy) // Only show accept button if it's the first-time flow
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('privacy_policy_accepted', true);
                    onAccept();
                  },
                  child: const Text('I Agree to Terms and Conditions',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:ascend/start-screen/account.dart';
import 'package:ascend/start-screen/startuserguide.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ascend/start-screen/splashscreen.dart'; // Adjust import path as needed
import 'package:ascend/start-screen/privacypolicy.dart'; // Import PrivacyPolicyScreen

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width *
                0.05, // Responsive font size
          ),
        ),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height *
            0.1, // Responsive toolbar height
        backgroundColor: const Color.fromARGB(255, 0, 28, 50),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 0, 28, 50).withOpacity(0.8),
              const Color.fromARGB(255, 0, 28, 50).withOpacity(0.9),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04), // Responsive padding
          child: Column(
            children: [
              // About Us Section
              _buildSettingsCard(
                context,
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.02), // Responsive spacing

              // Privacy Policy Section
              _buildSettingsCard(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrivacyPolicyScreen(
                        onAccept: () {
                          // Optional: Handle any post-acceptance logic if needed
                        },
                        showOnlyPolicy:
                            true, // Show only the policy without the accept button
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.02), // Responsive spacing


              // Logout Section
              _buildSettingsCard(
                context,
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: () {
                  _confirmLogout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation:
          MediaQuery.of(context).size.width * 0.01, // Responsive elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width *
            0.03), // Responsive border radius
      ),
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width *
            0.03), // Responsive border radius
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(
              MediaQuery.of(context).size.width * 0.04), // Responsive padding
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red[300] : Colors.white70,
                size: MediaQuery.of(context).size.width *
                    0.07, // Responsive icon size
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.04), // Responsive spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width *
                      0.045, // Responsive font size
                  color: isDestructive ? Colors.red[300] : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: isDestructive ? Colors.red[300] : Colors.white70,
                size: MediaQuery.of(context).size.width *
                    0.06, // Responsive icon size
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 28, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width *
                    0.04), // Responsive border radius
          ),
          title: Text(
            'About Ascend',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width *
                  0.05, // Responsive font size
            ),
          ),
          content: Text(
            'Ascend is your personal fitness companion app that helps you track workouts, nutrition, and progress towards your fitness goals.\n\nVersion 1.0.0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: MediaQuery.of(context).size.width *
                  0.04, // Responsive font size
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: MediaQuery.of(context).size.width *
                      0.04, // Responsive font size
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 0, 28, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width *
                        0.04), // Responsive border radius
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width *
                      0.05, // Responsive font size
                ),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: MediaQuery.of(context).size.width *
                      0.04, // Responsive font size
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: MediaQuery.of(context).size.width *
                          0.04, // Responsive font size
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: MediaQuery.of(context).size.width *
                          0.04, // Responsive font size
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldLogout) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AccountScreen()),
        (route) => false,
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../registrations/login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData; // To store fetched user data
  bool isLoading = true; // To show loading state

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void logout(BuildContext context) async {
    final userBox = Hive.box<String>('userBox');
    await userBox.clear(); // Clear all user data from Hive
    print('User logged out.'); // Debugging purpose

    // Navigate to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> fetchUserData() async {
    try {
      final userBox = Hive.box<String>('userBox');
      final String? userId = userBox.get('userId'); // Retrieve userId from Hive

      if (userId == null) {
        throw Exception('User ID not found in Hive');
      }

      // Query Supabase to fetch user data
      final response = await Supabase.instance.client
          .from('useraccounts') // Table name in Supabase
          .select()
          .eq('id', userId)
          .single(); // Retrieve a single user's data

      if (response == null) {
        throw Exception('User not found');
      }

      setState(() {
        userData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color.fromARGB(255, 1, 31, 55),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : userData == null
              ? Center(
                  child: Text('Failed to load user data.'),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            userData!['profileImageUrl'] ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                        SizedBox(height: 20),

                        // Name
                        Text(
                          userData!['name'] ?? 'Unknown Name',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        // Email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              userData!['email'] ?? 'Unknown Email',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Phone
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              userData!['phone'] ?? 'Unknown Phone',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Divider
                        Divider(thickness: 1, color: Colors.grey[300]),

                        SizedBox(height: 20),


                        // Logout button
                        ElevatedButton(
                          onPressed: () => logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Button color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
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

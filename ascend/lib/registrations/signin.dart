import 'package:ascend/main-screens/home-page.dart';
import 'package:ascend/registrations/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninScreen extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  // Controllers for the text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // New Phone Controller

  Future<void> signUp(BuildContext context) async {
    try {
      // Get the values from the controllers
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String dob = dobController.text.trim();
      String phone = phoneController.text.trim();

      // Validate phone number
      if (!RegExp(r'^\d{10,15}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone number. Enter 10-15 digits.')),
        );
        return;
      }

      // Validate DOB
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dob)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD.')),
        );
        return;
      }

      // Insert user data into Supabase
      final response = await supabase.from('useraccounts').insert({
        'name': name,
        'email': email,
        'password': password,
        'date_of_birth': dob,
        'phone': phone, // Add phone to the database
      });

      if (response.error == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your home screen
        );
      } else {
        print('Signup Error: ${response.error?.message}');
      }
    } catch (e) {
      print('Signup Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/SignGym.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Color.fromARGB(255, 1, 31, 55).withOpacity(0.5),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Create a password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Phone number field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Enter your phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Date of Birth field
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: 'Enter your date of birth (YYYY-MM-DD)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Signup button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90),
                      ),
                    ),
                    onPressed: () {
                      signUp(context);
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 31, 55),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Back to login
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back to LoginScreen
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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

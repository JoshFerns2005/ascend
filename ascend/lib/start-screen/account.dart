import 'package:ascend/registrations/login.dart';
import 'package:ascend/registrations/signin.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 31, 55), // Text color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button color
                      padding: EdgeInsets.symmetric(vertical: 15), // Reduced padding
                      minimumSize: Size(double.infinity, 50), // Increased width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(90), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SigninScreen()),
                      );
                    },
                    child: Text(
                      'Signup',
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

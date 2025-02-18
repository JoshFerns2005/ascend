import 'package:ascend/start-screen/account.dart';
import 'package:flutter/material.dart';

class Splashhomescreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 31, 55),
      body: Center(
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0), // Added horizontal padding
                  child: Text.rich(
                    TextSpan(
                      text: 'Push boundaries,\n',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      children: [
                        TextSpan(
                          text: 'achieve greatness,\n',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        TextSpan(
                          text: 'Ascend.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(189, 14, 52, 104), // Button color
                      padding:
                          EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(90), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountScreen()),
                      );
                    },
                    child: Text(
                      'Welcome',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255), // Text color
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

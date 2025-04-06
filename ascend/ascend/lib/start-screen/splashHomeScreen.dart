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
                  height: MediaQuery.of(context).size.width * 0.6, // Responsive image height
                  width: MediaQuery.of(context).size.width * 0.6, // Responsive image width
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1), // Responsive horizontal padding
                  child: Text.rich(
                    TextSpan(
                      text: 'Push boundaries,\n',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      children: [
                        TextSpan(
                          text: 'achieve greatness,\n',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        TextSpan(
                          text: 'Ascend.',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Responsive spacing
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01), // Responsive top padding
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(189, 14, 52, 104), // Button color
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.2, // Responsive horizontal padding
                        vertical: MediaQuery.of(context).size.height * 0.02, // Responsive vertical padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05), // Responsive border radius
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
                        fontSize: MediaQuery.of(context).size.width * 0.045, // Responsive font size
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
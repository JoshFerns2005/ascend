import 'package:flutter/material.dart';

class NutritionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(200, 0, 43, 79),
      body: Center(
        child: Text(
          'Your Nutrition Information!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

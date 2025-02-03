import 'package:flutter/material.dart';

class SquatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Push-ups')),
      body: Center(
        child: Text(
          'Details and instructions about Push-ups',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

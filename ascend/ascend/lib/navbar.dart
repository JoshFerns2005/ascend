import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items, // New items parameter
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed, // Fixed for more than 3 items
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color.fromARGB(255, 76, 76, 76),
      backgroundColor: Color.fromARGB(255, 0, 28, 50),
      items: widget.items, // Using the items parameter
    );
  }
}

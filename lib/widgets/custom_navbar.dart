import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Trips'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Drivers'),
        BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: 'Vehicles'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
      ],
      onTap: (index) {
        // TODO: Implement navigation logic
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(RideShareApp());
}

class RideShareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideShare',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color(0xFFF6F7FB),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 
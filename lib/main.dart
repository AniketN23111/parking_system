import 'package:flutter/material.dart';
import 'package:parking_system/Home/bike_entry_screen.dart';
import 'package:parking_system/Home/bike_exit_screen.dart';
import 'package:parking_system/Home/home_screen.dart';

void main() => runApp( MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike Parking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/entry': (context) => const BikeEntryScreen(),
        '/exit': (context) => const BikeExitScreen(),
      },
    );
  }
}





import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bike Parking System')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/entry'),
              child: const Text('Bike Entry'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/exit'),
              child: const Text('Bike Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
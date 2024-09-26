import 'package:flutter/material.dart';
import 'package:parking_system/Service/database_service.dart';

class BikeExitScreen extends StatefulWidget {
  const BikeExitScreen({super.key});

  @override
  State<BikeExitScreen> createState() => _BikeExitScreenState();
}

class _BikeExitScreenState extends State<BikeExitScreen> {
  final TextEditingController _numberPlateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bike Exit")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numberPlateController,
              decoration: const InputDecoration(labelText: 'Bike Number Plate'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                DatabaseService()
                    .scanBikeExit(numberPlate: _numberPlateController.text);
              },
              child: const Text('Scan and Exit Bike'),
            ),
          ],
        ),
      ),
    );
  }
}

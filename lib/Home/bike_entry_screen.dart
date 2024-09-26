import 'package:flutter/material.dart';
import 'package:parking_system/Service/database_service.dart';

class BikeEntryScreen extends StatefulWidget {
  const BikeEntryScreen({super.key});

  @override
  State<BikeEntryScreen> createState() => _BikeEntryScreenState();
}

class _BikeEntryScreenState extends State<BikeEntryScreen> {
  final TextEditingController _numberPlateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bike Entry")),
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
                    .scanBikeEntry(numberPlate: _numberPlateController.text);
              },
              child: const Text('Scan and Enter Bike'),
            ),
          ],
        ),
      ),
    );
  }
}

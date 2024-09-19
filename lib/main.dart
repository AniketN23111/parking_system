import 'package:flutter/material.dart';
import 'package:parking_system/Parking%20Area%20Register/parking_area_register.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: ParkingAreaRegister(),
    );
  }
}





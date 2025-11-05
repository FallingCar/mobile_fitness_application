import 'package:flutter/material.dart';
import 'package:mobile_fitness_application/fitness_calculation.dart';
import 'landing_page.dart';
import 'fitness_page.dart';
// import 'dart:io';
// import 'package:geolocator/geolocator.dart';


void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Geolocator.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override


  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routes: {
        '/browse': (context) => MyApp(),
      },
      home: const MyApp(),
    );
  }
}



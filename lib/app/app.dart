import 'package:flutter/material.dart';
import '../features/home/home_screen.dart'; // Imports your new home screen

class LifeLearningApp extends StatelessWidget {
  const LifeLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saksham',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Points to your new Feature-based Home
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class DriveAndLearnScreen extends StatefulWidget {
  const DriveAndLearnScreen({super.key});
  @override
  State<DriveAndLearnScreen> createState() => _DriveAndLearnScreenState();
}

class _DriveAndLearnScreenState extends State<DriveAndLearnScreen> {
  // --- VEHICLE DATA ---
  final List<Map<String, dynamic>> vehicles = [
    {
      "name": "Bus",
      "icon": Icons.directions_bus_rounded,
      "color": Colors.orangeAccent,
      "sound": "Honk Honk!"
    },
    {
      "name": "Train",
      "icon": Icons.train_rounded,
      "color": Colors.redAccent,
      "sound": "Choo Choo!"
    },
    {
      "name": "Taxi",
      "icon": Icons.local_taxi_rounded,
      "color": Colors.yellowAccent,
      "sound": "Beep Beep!"
    },
    {
      "name": "Bike",
      "icon": Icons.pedal_bike_rounded,
      "color": Colors.cyanAccent,
      "sound": "Ring Ring!"
    },
  ];

  int? _selectedVehicleIndex;
  double _vehiclePosition = -0.9;
  bool _isFinished = false;

  // --- LOGIC ---
  void _selectVehicle(int index) {
    setState(() {
      _selectedVehicleIndex = index;
      _vehiclePosition = -0.9;
      _isFinished = false;
    });
    speak("Tap to drive the ${vehicles[index]['name']}!");
  }

  void _driveVehicle() {
    if (_isFinished) return;
    setState(() {
      _vehiclePosition += 0.15;
    });
    speak(vehicles[_selectedVehicleIndex!]['sound']);
    if (_vehiclePosition >= 0.9) _finishRace();
  }

  void _finishRace() {
    setState(() {
      _isFinished = true;
      _vehiclePosition = 0.9;
    });
    PlayerStats.addXP(10);
    playSound("success.mp3");
    speak("Great Job!");
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _selectedVehicleIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
            _selectedVehicleIndex == null ? "Select Vehicle" : "Go Go Go!",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [LanguageButton(onChanged: () => setState(() {}))],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              if (_selectedVehicleIndex != null) {
                // Go back to vehicle selection
                setState(() => _selectedVehicleIndex = null);
              } else {
                // Go back to Game Zone Main Menu
                Navigator.pop(context); 
              }
            }),
      ),
      body: BackgroundWrapper(
        child: _selectedVehicleIndex == null
            ? _buildVehicleSelection()
            : _buildRacingScene(),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), // Added top padding so AppBar doesn't overlap
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        return GlassCard(
          onTap: () => _selectVehicle(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(v['icon'], size: 50, color: v['color']),
              const SizedBox(height: 10),
              Text(v['name'],
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRacingScene() {
    final vehicle = vehicles[_selectedVehicleIndex!];
    return GestureDetector(
      onTap: _driveVehicle,
      child: Stack(
        children: [
          Center(
            child: Text(
              _isFinished ? "FINISHED! 🎉" : "TAP TO DRIVE!",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[800],
              child: Center(
                  child: Container(
                      width: double.infinity,
                      height: 5,
                      color: Colors.white30)),
            ),
          ),
          Align(
            alignment: Alignment(_vehiclePosition, 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isFinished)
                  Text(vehicle['sound'],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(vehicle['icon'], size: 80, color: vehicle['color']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
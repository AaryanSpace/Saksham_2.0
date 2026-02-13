import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';
import '../ninja/ninja_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});
  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  // --- VEHICLE DATA ---
  final List<Map<String, dynamic>> vehicles = [
    {"name": "Bus", "icon": Icons.directions_bus_rounded, "color": Colors.orangeAccent, "sound": "Honk Honk!"},
    {"name": "Train", "icon": Icons.train_rounded, "color": Colors.redAccent, "sound": "Choo Choo!"},
    {"name": "Taxi", "icon": Icons.local_taxi_rounded, "color": Colors.yellowAccent, "sound": "Beep Beep!"},
    {"name": "Bike", "icon": Icons.pedal_bike_rounded, "color": Colors.cyanAccent, "sound": "Ring Ring!"},
  ];

  bool _isPlayingVehicles = false;
  int? _selectedVehicleIndex;
  double _vehiclePosition = -0.9;
  bool _isFinished = false;

  // --- LOGIC ---
  void _startVehicleGame() {
    setState(() {
      _isPlayingVehicles = true;
      _selectedVehicleIndex = null;
    });
    speak("Select a vehicle to drive!");
  }

  void _startNinjaGame() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NinjaScreen()));
  }

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
    // --- MAIN MENU (SQUARE CARDS) ---
    if (!_isPlayingVehicles) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Game Zone", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [LanguageButton(onChanged: () => setState(() {}))],
        ),
        body: BackgroundWrapper(
          child: Column(
            children: [
              const SizedBox(height: 100), // Space for AppBar
              const Text(
                "Choose a Game",
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // GRID OF SQUARE CARDS
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0, // Perfect Square
                  children: [
                    // CARD 1: DRIVE & LEARN (Coming Soon)
                    _buildSquareGameCard(
                      "Drive & Learn",
                      Icons.directions_car_filled_rounded,
                      Colors.orangeAccent,
                      () {
                        // SHOW COMING SOON DIALOG
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color.fromARGB(255, 216, 47, 47),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Column(
                              children: [
                                Icon(Icons.construction_rounded, color: Color.fromARGB(255, 234, 255, 0) , size: 60),
                                SizedBox(height: 10),
                                Text("Coming Soon!", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: const Text(
                              "This game is currently being built.\nCheck back later!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK", style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 234, 255, 0))),
                              )
                            ],
                          ),
                        );
                      },
                    ),

                    // CARD 2: MATH NINJA (Active)
                    _buildSquareGameCard(
                      "Math Ninja",
                      Icons.cut_rounded,
                      Colors.redAccent,
                      _startNinjaGame,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- VEHICLE GAME SCREEN (Kept for future use) ---
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_selectedVehicleIndex == null ? "Select Vehicle" : "Go Go Go!",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [LanguageButton(onChanged: () => setState(() {}))],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              if (_selectedVehicleIndex != null) {
                setState(() => _selectedVehicleIndex = null);
              } else {
                setState(() => _isPlayingVehicles = false);
              }
            }),
      ),
      body: BackgroundWrapper(
        child: _selectedVehicleIndex == null ? _buildVehicleSelection() : _buildRacingScene(),
      ),
    );
  }

  // NEW SQUARE CARD WIDGET
  Widget _buildSquareGameCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 45, color: color),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20,
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
              Text(v['name'], style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200, width: double.infinity, color: Colors.grey[800],
              child: Center(child: Container(width: double.infinity, height: 5, color: Colors.white30)),
            ),
          ),
          Align(
            alignment: Alignment(_vehiclePosition, 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isFinished) Text(vehicle['sound'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(vehicle['icon'], size: 80, color: vehicle['color']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
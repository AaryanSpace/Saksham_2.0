import 'package:flutter/material.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

// Import your 4 separate game files here
import 'drive_and_learn_screen.dart';
import 'ninja_screen.dart';
import 'balloon_sort_screen.dart';
import 'time_master_screen.dart';

class GameZoneScreen extends StatefulWidget {
  const GameZoneScreen({super.key});

  @override
  State<GameZoneScreen> createState() => _GameZoneScreenState();
}

class _GameZoneScreenState extends State<GameZoneScreen> {
  @override
  Widget build(BuildContext context) {
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
            
            // THE 4-GAME GRID
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0, // Perfect Squares
                children: [
                  // CARD 1: DRIVE & LEARN
                  _buildSquareGameCard(
                    "Drive & Learn",
                    Icons.directions_car_filled_rounded,
                    Colors.orangeAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriveAndLearnScreen())),
                  ),
                  
                  // CARD 2: MATH NINJA
                  _buildSquareGameCard(
                    "Math Ninja",
                    Icons.cut_rounded,
                    Colors.redAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NinjaScreen())),
                  ),

                  // CARD 3: BALLOON SORT
                  _buildSquareGameCard(
                    "Balloon Sort",
                    Icons.bubble_chart_rounded, 
                    Colors.purpleAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BalloonSortScreen())),
                  ),

                  // CARD 4: TIME MASTER
                  _buildSquareGameCard(
                    "Time Master",
                    Icons.access_time_filled_rounded,
                    Colors.cyanAccent,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TimeMasterScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SQUARE CARD WIDGET UI
  Widget _buildSquareGameCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
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
}
import 'package:flutter/material.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';
import 'dashboard_screen.dart'; 

// Make sure your globals is imported properly so we can use PlayerStats.xp
import '../../core/utils/globals.dart'; 

import 'drive_and_learn_screen.dart';
import 'balloon_sort_screen.dart';
import 'time_master_screen.dart';
import 'number_balance_screen.dart';
import 'energy_balance_screen.dart';
import 'ninja_screen.dart';

class GameZoneScreen extends StatefulWidget {
  const GameZoneScreen({super.key});

  @override
  State<GameZoneScreen> createState() => _GameZoneScreenState();
}

class _GameZoneScreenState extends State<GameZoneScreen> {
  
  // 🔥 CHANGE 1: Ab initial stars 0 nahi, global PlayerStats se aayenge
  int _currentStars = 0; 

  @override
  void initState() {
    super.initState();
    // Screen start hote hi current stars fetch karenge
    _currentStars = PlayerStats.xp; 
  }

  // 🔥 CHANGE 2: GAME SE WAPAS AANE PAR STARS REFRESH AUR POP-UP KA LOGIC 🔥
  void _refreshStarsAfterGame() {
    // 1. Game se aane ke baad naye stars fetch karo
    int newStars = PlayerStats.xp; 

    // 2. Check karo ki kya koi naya game unlock hua hai jo pehle nahi tha?
    if (_currentStars < 50 && newStars >= 50) {
      _showUnlockDialog("Balloon Sort", Icons.bubble_chart_rounded, Colors.purpleAccent, const BalloonSortScreen());
    } else if (_currentStars < 100 && newStars >= 100) {
      _showUnlockDialog("Math Ninja", Icons.cut_rounded, Colors.redAccent, const NinjaScreen());
    } else if (_currentStars < 150 && newStars >= 150) {
      _showUnlockDialog("Time Master", Icons.access_time_filled_rounded, Colors.cyanAccent, const TimeMasterScreen());
    } else if (_currentStars < 200 && newStars >= 200) {
      _showUnlockDialog("Number Balance", Icons.monitor_weight_rounded, Colors.indigoAccent, const NumberBalanceScreen());
    } else if (_currentStars < 250 && newStars >= 250) {
      _showUnlockDialog("Energy Balancer", Icons.balance_rounded, Colors.greenAccent, const EnergyBalanceScreen());
    }

    // 3. Screen ko naye stars ke sath update kar do taaki UI refresh ho jaye
    setState(() {
      _currentStars = newStars;
    });
  }

  // UNLOCK POP-UP ME REDIRECTION
  void _showUnlockDialog(String title, IconData icon, Color color, Widget targetScreen) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut), 
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 25, spreadRadius: 5)]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🎉 NEW GAME UNLOCKED!", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
                    const SizedBox(height: 25),
                    
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2), 
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)]
                      ),
                      child: Icon(icon, size: 70, color: color),
                    ),
                    const SizedBox(height: 25),
                    
                    Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("You have reached $_currentStars ⭐", style: const TextStyle(color: Colors.white70, fontSize: 17)),
                    const SizedBox(height: 30),
                    
                    // 🔥 NAYA: PLAY NOW REDIRECTION 🔥
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 15)
                        ),
                        onPressed: () {
                          // 1. Pehle Pop-up band karo
                          Navigator.pop(context);
                          // 2. Phir naye game ko khol do
                          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)).then((_) {
                            // Wapas aane par phir se stars check karo
                            _refreshStarsAfterGame();
                          });
                        },
                        child: const Text("PLAY NOW", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // DEMO CHEAT BUTTON KO BHI UPDATE KIYA
  void _addStarsForDemo() {
    // Manually PlayerStats me add kar rahe demo ke liye
    PlayerStats.xp += 50; 
    _refreshStarsAfterGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: _addStarsForDemo,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),

      body: BackgroundWrapper(
        child: SafeArea( 
          child: Column(
            children: [
              const SizedBox(height: 10), 
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("Game Zone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.amber)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 38), 
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(currentStars: _currentStars)));
                            },
                          ),
                          LanguageButton(onChanged: () => setState(() {})),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 25), 
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Choose a Game", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: Text("⭐ $_currentStars", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2, 
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0, 
                  children: [
                    _buildLockedGameCard(
                      title: "Drive & Learn",
                      icon: Icons.directions_car_filled_rounded,
                      color: Colors.orangeAccent,
                      requiredStars: 0, 
                      targetScreen: const DriveAndLearnScreen(),
                    ),
                    _buildLockedGameCard(
                      title: "Balloon Sort",
                      icon: Icons.bubble_chart_rounded, 
                      color: Colors.purpleAccent,
                      requiredStars: 50,
                      targetScreen: const BalloonSortScreen(),
                    ),
                    _buildLockedGameCard(
                      title: "Math Ninja",
                      icon: Icons.cut_rounded,
                      color: Colors.redAccent,
                      requiredStars: 100,
                      targetScreen: const NinjaScreen(),
                    ),
                    _buildLockedGameCard(
                      title: "Time Master",
                      icon: Icons.access_time_filled_rounded,
                      color: Colors.cyanAccent,
                      requiredStars: 150,
                      targetScreen: const TimeMasterScreen(),
                    ),
                    _buildLockedGameCard(
                      title: "Number Balance",
                      icon: Icons.monitor_weight_rounded, 
                      color: Colors.indigoAccent,
                      requiredStars: 200, 
                      targetScreen: const NumberBalanceScreen(),
                    ),
                    _buildLockedGameCard(
                      title: "Energy Balancer",
                      icon: Icons.balance_rounded, 
                      color: Colors.greenAccent,
                      requiredStars: 250,
                      targetScreen: const EnergyBalanceScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FIX KIYA HUA: WIDGET TARGET SCREEN AUR OVERLAY 🔥
  Widget _buildLockedGameCard({
    required String title, 
    required IconData icon, 
    required Color color, 
    required int requiredStars, 
    required Widget targetScreen
  }) {
    bool isLocked = _currentStars < requiredStars;
return GestureDetector(
//  PROGRESSION & STATE SYNC LOGIC 
    onTap: () async {
      if (isLocked) {
        // Show locked alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🔒 Earn $requiredStars ⭐ to unlock $title!")),
        );
      } else {
        // 1. Pause the Game Zone and go to the selected Game
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => targetScreen),
        );
        // 2. User is back! Instantly refresh stars & trigger unlock pop-ups
        _refreshStarsAfterGame();
      }
    },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center, 
          children: [
            Opacity(
              opacity: isLocked ? 1.0 : 1.0, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(icon, size: 40, color: color), 
                  ),
                  const SizedBox(height: 12), 
                  Text(
                    title, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ],
              ),
            ),

            // 🛑 LAYER 2: THE NEW LOCKED STATE OVERLAY (Black Square)
            if (isLocked)
              Container(
                width: 130, // Black box ki chaurai
                height: 130, // Black box ki lumbai
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55), // Background image halki si dikhegi
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.white, size: 40),
                    
                    // 🔥 GAPS KO MAINTAIN KARNE KE LIYE: SizedBox 🔥
                    const SizedBox(height: 8), 

                    Text(
                      "Needs $requiredStars ⭐", 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 13.5, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
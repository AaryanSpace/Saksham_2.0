import 'package:flutter/material.dart';

// Aapke core imports
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  // 🔥 DEMO KE LIYE: Hum pichli screen (Game Zone) se stars yahan bhejenge
  // 🟢 ASLI APP KE LIYE COMMENT: Jab Play Store par daalenge, toh is variable 
  // ko hata kar seedha PlayerStats.xp ya SharedPreferences se data fetch karenge.
  final int currentStars; 

  const DashboardScreen({super.key, required this.currentStars});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late List<Map<String, dynamic>> _badges;

  @override
  void initState() {
    super.initState();
        // Trophies tabhi 'unlocked: true' hongi jab utne stars pure honge!

    // 🔥 DYNAMIC TROPHY SYSTEM 🔥
    int stars = widget.currentStars;
    _badges = [
      {'name': 'Drive & Learn', 'icon': '🚗', 'unlocked': true, 'color': Colors.orangeAccent}, // 0 ⭐
      {'name': 'Balloon Sort', 'icon': '🎈', 'unlocked': stars >= 50, 'color': Colors.purpleAccent}, // 50 ⭐
      {'name': 'Math Ninja', 'icon': '🥷', 'unlocked': stars >= 100, 'color': Colors.redAccent}, // 100 ⭐
      {'name': 'Time Master', 'icon': '⏳', 'unlocked': stars >= 150, 'color': Colors.cyanAccent}, // 150 ⭐
      {'name': 'Number Balance', 'icon': '⚖️', 'unlocked': stars >= 200, 'color': Colors.indigoAccent}, // 200 ⭐
      {'name': 'Energy Balancer', 'icon': '🔮', 'unlocked': stars >= 250, 'color': Colors.greenAccent}, // 250 ⭐
    ];

    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    // Progress bar math: XP to Percentage conversion
    // .clamp(0.0, 1.0) ensures bar doesn't overflow if stars exceed 300!
    double targetProgress = (stars / 300).clamp(0.0, 1.0); 
    _progressAnimation = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic)
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  // Growth Level Name
  String _getLevelName(int stars) {
    if (stars < 100) return "🌱 Seedling";
    if (stars < 250) return "🌿 Explorer";
    return "🌳 Master";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 120), 
                
                GlassCard(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white54, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                        ),
                        child: const Text("👦", style: TextStyle(fontSize: 60)),
                      ),
                      const SizedBox(height: 15),
                      
                      Text(
                        _getLevelName(widget.currentStars),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Keep playing to grow your tree!",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      
                      const SizedBox(height: 30),

                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 25,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Container(
                                    height: 25,
                                    width: MediaQuery.of(context).size.width * 0.75 * _progressAnimation.value,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.tealAccent]),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 10)],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "⭐ ${widget.currentStars} / 300 Stars",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🏆 My Trophies",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),

                GridView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 15, 
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final badge = _badges[index];
                    bool isUnlocked = badge['unlocked'];

                    return GlassCard(
                      padding: const EdgeInsets.all(15),
                      child: Opacity(
                        opacity: isUnlocked ? 1.0 : 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnlocked ? badge['color'].withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                              ),
                              child: Text(isUnlocked ? badge['icon'] : "🔒", style: const TextStyle(fontSize: 40)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              badge['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
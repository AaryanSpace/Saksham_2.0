import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';
import '../../core/widgets/dialog_helper.dart'; // Add this import for showEntryDialog

// Import feature screens
import '../counting/counting_screen.dart';
import '../money/money_screen.dart';
import '../grocery_game/grocery_game_screen.dart';
import '../travel/travel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pre-load images to fix lag
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/money/money_5.jpg"), context);
    precacheImage(const AssetImage("assets/money/money_10.jpg"), context);
    precacheImage(const AssetImage("assets/money/money_20.jpg"), context);
    precacheImage(const AssetImage("assets/money/money_50.jpg"), context);
    precacheImage(const AssetImage("assets/money/money_100.jpg"), context);
    precacheImage(const AssetImage("assets/money/money_500.jpg"), context);
    precacheImage(const AssetImage("assets/products/rice.png"), context);
    precacheImage(const AssetImage("assets/products/milk.png"), context);
    precacheImage(const AssetImage("assets/shop/shop_bg.jpg"), context);
  }

  String selectedPeriod = "Today";

  @override
  Widget build(BuildContext context) {
    List<String> periodLabels = [
      currentLanguage == "hi-IN" ? "आज" : currentLanguage == "ne-NP" ? "आज" : "Today",
      currentLanguage == "hi-IN" ? "अभ्यास" : currentLanguage == "ne-NP" ? "अभ्यास" : "Practice",
      currentLanguage == "hi-IN" ? "प्रगति" : currentLanguage == "ne-NP" ? "प्रगति" : "Progress",
    ];

    if (!periodLabels.contains(selectedPeriod)) {
      selectedPeriod = periodLabels[0];
    }

    return Scaffold(
      body: BackgroundWrapper(
        child: Column(
          children: [
           // --- HEADER SECTION (Title + Language Button) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes items to edges
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns them to the top
                  children: [
                    // LEFT SIDE: Title and Tagline
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Saksham",
                          style: TextStyle(
                            fontSize: 31, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.cyanAccent, // Or your AppTheme.cyan
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                        currentLanguage == "hi-IN" 
                          ? "आत्मविश्वास के साथ सीखें" 
                          : currentLanguage == "ne-NP" 
                            ? "आत्मविश्वासका साथ सिक्नुहोस्" 
                            : "Learning with confidence",
                        style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    // RIGHT SIDE: Language Button
                    LanguageButton(
                      onChanged: () {
                        setState(() {}); // Refreshes the screen when language changes
                      },
                    ),
                  ],
                ),
              ),

            // --- CARDS GRID ---
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0, // Make cards slightly taller for sub-text
                  children: [
                    // CARD 1: COUNTING
                    _buildHomeCard(
                        Icons.pie_chart_rounded,
                        currentLanguage == "hi-IN" ? "नंबर मज़ा" : currentLanguage == "ne-NP" ? "नम्बर खेल" : "Number Fun",
                        // 1. HELPER TEXT
                        currentLanguage == "hi-IN" ? "संख्या चुनें और सीखें" : currentLanguage == "ne-NP" ? "अंक सिक्नुहोस्" : "Tap & learn numbers", 
                        Colors.purpleAccent, () {
                      playSound("tap.mp3");
                      String question = currentLanguage == "hi-IN" ? "क्या आप नंबरों के साथ खेलना चाहते हैं?" : currentLanguage == "ne-NP" ? "के तपाईं नम्बरहरूसँग खेल्न चाहनुहुन्छ?" : "Do you want to play with numbers?";
                      speak(question);
                      showEntryDialog(context, currentLanguage == "hi-IN" ? "नंबर मज़ा" : "Number Fun", question, const CountingScreen());
                    }),

                    // CARD 2: MONEY
                    _buildHomeCard(
                        Icons.account_balance_wallet_rounded,
                        currentLanguage == "hi-IN" ? "पैसा सीखें" : currentLanguage == "ne-NP" ? "पैसा सिकौं" : "Money Magic",
                        currentLanguage == "hi-IN" ? "पैसों का अभ्यास" : currentLanguage == "ne-NP" ? "पैसा अभ्यास" : "Practice real-life money",
                        Colors.greenAccent, () {
                      playSound("tap.mp3");
                      String question = currentLanguage == "hi-IN" ? "क्या आप पैसों के बारे में सीखना चाहते हैं?" : currentLanguage == "ne-NP" ? "के तपाईं पैसाको बारेमा सिक्न चाहनुहुन्छ?" : "Do you want to learn about money?";
                      speak(question);
                      showEntryDialog(context, currentLanguage == "hi-IN" ? "पैसा सीखें" : "Money Magic", question, const MoneyScreen());
                    }),

                    // CARD 3: MARKET
                    _buildHomeCard(
                        Icons.shopping_cart_rounded,
                        currentLanguage == "hi-IN" ? "बाज़ार खेल" : currentLanguage == "ne-NP" ? "बजार खेल" : "Market Mission",
                        currentLanguage == "hi-IN" ? "खरीदारी करना सीखें" : currentLanguage == "ne-NP" ? "किनमेल गर्न सिक्नुहोस्" : "Buy & pay smartly",
                        Colors.orangeAccent, () {
                      playSound("tap.mp3");
                      String question = currentLanguage == "hi-IN" ? "क्या आप खरीदारी के लिए जाना चाहते हैं?" : currentLanguage == "ne-NP" ? "के तपाईं किनमेल गर्न जान चाहनुहुन्छ?" : "Do you want to go shopping?";
                      speak(question);
                      showEntryDialog(context, currentLanguage == "hi-IN" ? "बाज़ार खेल" : "Market Mission", question, GroceryGameScreen(language: currentLanguage));
                    }),

                    // CARD 4: GAME ZONE (Combined Travel + Ninja)
                    _buildHomeCard(
                        Icons.sports_esports_rounded, // Changed Icon to Joystick/Game
                        currentLanguage == "hi-IN" ? "खेल क्षेत्र" : currentLanguage == "ne-NP" ? "खेल क्षेत्र" : "Game Zone",
                        currentLanguage == "hi-IN" ? "मज़े करो और सीखो" : currentLanguage == "ne-NP" ? "रमाइलो र सिक्नुहोस्" : "Play & Learn Math",
                        Colors.cyanAccent, () {
                      playSound("tap.mp3");
                      String question = currentLanguage == "hi-IN" ? "क्या आप गेम खेलना चाहते हैं?" : currentLanguage == "ne-NP" ? "के तपाईं खेल खेल्न चाहनुहुन्छ?" : "Do you want to play a game?";
                      speak(question);
                      // Navigate to the NEW Game Selection Screen (TravelScreen will now be a menu)
                      showEntryDialog(context, "Game Zone", question, const TravelScreen());
                    }),
                  ],
                ),
              ),
            ),

            // --- STATS PLATE ---
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
                ),
                child: Column(
                  children: [
                    // 2. GLOWING TAB SELECTOR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: periodLabels.map((period) {
                        final bool isSelected = selectedPeriod == period;
                        return GestureDetector(
                          onTap: () => setState(() => selectedPeriod = period),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentCyan : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              // GLOW EFFECT
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: AppTheme.accentCyan.withOpacity(0.6),
                                          blurRadius: 15,
                                          spreadRadius: 1)
                                    ]
                                  : [],
                            ),
                            child: Text(
                              period,
                              style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Spacer(),
                    
                    // STATS DISPLAY (Same as before)
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value: (PlayerStats.xp % 100) / 100,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentPink),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("LVL", style: TextStyle(fontSize: 10, color: Colors.white54)),
                                  Text("${PlayerStats.level}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMiniStat(
                                  currentLanguage == "hi-IN" ? "सीखा हुआ" : currentLanguage == "ne-NP" ? "सिकाइ" : "Learning Points",
                                  "${PlayerStats.xp}",
                                  AppTheme.accentYellow,
                                  (PlayerStats.xp % 1000) / 1000),
                              const SizedBox(height: 15),
                              _buildMiniStat(
                                  currentLanguage == "hi-IN" ? "किए गए काम" : currentLanguage == "ne-NP" ? "गरिएका काम" : "Activities Done",
                                  "${PlayerStats.tasksCompleted}",
                                  AppTheme.accentGreen,
                                  (PlayerStats.tasksCompleted % 50) / 50),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildHomeCard(IconData icon, String label, String subLabel, Color glowColor, VoidCallback onTap) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: glowColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: glowColor.withValues(alpha: 0.4), blurRadius: 15)
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.white), // Slightly bigger icon too
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            // UPDATED FONT SIZE: 16 -> 20
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            textAlign: TextAlign.center,
            // UPDATED FONT SIZE: 10 -> 13
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        )
      ],
    );
  }
}
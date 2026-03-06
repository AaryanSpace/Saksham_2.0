import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Aapke core imports
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class NumberBalanceScreen extends StatefulWidget {
  const NumberBalanceScreen({super.key});

  @override
  State<NumberBalanceScreen> createState() => _NumberBalanceScreenState();
}

class _NumberBalanceScreenState extends State<NumberBalanceScreen> with TickerProviderStateMixin {
  // --- GAME VARIABLES ---
  int _score = 0;
  final Random _random = Random();
  
  // Wazan (Weight) ki variables
  int _targetWeight = 10; // Left side ka total wazan
  int _givenWeight = 6;   // Right side par pehle se rakha wazan
  int _addedWeight = 0;   // User dwara rakha gaya naya wazan
  
  List<int> _options = []; // Niche dikhne wale 4 options
  bool _isTransitioning = false; // Taps block karne ke liye lock
  bool _showTutorial = true; // 🔥 NAYA: Pehli baar tutorial (finger) dikhane ke liye

  // --- CANDY CRUSH FEEDBACK ANIMATION VARIABLES ---
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScaleAnimation;
  String _feedbackText = "";
  Color _feedbackColor = Colors.white;

  String _questionText = "Balance the Scale!";

  @override
  void initState() {
    super.initState();
    // Animation Controller Setup
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _feedbackScaleAnimation = CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut);
    
    _startNewRound();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // --- LANGUAGE LOGIC ---
  void _updateLanguageText() {
    setState(() {
      if (currentLanguage == 'hi-IN') {
        _questionText = "तराजू को संतुलित करें!";
      } else if (currentLanguage == 'ne-NP') {
        _questionText = "तराजु सन्तुलन गर्नुहोस्!";
      } else {
        _questionText = "Balance the Scale!";
      }
    });
    speak(_questionText);
  }

  // --- NEW ROUND LOGIC ---
  void _startNewRound() {
    setState(() {
      _isTransitioning = false;
      _addedWeight = 0; // Taraazu par rakha gaya user ka wazan zero kar do
      
      // 1. Target wazan set karo (Jaise 5 se 15 ke beech)
      _targetWeight = 5 + _random.nextInt(11); 
      
      // 2. Ek chhota wazan right side par pehle se rakh do
      _givenWeight = 1 + _random.nextInt(_targetWeight - 1); 
      
      // 3. Sahi jawab (Missing weight) calculate karo
      int correctOption = _targetWeight - _givenWeight;

      // 4. 4 Options generate karo jisme 1 sahi aur 3 galat hon
      _options.clear();
      _options.add(correctOption);
      while (_options.length < 4) {
        int wrongOption = 1 + _random.nextInt(10);
        if (!_options.contains(wrongOption)) {
          _options.add(wrongOption);
        }
      }
      _options.shuffle(); // Options ko mix kar do
    });
    
    _updateLanguageText();
  }

  // --- TAP LOGIC (JAB USER KISI OPTION PAR CLICK KARE) ---
  void _handleOptionTap(int selectedWeight) {
    if (_isTransitioning) return;

    setState(() {
      _showTutorial = false; // 🔥 NAYA: Jaise hi user tap kare, tutorial hata do
      _addedWeight = selectedWeight; // User ka select kiya wazan taraazu par rakho
    });

    // Check karo kya dono taraf ka wazan barabar ho gaya?
    if (_givenWeight + _addedWeight == _targetWeight) {
      // ✅ SAHI JAWAB (BALANCED)
      playSound("success.mp3");
      _triggerWinFeedback();
      PlayerStats.addXP(5);
      
      setState(() {
        _isTransitioning = true;
        _score += 5;
      });

      // 2 Second baad naya round start
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) _startNewRound();
      });

    } else {
      // ❌ GALAT JAWAB (UNBALANCED)
      playSound("tap.mp3");
      _triggerWrongFeedback();
      setState(() => _isTransitioning = true);

      // 1.5 Second baad galat wazan ko taraazu se hata do
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _addedWeight = 0;
            _isTransitioning = false;
          });
        }
      });
    }
  }

  // --- CANDY CRUSH STYLE POP-UP LOGIC ---
  void _triggerWinFeedback() {
    List<String> words = ["Balanced!", "Awesome!", "Perfect!"];
    if (currentLanguage == 'hi-IN') words = ["बिल्कुल सही!", "शानदार!"];
    if (currentLanguage == 'ne-NP') words = ["सन्तुलित!", "धेरै राम्रो!"];

    setState(() {
      _feedbackText = words[_random.nextInt(words.length)];
      _feedbackColor = Colors.greenAccent;
    });
    speak(_feedbackText);
    _feedbackController.reset();
    _feedbackController.forward();
  }

  void _triggerWrongFeedback() {
    List<String> words = [
  "Almost! Let's try again.",
  "Not balanced yet.",
  "Oops!", "Try again!"];
    if (currentLanguage == 'hi-IN') words = ["ओह! गलत वज़न", "फिर कोशिश करें!"];
    if (currentLanguage == 'ne-NP') words = ["ओहो! गलत तौल", "फेरी प्रयास गर्नुहोस्!"];

    setState(() {
      _feedbackText = words[_random.nextInt(words.length)];
      _feedbackColor = Colors.redAccent;
    });
    speak(_feedbackText);
    _feedbackController.reset();
    _feedbackController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 THE PHYSICS ENGINE (Math Logic) 🔥
    // Taraazu kitna jhukega? Ye depend karta hai dono taraf ke wazan ke difference par.
    double rightTotal = (_givenWeight + _addedWeight).toDouble();
    double leftTotal = _targetWeight.toDouble();
    
    // Agar Right bhari hai to +, Left bhari hai to - (Turns mein calculation)
    // Multiplied by 0.01 taaki rotation smooth aur realistic ho (jyada palte na)
    double tiltAngle = (rightTotal - leftTotal) * 0.015;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.yellow, size: 20),
              const SizedBox(width: 8),
              Text("$_score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
        actions: [LanguageButton(onChanged: () => _updateLanguageText())],
      ),
      body: BackgroundWrapper(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                
                // QUESTION CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                    ),
                  ),
                ),
                
                const Spacer(),

                // ⚖️ THE ANIMATED SEE-SAW (TARAAZU) ⚖️
                SizedBox(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // 1. Fulcrum (Taraazu ka base/stand)
                      CustomPaint(
                        size: const Size(60, 80),
                        painter: FulcrumPainter(),
                      ),
                      
                      // 2. The Plank (Jhukne wala lakkad)
                      Positioned(
                        bottom: 80, // Stand ke bilkul upar
                        child: AnimatedRotation(
                          turns: tiltAngle, // Physics math se jhukega
                          duration: const Duration(milliseconds: 600), // Smooth animation
                          curve: Curves.easeOutBack, // Thoda bounce effect aayega
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Lakkad ki patti (Wood plank)
                              Container(
                                width: 300,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.brown.shade700, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 5))],
                                ),
                              ),
                              
                              // 🔥 NAYA: LEFT SIDE BOX (Target Weight - Seb ki Bori)
                              Positioned(
                                left: 10,
                                bottom: 16,
                                child: _buildWeightBox(_targetWeight, Colors.redAccent, icon: "🍎"),
                              ),

                              // 🔥 NAYA: RIGHT SIDE BOXES (Given + Added)
                              Positioned(
                                right: 10,
                                bottom: 16,
                                child: Row(
                                  children: [
                                    if (_addedWeight > 0) ...[
                                      // User ka rakha hua wazan
                                      _buildWeightBox(_addedWeight, Colors.blueGrey, icon: "⚖️"),
                                      const SizedBox(width: 5),
                                    ],
                                    // Pehle se rakhi hui chhoti bori
                                    _buildWeightBox(_givenWeight, Colors.green.shade600, icon: "🍏"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🔢 OPTIONS (Dabbe jo user uthayega)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _options.map((option) {
                          return GestureDetector(
                            onTap: () => _handleOptionTap(option),
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              child: Column(
                                children: [
                                  const Text("⚖️", style: TextStyle(fontSize: 24)),
                                  Text(
                                    "${getLocalizedNumber(option)} kg", // 🔥 NAYA: kg add kiya hai
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // 🔥 NAYA: TUTORIAL ANIMATION (Bouncing Finger)
                      if (_showTutorial)
                        const Positioned(
                          top: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text("👇", style: TextStyle(fontSize: 40)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // 🔥 CANDY CRUSH POP-UP FEEDBACK
            Center(
              child: IgnorePointer(
                child: ScaleTransition(
                  scale: _feedbackScaleAnimation,
                  child: FadeTransition(
                    opacity: _feedbackController.drive(Tween(begin: 3.0, end: 0.0)),
                    child: Text(
                      _feedbackText,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: _feedbackColor,
                        shadows: const [Shadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 5)],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 NAYA: Box banane ka chhota function ab icon aur "kg" dono handle karega
  Widget _buildWeightBox(int weight, Color color, {String? icon}) {
    return Container(
      width: 75, // Bada kiya taaki emoji aur text sahi se fit aa jaye
      height: 75,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Text(icon, style: const TextStyle(fontSize: 20)),
          Text(
            "${getLocalizedNumber(weight)} kg", // Ab numbers ke sath 'kg' likha aayega
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// --- TARAAZU KA STAND (Fulcrum Painter) ---
// ==========================================
class FulcrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Stand ka triangle shape
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.width / 2, 0) // Top center
      ..lineTo(0, size.height)    // Bottom left
      ..lineTo(size.width, size.height) // Bottom right
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    // Upar ka chhota sa gol pahiya (Jahan patti ghumti hai)
    canvas.drawCircle(Offset(size.width / 2, 0), 8, Paint()..color = Colors.amber);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
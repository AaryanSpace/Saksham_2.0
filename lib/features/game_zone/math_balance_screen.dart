import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class MathBalanceScreen extends StatefulWidget {
  const MathBalanceScreen({super.key});

  @override
  State<MathBalanceScreen> createState() => _MathBalanceScreenState();
}

class _MathBalanceScreenState extends State<MathBalanceScreen> with TickerProviderStateMixin {
  int _score = 0;
  final Random _random = Random();
  
  // Game Variables
  int _targetWeight = 10; 
  int _givenWeight = 6;   
  int _addedWeight = 0;   
  
  List<int> _options = []; 
  bool _isTransitioning = false; 
  bool _showTutorial = true; 

  // Feedback Animation
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScaleAnimation;
  String _feedbackText = "";
  Color _feedbackColor = Colors.white;

  String _questionText = "Balance the Energy!";

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _feedbackScaleAnimation = CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut);
    _startNewRound();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateLanguageText() {
    setState(() {
      if (currentLanguage == 'hi-IN') {
        _questionText = "ऊर्जा को संतुलित करें!";
      } else if (currentLanguage == 'ne-NP') {
        _questionText = "ऊर्जा सन्तुलन गर्नुहोस्!";
      } else {
        _questionText = "Balance the Energy!";
      }
    });
    speak(_questionText);
  }

  void _startNewRound() {
    setState(() {
      _isTransitioning = false;
      _addedWeight = 0; 
      
      _targetWeight = 5 + _random.nextInt(11); 
      _givenWeight = 1 + _random.nextInt(_targetWeight - 1); 
      
      int correctOption = _targetWeight - _givenWeight;

      _options.clear();
      _options.add(correctOption);
      
      // 🔥 CHANGE 1: Options ki ginti 4 se ghata kar 3 kar di hai
      while (_options.length < 3) {
        int wrongOption = 1 + _random.nextInt(10);
        if (!_options.contains(wrongOption)) {
          _options.add(wrongOption);
        }
      }
      _options.shuffle(); 
    });
    _updateLanguageText();
  }

  void _handleOptionTap(int selectedWeight) {
    if (_isTransitioning) return;

    setState(() {
      _showTutorial = false; 
      _addedWeight = selectedWeight; 
    });

    if (_givenWeight + _addedWeight == _targetWeight) {
      // ✅ SUCCESS
      playSound("success.mp3");
      _triggerWinFeedback();
      PlayerStats.addXP(15);
      
      setState(() {
        _isTransitioning = true;
        _score += 15;
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) _startNewRound();
      });

    } else {
      // ❌ FAIL
      playSound("tap.mp3");
      _triggerWrongFeedback();
      setState(() => _isTransitioning = true);

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

  void _triggerWinFeedback() {
    List<String> words = ["Balanced!", "Awesome!", "Perfect!"];
    if (currentLanguage == 'hi-IN') words = ["बिल्कुल सही!", "शानदार!"];
    if (currentLanguage == 'ne-NP') words = ["सन्तुलित!", "धेरै राम्रो!"];

    setState(() {
      _feedbackText = words[_random.nextInt(words.length)];
      _feedbackColor = Colors.cyanAccent; // Neon Blue win color
    });
    speak(_feedbackText);
    _feedbackController.reset();
    _feedbackController.forward();
  }

  void _triggerWrongFeedback() {
    List<String> words = ["Almost!", "Try again!", "Oops!"];
    if (currentLanguage == 'hi-IN') words = ["ओह! गलत ऊर्जा", "फिर कोशिश करें!"];
    if (currentLanguage == 'ne-NP') words = ["ओहो! गलत ऊर्जा", "फेरी प्रयास गर्नुहोस्!"];

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
    // 🔥 THE PHYSICS ENGINE 🔥
    double rightTotal = (_givenWeight + _addedWeight).toDouble();
    double leftTotal = _targetWeight.toDouble();

   // Tilt angle directly mapped to weight difference
    double tiltAngle = (rightTotal - leftTotal) * 0.012;

    bool isBalanced = (_givenWeight + _addedWeight == _targetWeight) && _isTransitioning;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyan.shade900.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.yellow, size: 24),
              const SizedBox(width: 8),
              Text("$_score", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
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
                // 🔥 CHANGE 2: Top spacing kam kar di (100 se 85) taaki Question Box thoda upar jaye
                const SizedBox(height: 20),
                
                // Question Box
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                    ),
                  ),
                ),
                
                SizedBox(height: 20), // 🔥 Ye Spacer Taraazu ko center mein pull karega

                // ⚖️ NEON SCALE (TARAAZU) ⚖️
                SizedBox(
                  height: 380, 
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // 1. Sleek Neon Stand
                      CustomPaint(
                        size: const Size(90, 140),
                        painter: NeonFulcrumPainter(isBalanced: isBalanced),
                      ),
                      
                      // 2. The Glowing Beam (Plank)
                      Positioned(
                        bottom: 135, 
                        child: AnimatedRotation(
                          turns: tiltAngle, 
                          duration: const Duration(milliseconds: 700), 
                          // Gives that real-world bouncing effect
                          curve: Curves.elasticOut, 
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 340, 
                                height: 12, 
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isBalanced ? Colors.greenAccent : Colors.cyanAccent, 
                                      blurRadius: 15, 
                                      spreadRadius: 2
                                    )
                                  ],
                                ),
                              ),
                              
                              Positioned(
                                left: 5,
                                bottom: 10,
                                child: _buildEnergyOrb(_targetWeight, isBalanced ? Colors.greenAccent : Colors.purpleAccent, size: 100),
                              ),

                              Positioned(
                                right: 5,
                                bottom: 10, 
                                child: isBalanced 
                                  ? _buildEnergyOrb(_targetWeight, Colors.greenAccent, size: 100)
                                  : Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (_addedWeight > 0) ...[
                                          _buildEnergyOrb(_addedWeight, Colors.orangeAccent, size: 80),
                                          const SizedBox(width: 5),
                                        ],
                                        _buildEnergyOrb(_givenWeight, Colors.blueAccent, size: 80),
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

                SizedBox(height: 80), // 🔥 Ye Spacer options ko perfect distance par push karega

                // 🔢 OPTIONS (Energy Cores)
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
                            // 🔥 CHANGE 3: Option ka size 75 se 95 kar diya gaya hai (Bada Size)
                            child: _buildEnergyOrb(option, Colors.orangeAccent.withOpacity(0.8), size: 90),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🔥 CHANGE 4: CANDY CRUSH POP-UP FEEDBACK KI POSITION CHANGE
            // Isko Center se hata kar Positioned mein daala gaya hai Question Box ke theek niche.
            Positioned(
              top: 150, // Question Box ke niche aur Taraazu ke upar ki jagah
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ScaleTransition(
                  scale: _feedbackScaleAnimation,
                  child: FadeTransition(
                    opacity: _feedbackController.drive(Tween(begin: 3.0, end: 0.0)),
                    child: Text(
                      _feedbackText,
                      style: TextStyle(
                        fontSize: 50, // Text size slightly adjust for better fit
                        fontWeight: FontWeight.w900,
                        color: _feedbackColor,
                        shadows: [Shadow(color: _feedbackColor.withOpacity(0.5), blurRadius: 20)],
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

  // 🔥 THE ENERGY ORB 🔥
  Widget _buildEnergyOrb(int weight, Color glowColor, {required double size}) {
    return Container(
      width: size, 
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white, glowColor, glowColor.withOpacity(0.5)],
          stops: const [0.1, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: glowColor.withOpacity(0.8), blurRadius: 15, spreadRadius: 2),
          BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 5, spreadRadius: 1), 
        ],
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Center(
        child: Text(
          getLocalizedNumber(weight), 
          style: TextStyle(
            fontSize: size * 0.45, 
            fontWeight: FontWeight.w900, 
            color: Colors.black87, 
          ), 
        ),
      ),
    );
  }
}

// ==========================================
// --- NEON STAND (Sleek Sci-Fi Fulcrum) ---
// ==========================================
class NeonFulcrumPainter extends CustomPainter {
  final bool isBalanced;
  NeonFulcrumPainter({required this.isBalanced});

  @override
  void paint(Canvas canvas, Size size) {
    Color glowColor = isBalanced ? Colors.greenAccent : Colors.cyanAccent;

    final paint = Paint()
      ..color = Colors.black87 
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path()
      ..moveTo(size.width / 2, 0) 
      ..lineTo(20, size.height)    
      ..lineTo(size.width - 20, size.height) 
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    
    canvas.drawCircle(Offset(size.width / 2, 0), 10, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width / 2, 0), 14, Paint()..color = glowColor..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant NeonFulcrumPainter oldDelegate) {
    return oldDelegate.isBalanced != isBalanced; 
  }
}
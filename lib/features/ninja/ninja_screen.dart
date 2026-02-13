import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class NinjaScreen extends StatefulWidget {
  const NinjaScreen({super.key});

  @override
  State<NinjaScreen> createState() => _NinjaScreenState();
}

class _NinjaScreenState extends State<NinjaScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  
  // Game Loop Controllers
  late AnimationController _controller;
  
  // --- CANDY CRUSH STYLE FEEDBACK ---
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScaleAnimation;
  String _feedbackText = "";
  Color _feedbackColor = Colors.white;
  // ----------------------------------

  int _score = 0;
  String _questionText = "";
  String _visualHint = "";
  dynamic _correctAnswer;
  bool _isMoneyRound = false;

  List<GameItem> _items = [];
  Timer? _spawnTimer;
  Timer? _loopTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    
    // Initialize Feedback Animation (Pop effect)
    _feedbackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _feedbackScaleAnimation = CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut);

    _startNewRound();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) => _spawnItem());
    _loopTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) => _updateItems());
  }

  @override
  void dispose() {
    _controller.dispose();
    _feedbackController.dispose();
    _spawnTimer?.cancel();
    _loopTimer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _items.clear();
      // 30% Money, 70% Math
      if (_random.nextDouble() < 0.3) {
        _setupMoneyRound();
      } else {
        _setupMathRound();
      }
    });
  }

  // --- LOGIC: NATURAL SPEAKING MATH ---
  void _setupMathRound() {
    _isMoneyRound = false;
    int a = _random.nextInt(10) + 1; // 1 to 10
    int b = _random.nextInt(5) + 1;  // 1 to 5
    bool isPlus = _random.nextBool();

    String speakText = "";
    
    // Get Localized Digits (e.g., 5 -> ५) for Display AND Speech context
    String aLoc = getLocalizedNumber(a);
    String bLoc = getLocalizedNumber(b);

    if (isPlus) {
      _correctAnswer = a + b;
      _questionText = "$aLoc + $bLoc = ?";
      _visualHint = "${'•' * a} + ${'•' * b}";

      // --- NATURAL SPEECH GENERATION ---
      if (currentLanguage == 'hi-IN') {
        // "10 mein 5 jodne par kya aayega?"
        speakText = "$aLoc में $bLoc जोड़ने पर क्या आएगा?"; 
      } else if (currentLanguage == 'ne-NP') {
        // "10 ma 5 jodda natija ke huncha?"
        speakText = "$aLoc मा $bLoc जोड्दा नतिजा के हुन्छ?";
      } else {
        speakText = "$a plus $b equals what?";
      }

    } else {
      // Subtraction: Ensure result is positive
      if (a < b) { int temp = a; a = b; b = temp; aLoc = getLocalizedNumber(a); bLoc = getLocalizedNumber(b); }
      
      _correctAnswer = a - b;
      _questionText = "$aLoc - $bLoc = ?";
      _visualHint = "${'•' * a} - ${'•' * b}";

      // --- NATURAL SPEECH GENERATION ---
      if (currentLanguage == 'hi-IN') {
        // "10 mein se 5 ghatane par kya aayega?"
        speakText = "$aLoc में से $bLoc घटाने पर क्या आएगा?";
      } else if (currentLanguage == 'ne-NP') {
        // "10 bata 5 ghatauda natija ke huncha?"
        speakText = "$aLoc बाट $bLoc घटाउँदा नतिजा के हुन्छ?";
      } else {
        speakText = "$a minus $b equals what?";
      }
    }

    speak(speakText);
  }

  void _setupMoneyRound() {
    _isMoneyRound = true;
    List<int> notes = [10, 20, 50, 100];
    int val = notes[_random.nextInt(notes.length)];
    _correctAnswer = val;
    
    String valStr = getLocalizedNumber(val);
    String speakText = "";

    if (currentLanguage == "hi-IN") {
       _questionText = "₹$valStr का नोट";
       speakText = "$valStr रुपये का नोट ढूँढें"; // Using Devanagari numbers ensures "Das" not "One Zero"
    } else if (currentLanguage == "ne-NP") {
       _questionText = "₹$valStr को नोट";
       speakText = "$valStr रुपैयाँको नोट खोज्नुहोस्";
    } else {
       _questionText = "Find ₹$valStr";
       speakText = "Find $val rupees note";
    }
    _visualHint = "Tap the money!";
    
    speak(speakText);
  }

  void _spawnItem() {
    if (!mounted) return;
    bool isCorrect = _random.nextDouble() < 0.4;
    dynamic value;

    if (isCorrect) {
      value = _correctAnswer;
    } else {
      if (_isMoneyRound) {
        List<int> notes = [10, 20, 50, 100];
        value = notes[_random.nextInt(notes.length)];
        if (value == _correctAnswer) value = (value == 10) ? 20 : 10;
      } else {
        value = _random.nextInt(10);
        if (value == _correctAnswer) value = value + 1;
      }
    }

    setState(() {
      _items.add(GameItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        value: value,
        x: _random.nextDouble() * 0.8 + 0.1,
        y: 1.1,
        speed: _random.nextDouble() * 0.005 + 0.005,
        isCorrect: isCorrect,
        isMoney: _isMoneyRound,
      ));
    });
  }

  void _updateItems() {
    setState(() {
      for (var item in _items) {
        item.y -= item.speed;
      }
      _items.removeWhere((item) => item.y < -0.2);
    });
  }

  // --- CANDY CRUSH ANIMATION TRIGGER ---
  void _triggerWinFeedback() {
    List<String> words;
    if (currentLanguage == 'hi-IN') {
      words = ["बहुत बढ़िया!", "शानदार!", "सही जवाब!"];
    } else if (currentLanguage == 'ne-NP') {
      words = ["धेरै राम्रो!", "बबाल!", "सही हो!"];
    } else {
      words = ["Awesome!", "Perfect!", "Great Job!"];
    }
    
    setState(() {
      _feedbackText = words[_random.nextInt(words.length)];
      _feedbackColor = [Colors.yellowAccent, Colors.greenAccent, Colors.cyanAccent, Colors.orangeAccent][_random.nextInt(4)];
    });
    
    _feedbackController.reset();
    _feedbackController.forward();
  }

  void _handleTap(GameItem item) {
    if (item.isCorrect) {
      // 1. SUCCESS LOGIC
      playSound("success.mp3");
      PlayerStats.addXP(10);
      _triggerWinFeedback(); // Show the big text!
      
      setState(() {
        _score += 10;
        _items.remove(item);
      });
      _startNewRound();
    } else {
      // 2. WRONG ANSWER LOGIC
      playSound("tap.mp3");
      
      String wrongText = "";
      if (currentLanguage == 'hi-IN') {
        wrongText = "गलत जवाब, फिर से कोशिश करें";
      } else if (currentLanguage == 'ne-NP') {
        wrongText = "गलत हो, फेरी प्रयास गर्नुहोस्";
      } else {
        wrongText = "Wrong answer, try again";
      }
      speak(wrongText);

      setState(() {
        item.isShaking = true;
      });
    }
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
        // 1. MOVED SCORE TO LEFT (centerTitle: false)
        centerTitle: false, 
        titleSpacing: 0, // Removes extra gap between back arrow and score
        
        // --- SCORE CONTAINER ---
        title: Container(
          margin: const EdgeInsets.only(left: 0), // Little space from arrow
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade700, 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30, width: 1.5),
            boxShadow: [
              const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Icon(Icons.star_rounded, color: Colors.yellow, size: 20),
              const SizedBox(width: 8),
              Text(
                "$_score", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
              ),
            ],
          ),
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LanguageButton(onChanged: () => setState(() { _startNewRound(); })),
          )
        ],
      ),
      body: BackgroundWrapper(
        child: Stack(
          children: [
            // 1. FLOATING ITEMS
            ..._items.map((item) {
              return Positioned(
                left: MediaQuery.of(context).size.width * item.x,
                top: MediaQuery.of(context).size.height * item.y,
                child: GestureDetector(
                  onTap: () => _handleTap(item),
                  child: item.isMoney
                    // Money Image (No Container)
                    ? SizedBox(
                        height: 260,
                        child: Image.asset(
                          "assets/money/money_${item.value}.jpg",
                          fit: BoxFit.contain,
                        ),
                      )
                    // Number Bubble
                    : Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          color: item.isShaking ? Colors.redAccent : AppTheme.accentCyan.withOpacity(0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 1),
                          boxShadow: [
                            BoxShadow(color: AppTheme.accentCyan.withOpacity(0.6), blurRadius: 8)
                          ]
                        ),
                        child: Center(
                          child: Text(
                            getLocalizedNumber(item.value),
                            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 33, 35, 82)),
                          ),
                        ),
                      ),
                ),
              );
            }).toList(),

// 2. QUESTION CARD (MOVED TO TOP & CONSTANT STYLE)
            Align(
              alignment: Alignment.topCenter, // <--- 1. MOVED TO TOP
              child: Container(
                // 2. Adjust margins to sit nicely below the AppBar (Score/Back button)
                margin: const EdgeInsets.only(top: 0, left: 14, right: 14), 
                height: 130, // <--- 3. FIXED HEIGHT (Constant size)
                width: double.infinity, // Fills width minus margins
                child: GlassCard(
                  child: Column(  
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // THE QUESTION TEXT (e.g., "2 + 2 = ?")
                      Text(
                        _questionText,
                        style: const TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.w900, // Extra Bold
                          color: Colors.white,
                          letterSpacing: 1.2
                        ),
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // THE HINT BOX (Black Pill Shape)
                      // Now applies to BOTH Math and Money rounds for consistency
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3), // Dark transparent bg
                          borderRadius: BorderRadius.circular(30), // Rounded pill shape
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Text(
                          // Show Dots if math, "Tap Note" if money
                          _isMoneyRound 
                              ? (currentLanguage == "en-US" ? "Tap the note!" : (currentLanguage == "hi-IN" ? "नोट दबाएं!" : "नोट थिच्नुहोस्!"))
                              : _visualHint,
                          style: TextStyle(
                            fontSize: _isMoneyRound ? 18 : 24, // Text size adjustment
                            color: _isMoneyRound ? Colors.white70 : AppTheme.accentYellow,
                            fontWeight: FontWeight.bold,
                            letterSpacing: _isMoneyRound ? 1 : 10, // Spacing for dots
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. BIG CONGRATULATIONS TEXT (Candy Crush Style)
            Center(
              child: ScaleTransition(
                scale: _feedbackScaleAnimation,
                child: FadeTransition(
                  opacity: _feedbackController.drive(Tween(begin: 3.0, end: 0.0)),
                  child: Text(
                    _feedbackText,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _feedbackColor,
                      shadows: [
                        const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                        Shadow(color: _feedbackColor.withOpacity(0.5), blurRadius: 20),
                      ],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameItem {
  String id;
  dynamic value;
  double x;
  double y;
  double speed;
  bool isCorrect;
  bool isMoney;
  bool isShaking;

  GameItem({
    required this.id, required this.value, required this.x, required this.y, required this.speed, required this.isCorrect, required this.isMoney, this.isShaking = false,
  });
}
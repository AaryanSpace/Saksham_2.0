import 'dart:math';
import 'dart:ui'; // Required for Glass Effect

import 'package:flutter/material.dart';

import '../../core/utils/globals.dart';

class GroceryGameScreen extends StatefulWidget {
  final String language;

  const GroceryGameScreen({super.key, required this.language});

  @override
  State<GroceryGameScreen> createState() => _GroceryGameScreenState();
}

class _GroceryGameScreenState extends State<GroceryGameScreen>
    with TickerProviderStateMixin {
  final Random random = Random();
  bool _isFirstRun = true;

  final List<int> availableNotes = [5, 10, 20, 50, 100, 500];

  final List<Map<String, dynamic>> products = [
    {"image": "assets/products/rice.png", "name": "Rice", "name_hi": "चावल", "name_ne": "चामल"},
    {"image": "assets/products/biscuit.png", "name": "Biscuit", "name_hi": "बिस्कुट", "name_ne": "बिस्कुट"},
    {"image": "assets/products/milk.png", "name": "Milk", "name_hi": "दूध", "name_ne": "दूध"},
    {"image": "assets/products/soap.png", "name": "Soap", "name_hi": "साबुन", "name_ne": "साबुन"},
    {"image": "assets/products/chips.png", "name": "Chips", "name_hi": "चिप्स", "name_ne": "चिप्स"},
    {"image": "assets/products/bread.png", "name": "Bread", "name_hi": "ब्रेड", "name_ne": "ब्रेड"},
    {"image": "assets/products/egg.png", "name": "Eggs", "name_hi": "अंडे", "name_ne": "अण्डा" },
    {"image": "assets/products/banana.png", "name": "Banana", "name_hi": "केला", "name_ne": "केरा"},
  ];

  late Map<String, dynamic> currentProduct;
  int currentPrice = 0;
  int currentMoneyGiven = 0;
  List<int> notesOnCounter = [];

  int score = 0;
  int level = 1;
  int correctInRow = 0;
  List<Widget> flyingMoneyWidgets = [];
  bool _isAnimating = false; // Add this variable to lock taps during animation

  @override
  void initState() {
    super.initState();
    // No language check needed here, it uses global currentLanguage
    _nextProduct();
  }

  void _generatePriceForLevel() {
    List<int> possiblePrices = [];
    if (level == 1) {
      possiblePrices = availableNotes;
    } else if (level == 2) {
      for (int a in availableNotes) {
        for (int b in availableNotes) {
          int sum = a + b;
          if (sum <= 200) possiblePrices.add(sum);
        }
      }
    } else {
      for (int a in availableNotes) {
        for (int b in availableNotes) {
          for (int c in availableNotes) {
            int sum = a + b + c;
            if (sum <= 500) possiblePrices.add(sum);
          }
        }
      }
    }
    
    if (possiblePrices.isNotEmpty) {
      currentPrice = possiblePrices[random.nextInt(possiblePrices.length)];
    } else {
      currentPrice = 10;
    }
  }

  void _nextProduct() {
    setState(() {
      currentProduct = products[random.nextInt(products.length)];
      _generatePriceForLevel();
      currentMoneyGiven = 0;
      notesOnCounter.clear();
    });

    if (_isFirstRun) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _speakPrice();
          setState(() => _isFirstRun = false);
        }
      });
    } else {
      _speakPrice();
    }
  }

  void _changeLevel(int newLevel) {
    setState(() { level = newLevel; correctInRow = 0; });
    _nextProduct();
  }

void _triggerFlyAnimation(int amount) {
    // 1. STOP if already animating (Prevents rapid tapping)
    if (_isAnimating) return;

    // 2. CHECK if max notes reached
    int maxNotesAllowed = level; 
    if (notesOnCounter.length >= maxNotesAllowed) {
      String warning = "";
      if (currentLanguage == "hi-IN") {
        warning = "केवल $maxNotesAllowed नोट का उपयोग करें!";
      } else if (currentLanguage == "ne-NP") {
        warning = "$maxNotesAllowed नोट मात्र प्रयोग गर्नुहोस्!";
      } else {
        warning = "Only $maxNotesAllowed notes allowed!";
      }

      speak(warning); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(warning, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.orange,
        duration: const Duration(milliseconds: 1000), // Shortened duration
      ));
      return;
    }

    // 3. LOCK taps
    setState(() {
      _isAnimating = true; 
    });

    playSound("coin.mp3");
    Key key = UniqueKey();

    setState(() {
      flyingMoneyWidgets.add(
        Positioned(
          key: key,
          bottom: 50,
          left: MediaQuery.of(context).size.width / 2 - 70, 
          child: TweenAnimationBuilder(
            tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -350)), 
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, Offset offset, child) {
              return Transform.translate(
                offset: offset,
                child: Opacity(
                  opacity: 1.0 - (offset.dy / -400).abs().clamp(0.0, 1.0),
                  child: Image.asset("assets/money/money_$amount.jpg", width: 140),
                ),
              );
            },
            onEnd: () {
              setState(() {
                flyingMoneyWidgets.removeWhere((w) => w.key == key);
                currentMoneyGiven += amount;
                notesOnCounter.add(amount);
                
                _isAnimating = false; // 4. UNLOCK taps when animation finishes
              });
            },
          ),
        ),
      );
    });
  }

  void _confirmPayment() {
    if (currentMoneyGiven == 0) {
      _speakText("Please put money first");
      return;
    }

    if (notesOnCounter.length != level) {
      String msg = "";
      if (currentLanguage == "hi-IN") {
        msg = "कृपया $level नोटों का उपयोग करें";
      } else if (currentLanguage == "ne-NP") {
        msg = "कृपया $level नोटहरू प्रयोग गर्नुहोस्";
      } else {
        msg = "Please use $level notes";
      }
      
      speak(msg);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    if (currentMoneyGiven < currentPrice) {
      _speakText("Not enough money");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough money!", style: TextStyle(fontSize: 16)), backgroundColor: Colors.red)
      );
      return;
    }
    
    playSound("success.mp3");
    _handleWin(currentMoneyGiven - currentPrice);
  }

  void _speakText(String enText) async {
    String text = enText;
    if (currentLanguage == 'hi-IN') {
      if (enText.contains("Not enough")) text = "पैसे कम हैं";
      if (enText.contains("Please put")) text = "कृपया पैसे रखें";
    } else if (currentLanguage == 'ne-NP') {
      if (enText.contains("Not enough")) text = "पैसा पुगेन";
      if (enText.contains("Please put")) text = "कृपया पैसा राख्नुहोस्";
    }
    speak(text);
  }

  void _handleWin(int change) {
    setState(() {
      score += 10;
      correctInRow++;
      if (correctInRow >= 5 && level < 3) {
        level++;
        correctInRow = 0;
        _showLevelUpDialog();
        return;
      }
    });
    _showResult(true, change);
  }

void _showLevelUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparent for Glass Effect
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass Blur
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // MATCHING HOME PAGE GRADIENT (Midnight Blue -> Cyan)
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1BFFFF).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5
                    )
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. FLOATING STAR ICON
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.yellowAccent, size: 60),
                    ),
                    const SizedBox(height: 20),

                    // 2. LEVEL UP TEXT
                    const Text(
                      "LEVEL UP!",
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.w900, 
                        color: Colors.white, 
                        letterSpacing: 1.5,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 10)]
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    
                    // 3. SUBTITLE
                    Text(
                      "You reached Level $level!",
                      style: const TextStyle(
                        fontSize: 18, 
                        color: Colors.white70,
                        fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // 4. CONTINUE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _nextProduct();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2E3192), // Text color matches theme
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 8,
                          shadowColor: const Color(0xFF1BFFFF).withOpacity(0.5),
                        ),
                        child: const Text(
                          "Continue ➔", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResult(bool correct, int change) {
    _speakResult(correct, change);
    List<int> changeNotes = change > 0 ? _getChangeNotes(change) : [];

    String titleText = "Awesome Job!";
    String scoreText = "+10 Score";
    String collectChangeText = "Collect Your Change: ₹$change";
    String exactAmountText = "Exact amount! No change needed.";
    String nextBtnText = "Next Item ➔";

    if (currentLanguage == "hi-IN") {
      titleText = "बहुत बढ़िया!";
      scoreText = "+10 अंक";
      collectChangeText = "अपने खुले पैसे लें: ₹$change";
      exactAmountText = "सही राशि! खुले पैसों की जरूरत नहीं।";
      nextBtnText = "अगला आइटम ➔";
    } else if (currentLanguage == "ne-NP") {
      titleText = "धेरै राम्रो!";
      scoreText = "+10 अङ्क";
      collectChangeText = "आफ्नो फिर्ता पैसा लिनुहोस्: ₹$change";
      exactAmountText = "सही रकम! फिर्ता लिनु पर्दैन।";
      nextBtnText = "अर्को सामान ➔";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E3192).withValues(alpha: 0.85), 
                      const Color.fromARGB(237, 230, 73, 207).withValues(alpha: 1)
                    ], 
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 211, 239, 239).withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5
                    )
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, 
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Color.fromARGB(255, 55, 208, 12), size: 60),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      titleText,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      scoreText,
                      style: const TextStyle(fontSize: 20, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white30, height: 30),
                    if (change > 0) ...[
                      Text(
                        collectChangeText,
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: changeNotes.map((note) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                                  ]
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    "assets/money/money_$note.jpg",
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      Text(
                        exactAmountText,
                        style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _nextProduct();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2E3192),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: Text(
                          nextBtnText, 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                        ),
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

  void _resetCurrentRound() {
    setState(() { currentMoneyGiven = 0; notesOnCounter.clear(); });
  }

  List<int> _getChangeNotes(int amount) {
    List<int> changeNotes = [];
    List<int> sortedNotes = List.from(availableNotes)..sort((a, b) => b.compareTo(a));
    for (int note in sortedNotes) {
      if (amount >= note) {
        int count = amount ~/ note;
        for (int i = 0; i < count; i++) changeNotes.add(note);
        amount %= note;
      }
    }
    return changeNotes;
  }

  Future<void> _speakPrice() async {
    String textToSpeak = "";
    if (currentLanguage == 'en-US') {
      textToSpeak = "${currentProduct['name']} costs $currentPrice";
    } else if (currentLanguage == 'hi-IN') {
      textToSpeak = "${currentProduct['name_hi']} की कीमत $currentPrice रुपये है";
    } else if (currentLanguage == 'ne-NP') {
      textToSpeak = "${currentProduct['name_ne']} को मूल्य $currentPrice रुपैयाँ हो";
    }
    speak(textToSpeak);
  }

  Future<void> _speakResult(bool correct, int change) async {
    String text = "";
    if (correct) {
      if (change > 0) {
        if (currentLanguage == 'en-US') text = "Take $change change.";
        else if (currentLanguage == 'hi-IN') text = "$change रुपये वापस लो।";
        else text = "$change फिर्ता लिनुहोस्।";
      } else {
        if (currentLanguage == 'en-US') text = "Perfect!";
        else if (currentLanguage == 'hi-IN') text = "बिल्कुल सही!";
        else text = "एकदम सही!";
      }
    }
    speak(text);
  }

  void _cycleLanguage() {
    setState(() {
      if (currentLanguage == "en-US") currentLanguage = "hi-IN";
      else if (currentLanguage == "hi-IN") currentLanguage = "ne-NP";
      else currentLanguage = "en-US";
    });
    _speakPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            
            // LEVEL
            PopupMenuButton<int>(
              onSelected: _changeLevel,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 1, child: Text("Level 1 (Basic)")),
                const PopupMenuItem(value: 2, child: Text("Level 2 (Advanced)")),
                const PopupMenuItem(value: 3, child: Text("Level 3 (Pro)")),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 193, 5, 180),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  children: [
                    Text("Level $level",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white)),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.white, size: 20)
                  ],
                ),
              ),
            ),
            // SCORE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 0, 0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white,width: 2)),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 20),
                  const SizedBox(width: 22),
                  Text("$score",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                ],
              ),
            )
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: _cycleLanguage,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        currentLanguage == "en-US"
                            ? "EN"
                            : (currentLanguage == "hi-IN" ? "HI" : "NE"),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/shop/shop_bg.jpg",
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.3),
            colorBlendMode: BlendMode.darken,
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 30,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          // WRAP WITH GESTURE DETECTOR
                          child: GestureDetector(
                            onTap: () {
                              // 1. Play a small tap sound for feedback
                              playSound("tap.mp3"); 
                              // 2. Call the existing function to re-speak price
                              _speakPrice(); 
                            },
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 310),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      width: 1.5),
                                  boxShadow: [
                                    const BoxShadow(
                                        blurRadius: 10, color: Colors.black12)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(currentProduct["image"],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentLanguage == 'en-US'
                                    ? currentProduct['name']
                                    : currentLanguage == 'hi-IN'
                                        ? currentProduct['name_hi']
                                        : currentProduct['name_ne'],
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black, blurRadius: 10)
                                    ]),
                              ),
                              const SizedBox(width: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Text(
                                  "₹$currentPrice",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 32,
                  child: Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        FittedBox(
                          child: Text("Money on Counter: ₹$currentMoneyGiven",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Text("Max Notes: $level",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                        const Divider(color: Colors.white54, height: 8),
                        Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: max(constraints.maxWidth,
                                    (notesOnCounter.length * 40.0) + 100),
                                height: constraints.maxHeight,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: List.generate(notesOnCounter.length,
                                      (index) {
                                    return Positioned(
                                      left: index * 40.0,
                                      top: 0,
                                      bottom: 0,
                                      child: Image.asset(
                                        "assets/money/money_${notesOnCounter[index]}.jpg",
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          }),
                        ),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: currentMoneyGiven > 0
                                    ? _resetCurrentRound
                                    : null,
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white, size: 18),
                                label: const Text("Clear"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton.icon(
                                onPressed: currentMoneyGiven > 0
                                    ? _confirmPayment
                                    : null,
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.white, size: 18),
                                label: const Text("PAY"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 47,
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FittedBox(
                          child: Text("Your Wallet:",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 4)
                                  ])),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            children: availableNotes.map((amount) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12.0),
                                child: GestureDetector(
                                  onTap: () => _triggerFlyAnimation(amount),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Image.asset(
                                              "assets/money/money_$amount.jpg",
                                              fit: BoxFit.contain),
                                        ),
                                        const SizedBox(height: 1),
                                        Text("₹$amount",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...flyingMoneyWidgets,
        ],
      ),
    );
  }
}
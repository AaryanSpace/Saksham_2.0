import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Core imports
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class DriveAndLearnScreen extends StatefulWidget {
  const DriveAndLearnScreen({super.key});

  @override
  State<DriveAndLearnScreen> createState() => _DriveAndLearnScreenState();
}

class _DriveAndLearnScreenState extends State<DriveAndLearnScreen> with TickerProviderStateMixin {
  // --- VARIABLES ---
  int _score = 0; // User ka current score
  int _targetNumber = 50; // Wo number jahan user ko gaadi rokni hai
  double _currentPosition = 0.0; // Gaadi ki current position (0 se 100 ke scale par)
  bool _isDriving = false; // Kya user ne pedal daba rakha hai?
  bool _hasAnswered = false; // Kya user gaadi rok chuka hai?
  
  // VEHICLE GARAGE LOGIC (Gaadiyon ka collection)
  // Emojis default left face karte hain, hum aage inko code me rotate (90 deg) karenge taaki upar dekhein
  List<String> _vehicles = ['🚗', '🚌', '🚛', '🏍️'];
  int _selectedVehicleIndex = 0; // Default car selected hai

  Timer? _driveTimer; // Gaadi chalane wala timer engine
  final Random _random = Random(); // Random target generate karne ke liye

  // Feedback UI variables
  String _feedbackText = "";
  Color _feedbackColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _startNewRound(); // Screen open hote hi pehla round start
  }

  @override
  void dispose() {
    _driveTimer?.cancel(); // Memory leak se bachne ke liye timer ko cancel karna zaroori hai
    super.dispose();
  }

  // --- NEW ROUND LOGIC ---
  void _startNewRound() {
    setState(() {
      _hasAnswered = false; // Round reset
      _currentPosition = 0.0; // Gaadi wapas 0 (bottom) par aa jayegi
      _feedbackText = "";
      
      // Random target generate karo 10 aur 95 ke beech mein
      _targetNumber = 10 + _random.nextInt(86); 
    });
    _speakTarget(); // Target ko aawaz mein bolo
  }

  void _speakTarget() {
    String text = "Drive to $_targetNumber";
    if (currentLanguage == 'hi-IN') text = "$_targetNumber तक गाड़ी चलाएं";
    if (currentLanguage == 'ne-NP') text = "$_targetNumber सम्म गाडी चलाउनुहोस्";
    speak(text); // Text-to-speech
  }

  // --- ACCELERATOR LOGIC (PEDAL PRESS) ---
  void _startDriving() {
    if (_hasAnswered) return; // Agar round khatam ho gaya to gaadi mat chalao
    playSound("tap.mp3"); // Engine start sound
    setState(() => _isDriving = true);
    
    // Har 30 milliseconds mein gaadi aage (upar) badhegi
    _driveTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        // SPEED SETTING: Yahan 0.4 hai. Isey bada kar gaadi fast aur chhota kar slow kar sakte hain.
        _currentPosition += 0.4; 
        
        // Agar gaadi 100 (Top) par pahunch jaye toh automatically rok do
        if (_currentPosition >= 100) {
          _currentPosition = 100;
          _stopDriving();
        }
      });
    });
  }

  // --- BRAKE LOGIC (PEDAL RELEASE) ---
  void _stopDriving() {
    if (!_isDriving || _hasAnswered) return;
    _driveTimer?.cancel(); // Timer (Engine) band
    setState(() {
      _isDriving = false;
      _hasAnswered = true; // User ne apna turn le liya
    });
    _checkParking(); // Ab check karo sahi jagah ruki ya nahi
  }

  // --- CHECK WIN/LOSS LOGIC ---
  void _checkParking() {
    // Dyscalculia ke liye thodi margin/chhoot dete hain (+/- 4 numbers ki)
    double difference = (_targetNumber - _currentPosition).abs();

    if (difference <= 4.0) {
      // ✅ PERFECT PARKING (Jeet gaye)
      playSound("success.mp3");
      PlayerStats.addXP(20);
      setState(() {
        _score += 5;
        _feedbackColor = Colors.greenAccent;
        if (currentLanguage == 'hi-IN') _feedbackText = "बिल्कुल सही जगह! 🏆";
        else if (currentLanguage == 'ne-NP') _feedbackText = "उत्कृष्ट पार्किङ! 🏆";
        else _feedbackText = "Perfect Parking! 🏆";
      });
      speak(_feedbackText);
    } else {
      // ❌ WRONG PARKING (Galat jagah roki)
      playSound("tap.mp3"); 
      setState(() {
        _feedbackColor = Colors.redAccent;
        if (_currentPosition < _targetNumber) {
          if (currentLanguage == 'hi-IN') _feedbackText = "थोड़ा और आगे जाना था!";
          else if (currentLanguage == 'ne-NP') _feedbackText = "अलि अगाडि जानुपर्थ्यो!";
          else _feedbackText = "Too short! Keep going.";
        } else {
          if (currentLanguage == 'hi-IN') _feedbackText = "बहुत आगे निकल गए!";
          else if (currentLanguage == 'ne-NP') _feedbackText = "धेरै अगाडि जानुभयो!";
          else _feedbackText = "Oops! You went too far.";
        }
      });
      speak(_feedbackText);
    }

    // 2.5 seconds baad gaadi wapas 0 par aur naya round start
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _startNewRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    String headerText = "Drive to number";
    if (currentLanguage == 'hi-IN') headerText = "यहाँ तक चलाएं";
    if (currentLanguage == 'ne-NP') headerText = "यहाँ सम्म चलाउनुहोस्";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // App Bar UI (Score aur Back button)
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
        actions: [LanguageButton(onChanged: () => setState(() {}))],
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            const SizedBox(height: 90),
            
            // 1. TARGET CARD (Kahan jana hai)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Column(
                  children: [
                    Text(headerText, style: const TextStyle(fontSize: 20, color: Colors.white70)),
                    Text(
                      getLocalizedNumber(_targetNumber),
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: AppTheme.accentYellow, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 10),

            // 2. VEHICLE GARAGE (Gaadi select karne ka box)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_vehicles.length, (index) {
                  bool isSelected = _selectedVehicleIndex == index;
                  return GestureDetector(
                    onTap: () {
                      if (!_isDriving && !_hasAnswered) {
                        setState(() => _selectedVehicleIndex = index);
                        playSound("tap.mp3");
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white30, width: 2),
                      ),
                      child: Text(_vehicles[index], style: const TextStyle(fontSize: 30)),
                    ),
                  );
                }),
              ),
            ),

            // Feedback Text (Bich mein dikhega gaadi rokne par)
            if (_hasAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _feedbackText,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _feedbackColor, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
              ),

            // 3. THE VERTICAL ROAD (Main Game Area)
            // Expanded widget isliye lagaya taaki screen ki bachi hui saari height ye road le le!
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Math Logic for Vertical Position
                  double roadHeight = constraints.maxHeight; // Total available height
                  double roadWidth = 140.0; // Highway ki chaurayi
                  double paddingY = 40.0; // Top aur Bottom se thoda gap taaki gaadi kate nahi
                  double availableHeight = roadHeight - (paddingY * 2);

                  // Formula: 0 position par gaadi niche (bottom) hogi, 100 par upar (top) hogi.
                  double vehicleY = paddingY + (1 - (_currentPosition / 100)) * availableHeight;
                  // Flag ki Y position
                  double flagY = paddingY + (1 - (_targetNumber / 100)) * availableHeight;

                  return Stack(
                    alignment: Alignment.center, // Sab kuch horizontally center mein rakhega
                    children: [
                      // A) Highway Road Painter (Niche background me draw hoga)
                      SizedBox(
                        width: MediaQuery.of(context).size.width, // Poori screen ki width le raha hai drawing ke liye
                        height: roadHeight,
                        child: CustomPaint(painter: VerticalRoadPainter()),
                      ),
                      
                      // B) The Target Flag (Gaadi rokne ke baad dikhega)
                      if (_hasAnswered)
                        Positioned(
                          top: flagY - 20, // Thoda adjust kiya taaki road ke side me dikhe
                          right: (MediaQuery.of(context).size.width / 2) - (roadWidth / 2) - 60, // Road ke right side me
                          child: Column(
                            children: [
                              const Text("📍", style: TextStyle(fontSize: 35)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  getLocalizedNumber(_targetNumber), 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                                ),
                              ),
                            ],
                          ),
                        ),

                      // C) The Driving Vehicle (Humari Gaadi)
                      Positioned(
                        // VIBRATION LOGIC: Agar chal rahi hai to X axis par thoda hilegi (shake hogi)
                        left: _isDriving 
                            ? (MediaQuery.of(context).size.width / 2) - 25 + (_random.nextDouble() * 4 - 2)
                            : (MediaQuery.of(context).size.width / 2) - 25, 
                        top: vehicleY - 25, // -25 is approximate center of emoji
                        
                        // 🔥 MAIN FIX: RotatedBox gaadi ko 90 degree rotate karta hai taaki wo UPAR (FORWARD) face kare!
                        child: RotatedBox(
                          quarterTurns: 1, // 1 Quarter Turn = 90 Degrees Clockwise
                          child: Text(
                            _vehicles[_selectedVehicleIndex],
                            style: const TextStyle(fontSize: 50, shadows: [Shadow(color: Colors.black54, offset: Offset(3, 5), blurRadius: 5)]),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),

            // 4. THE ACCELERATOR PEDAL (Sabse niche)
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: GestureDetector(
                onTapDown: (_) => _startDriving(), // Dabane par chalegi
                onTapUp: (_) => _stopDriving(), // Chhodne par rukegi
                onTapCancel: () => _stopDriving(), // Agar ungli bahar fisal jaye to rukegi
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isDriving 
                          ? [Colors.green.shade600, Colors.greenAccent] 
                          : [Colors.blue.shade600, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: _isDriving ? Colors.greenAccent.withOpacity(0.6) : Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.speed, size: 35, color: _isDriving ? Colors.white : Colors.white70),
                      Text(
                        currentLanguage == 'hi-IN' ? "चलाएं" : (currentLanguage == 'ne-NP' ? "चलाउनुहोस्" : "DRIVE"),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const Text("(Hold)", style: TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
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

// ==========================================
// --- VERTICAL ROAD & NUMBER LINE PAINTER ---
// ==========================================
// Ye class poori road aur 0 se 100 tak ke markings khud code se draw karti hai
class VerticalRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double roadWidth = 140.0; // Road ki motayi
    double centerX = size.width / 2; // Screen ka beecho-beech point

    // 1. Draw Asphalt (Dark Grey Road)
    final roadPaint = Paint()..color = const Color(0xFF2C3E50);
    final roadRect = Rect.fromCenter(center: Offset(centerX, size.height / 2), width: roadWidth, height: size.height);
    canvas.drawRect(roadRect, roadPaint);

    // 2. Draw Solid White Edges (Road ke kinare wali line)
    final edgePaint = Paint()..color = Colors.white..strokeWidth = 4;
    double leftEdgeX = centerX - (roadWidth / 2) + 5;
    double rightEdgeX = centerX + (roadWidth / 2) - 5;
    canvas.drawLine(Offset(leftEdgeX, 0), Offset(leftEdgeX, size.height), edgePaint);
    canvas.drawLine(Offset(rightEdgeX, 0), Offset(rightEdgeX, size.height), edgePaint);

    // 3. Draw Dashed Yellow Line (Highway ke bich ki lehrati yellow line)
    final dashPaint = Paint()..color = Colors.amber..strokeWidth = 4;
    double dashHeight = 25, dashSpace = 25, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(centerX, startY), Offset(centerX, startY + dashHeight), dashPaint);
      startY += dashHeight + dashSpace; // Ek dash aur ek khali space
    }

    // 4. Draw Number Line Markers (0, 10, 20... 100) on the Left Side
    double paddingY = 40.0;
    double availableHeight = size.height - (paddingY * 2);
    final markerPaint = Paint()..color = Colors.white..strokeWidth = 2;

    for (int i = 0; i <= 100; i += 10) {
      // Niche se upar jane ka math (0 is bottom, 100 is top)
      double y = paddingY + (1 - (i / 100)) * availableHeight;
      
      // Draw Tick Mark (Chhoti safed line) road ke left edge par
      canvas.drawLine(Offset(leftEdgeX, y), Offset(leftEdgeX - 15, y), markerPaint);
      
      // Draw Numbers (Localized in Hindi/Nepali/English)
      final textPainter = TextPainter(
        text: TextSpan(
          text: getLocalizedNumber(i),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Text ko line ke theek left mein center align karna
      textPainter.paint(canvas, Offset(leftEdgeX - 25 - textPainter.width, y - (textPainter.height / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // Road update hoti rehni chahiye
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
  int _score = 0;
  int _targetNumber = 50;
  double _currentPosition = 0.0; // 0 to 100 scale
  bool _isDriving = false;
  bool _hasAnswered = false;
  
  // VEHICLE GARAGE LOGIC
  List<String> _vehicles = ['🚗', '🚌', '🚛', '🏍️'];
  int _selectedVehicleIndex = 0;

  Timer? _driveTimer;
  final Random _random = Random();

  String _feedbackText = "";
  Color _feedbackColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void dispose() {
    _driveTimer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    setState(() {
      _hasAnswered = false;
      _currentPosition = 0.0;
      _feedbackText = "";
      
      // Generate a random target between 10 and 95 (avoiding extreme edges)
      _targetNumber = 10 + _random.nextInt(86); 
    });
    _speakTarget();
  }

  void _speakTarget() {
    String text = "Drive to $_targetNumber";
    if (currentLanguage == 'hi-IN') text = "$_targetNumber तक गाड़ी चलाएं";
    if (currentLanguage == 'ne-NP') text = "$_targetNumber सम्म गाडी चलाउनुहोस्";
    speak(text);
  }

  // ACCELERATOR LOGIC (Pedal dabane par gaadi chalegi)
  void _startDriving() {
    if (_hasAnswered) return;
    playSound("tap.mp3"); // Replace with engine.mp3 if you have one!
    setState(() => _isDriving = true);
    
    _driveTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        // Speed of the vehicle
        _currentPosition += 0.8; 
        if (_currentPosition >= 100) {
          _currentPosition = 100;
          _stopDriving();
        }
      });
    });
  }

  // BREAK LOGIC (Pedal chhodne par gaadi rukegi aur check hoga)
  void _stopDriving() {
    if (!_isDriving || _hasAnswered) return;
    _driveTimer?.cancel();
    setState(() {
      _isDriving = false;
      _hasAnswered = true;
    });
    _checkParking();
  }

  void _checkParking() {
    // Dyscalculia ke liye hum thodi chhoot (margin of error) denge
    // Agar target 45 hai, aur user ne 42 se 48 ke beech roka, toh bhi WIN!
    double difference = (_targetNumber - _currentPosition).abs();

    if (difference <= 4.0) {
      // ✅ PERFECT PARKING
      playSound("success.mp3");
      PlayerStats.addXP(20);
      setState(() {
        _score += 15;
        _feedbackColor = Colors.greenAccent;
        if (currentLanguage == 'hi-IN') _feedbackText = "बिल्कुल सही जगह! 🏆";
        else if (currentLanguage == 'ne-NP') _feedbackText = "उत्कृष्ट पार्किङ! 🏆";
        else _feedbackText = "Perfect Parking! 🏆";
      });
      speak(_feedbackText);
    } else {
      // ❌ WRONG PARKING
      playSound("tap.mp3"); // Error sound
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

    // 2.5 seconds baad gaadi wapas start line par
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _startNewRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    String headerText = "Drive to number";
    if (currentLanguage == 'hi-IN') headerText = "यहाँ तक चलाएं";
    if (currentLanguage == 'ne-NP') headerText = "यहाँ सम्म चलाउनुहोस्";

    // Dynamic Road Width
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 20.0;
    double roadWidth = screenWidth - (padding * 2);
    
    // Calculate Vehicle X Position pixel
    double vehicleX = padding + (_currentPosition / 100) * (roadWidth - 40); // 40 is approx vehicle width offset

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
        actions: [LanguageButton(onChanged: () => setState(() {}))],
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            const SizedBox(height: 100),
            
            // TARGET CARD
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
            
            const SizedBox(height: 15),

            // VEHICLE GARAGE (Selection)
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
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white30, width: 2),
                      ),
                      child: Text(_vehicles[index], style: const TextStyle(fontSize: 35)),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // FEEDBACK TEXT (Perfect / Too Far)
            if (_hasAnswered)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _feedbackText,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _feedbackColor, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
              ),

            // THE REALISTIC ROAD & NUMBER LINE
            SizedBox(
              height: 180,
              width: screenWidth,
              child: Stack(
                children: [
                  // 1. The Highway Road Painter
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: CustomPaint(painter: RoadPainter()),
                    ),
                  ),
                  
                  // 2. The Target Flag (Appears only after stopping)
                  if (_hasAnswered)
                    Positioned(
                      left: padding + (_targetNumber / 100) * (roadWidth - 40) + 10,
                      top: 20,
                      child: Column(
                        children: [
                          const Text("📍", style: TextStyle(fontSize: 30)),
                          Text(
                            getLocalizedNumber(_targetNumber), 
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18, backgroundColor: Colors.black54)
                          ),
                        ],
                      ),
                    ),

                  // 3. The Driving Vehicle
                  Positioned(
                    left: vehicleX,
                    top: _isDriving ? 68 + (_random.nextDouble() * 3) : 70, // Vibration effect while driving!
                    child: Text(
                      _vehicles[_selectedVehicleIndex],
                      style: const TextStyle(fontSize: 50, shadows: [Shadow(color: Colors.black54, offset: Offset(3, 5), blurRadius: 5)]),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // THE ACCELERATOR PEDAL
            GestureDetector(
              onTapDown: (_) => _startDriving(),
              onTapUp: (_) => _stopDriving(),
              onTapCancel: () => _stopDriving(),
              child: Container(
                width: 140,
                height: 140,
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
                    Icon(Icons.speed, size: 40, color: _isDriving ? Colors.white : Colors.white70),
                    const SizedBox(height: 5),
                    Text(
                      currentLanguage == 'hi-IN' ? "चलाएं" : (currentLanguage == 'ne-NP' ? "चलाउनुहोस्" : "DRIVE"),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const Text("(Hold)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// --- REALISTIC ROAD & NUMBER LINE PAINTER ---
// ==========================================
class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the dark asphalt road
    final roadRect = Rect.fromLTWH(0, 50, size.width, 100);
    final roadPaint = Paint()..color = const Color(0xFF2C3E50); // Dark grayish-blue asphalt
    canvas.drawRect(roadRect, roadPaint);

    // 2. Draw Top and Bottom Solid White Edge Lines
    final edgePaint = Paint()..color = Colors.white..strokeWidth = 3;
    canvas.drawLine(Offset(0, 55), Offset(size.width, 55), edgePaint);
    canvas.drawLine(Offset(0, 145), Offset(size.width, 145), edgePaint);

    // 3. Draw Center Dashed Yellow Line (Highway look)
    final dashPaint = Paint()..color = Colors.amber..strokeWidth = 3;
    double dashWidth = 20, dashSpace = 20, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 100), Offset(startX + dashWidth, 100), dashPaint);
      startX += dashWidth + dashSpace;
    }

    // 4. Draw Number Line Markers (0, 10, 20... 100)
    final markerPaint = Paint()..color = Colors.white..strokeWidth = 2;
    for (int i = 0; i <= 100; i += 10) {
      double x = (i / 100) * (size.width - 40) + 20; // 40 is offset for vehicle width
      
      // Draw tick mark
      canvas.drawLine(Offset(x, 145), Offset(x, 160), markerPaint);
      
      // Draw text (Localized numbers!)
      final textPainter = TextPainter(
        text: TextSpan(
          text: getLocalizedNumber(i),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), 165));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
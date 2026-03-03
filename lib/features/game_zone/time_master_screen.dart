import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class TimeMasterScreen extends StatefulWidget {
  const TimeMasterScreen({super.key});

  @override
  State<TimeMasterScreen> createState() => _TimeMasterScreenState();
}

class _TimeMasterScreenState extends State<TimeMasterScreen> with TickerProviderStateMixin {
  final Random _random = Random();
  int _score = 0;
  
  int _targetHour = 12;
  int _targetMinute = 0;
  
  int _currentHour = 12;
  int _currentMinute = 0;

  // Feedback Animation
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScaleAnimation;
  String _feedbackText = "";
  Color _feedbackColor = Colors.white;

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

  void _startNewRound() {
    setState(() {
      _targetHour = _random.nextInt(12) + 1; // 1 to 12
      // Keep minutes to 0, 15, 30, 45 to make it accessible for beginners
      List<int> minuteOptions = [0, 15, 30, 45];
      _targetMinute = minuteOptions[_random.nextInt(minuteOptions.length)];
      
      _currentHour = 12;
      _currentMinute = 0;
    });

    _speakTargetTime();
  }

  void _speakTargetTime() {
    String minStr = _targetMinute == 0 ? "o'clock" : _targetMinute.toString();
    String speakText = "";

    if (currentLanguage == 'hi-IN') {
      if (_targetMinute == 0) speakText = "$_targetHour बजाइए";
      else if (_targetMinute == 15) speakText = "सवा $_targetHour बजाइए";
      else if (_targetMinute == 30) speakText = "साढ़े $_targetHour बजाइए";
      else if (_targetMinute == 45) speakText = "पौने ${_targetHour == 12 ? 1 : _targetHour + 1} बजाइए";
    } else if (currentLanguage == 'ne-NP') {
      // FIX: Corrected Nepali TTS logic to sound natural
      if (_targetMinute == 0) speakText = "$_targetHour बजाउनुहोस्";
      else if (_targetMinute == 15) speakText = "सवा $_targetHour बजाउनुहोस्";
      else if (_targetMinute == 30) speakText = "साढे $_targetHour बजाउनुहोस्";
      else if (_targetMinute == 45) speakText = "पौने ${_targetHour == 12 ? 1 : _targetHour + 1} बजाउनुहोस्";
    } else {
      speakText = "Set the time to $_targetHour $minStr";
    }
    
    speak(speakText);
  }

  void _adjustTime(int hoursToAdd, int minutesToAdd) {
    playSound("tap.mp3");
    setState(() {
      _currentMinute += minutesToAdd;
      if (_currentMinute >= 60) {
        _currentMinute -= 60;
        _currentHour++;
      } else if (_currentMinute < 0) {
        _currentMinute += 60;
        _currentHour--;
      }

      _currentHour += hoursToAdd;
      if (_currentHour > 12) _currentHour -= 12;
      if (_currentHour < 1) _currentHour += 12;
    });
  }

  void _checkTime() {
    if (_currentHour == _targetHour && _currentMinute == _targetMinute) {
      // ✅ SUCCESS
      playSound("success.mp3");
      PlayerStats.addXP(15);
      
      setState(() {
        _score += 15;
      });

      _triggerWinFeedback();

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) _startNewRound();
      });
    } else {
      // ❌ WRONG
      playSound("tap.mp3");
      String wrongText = currentLanguage == 'hi-IN' ? "गलत समय, फिर कोशिश करें" : "Wrong time, try again!";
      if (currentLanguage == 'ne-NP') wrongText = "गलत समय, फेरी प्रयास गर्नुहोस्";

      speak(wrongText);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(wrongText, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(milliseconds: 1000),
      ));
    }
  }

  void _triggerWinFeedback() {
    List<String> words = ["Awesome!", "Perfect Time!", "Great Job!"];
    if (currentLanguage == 'hi-IN') words = ["बिल्कुल सही समय!", "शानदार!", "बहुत बढ़िया!"];
    if (currentLanguage == 'ne-NP') words = ["सही समय!", "धेरै राम्रो!", "बबाल!"];

    final selectedWord = words[_random.nextInt(words.length)];

    setState(() {
      _feedbackText = selectedWord;
      _feedbackColor = Colors.greenAccent;
    });

    Future.delayed(const Duration(milliseconds: 100), () => speak(selectedWord));
    _feedbackController.reset();
    _feedbackController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // --- LOCALIZATION LOGIC FOR TEXTS AND BUTTONS ---
    String headerText = "Set the time to";
    String hourBtn = "Hour +";
    String minBtn = "Min +15";
    String checkBtn = "CHECK TIME";

    if (currentLanguage == 'hi-IN') {
      headerText = "समय सेट करें";
      hourBtn = "घंटा +";
      minBtn = "मिनट +${getLocalizedNumber(15)}";
      checkBtn = "समय जांचें";
    } else if (currentLanguage == 'ne-NP') {
      headerText = "समय सेट गर्नुहोस्";
      hourBtn = "घण्टा +";
      minBtn = "मिनेट +${getLocalizedNumber(15)}";
      checkBtn = "समय जाँच गर्नुहोस्";
    }

    // --- LOCALIZATION LOGIC FOR TARGET TIME NUMBERS ---
    String locHour = getLocalizedNumber(_targetHour);
    // If minute is 0, we need '00' or '००'
    String locMin = _targetMinute == 0 
        ? "${getLocalizedNumber(0)}${getLocalizedNumber(0)}" 
        : getLocalizedNumber(_targetMinute);
    
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: LanguageButton(onChanged: () => setState(() { _speakTargetTime(); })),
          )
        ],
      ),
      body: BackgroundWrapper(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                
                // TARGET TIME CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          headerText, // Localized
                          style: const TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$locHour:$locMin", // Fully Localized Numbers!
                          style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: AppTheme.accentYellow, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),

                // THE ANALOG CLOCK
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white54, width: 4),
                    boxShadow: [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: CustomPaint(
                    painter: ClockPainter(hour: _currentHour, minute: _currentMinute),
                  ),
                ),

                const Spacer(),

                // CONTROLS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(hourBtn, () => _adjustTime(1, 0)), // Localized
                      _buildControlButton(minBtn, () => _adjustTime(0, 15)), // Localized
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // CHECK BUTTON
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _checkTime,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 8,
                    ),
                    child: Text(checkBtn, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)), // Localized
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),

            // SUCCESS FEEDBACK ANIMATION
            Center(
              child: ScaleTransition(
                scale: _feedbackScaleAnimation,
                child: FadeTransition(
                  opacity: _feedbackController.drive(Tween(begin: 3.0, end: 0.0)),
                  child: Text(
                    _feedbackText,
                    style: TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w900, color: _feedbackColor,
                      shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)],
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

  Widget _buildControlButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.white30)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// CUSTOM PAINTER TO DRAW THE ANALOG CLOCK
class ClockPainter extends CustomPainter {
  final int hour;
  final int minute;

  ClockPainter({required this.hour, required this.minute});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw center dot
    final centerPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);

    // Draw hour markers
    final markerPaint = Paint()..color = Colors.white54..strokeWidth = 3;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final p1 = Offset(center.dx + (radius - 12) * cos(angle), center.dy + (radius - 12) * sin(angle));
      final p2 = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(p1, p2, markerPaint);
    }

    // DRAW NUMBERS (1 to 12)
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: getLocalizedNumber(i), 
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      final offset = Offset(
        center.dx + (radius - 35) * cos(angle) - textPainter.width / 2,
        center.dy + (radius - 35) * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // Calculate angles
    final minAngle = (minute * 6 - 90) * pi / 180;
    final hourAngle = ((hour * 30) + (minute * 0.5) - 90) * pi / 180;

    // Draw Minute Hand
    final minPaint = Paint()..color = Colors.cyanAccent..strokeWidth = 4..strokeCap = StrokeCap.round;
    final minHandX = center.dx + (radius * 0.65) * cos(minAngle);
    final minHandY = center.dy + (radius * 0.65) * sin(minAngle);
    canvas.drawLine(center, Offset(minHandX, minHandY), minPaint);

    // Draw Hour Hand
    final hourPaint = Paint()..color = Colors.orangeAccent..strokeWidth = 6..strokeCap = StrokeCap.round;
    final hourHandX = center.dx + (radius * 0.45) * cos(hourAngle);
    final hourHandY = center.dy + (radius * 0.45) * sin(hourAngle);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
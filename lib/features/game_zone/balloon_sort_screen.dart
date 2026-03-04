import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Aapke core files aur widgets ke imports
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class BalloonSortScreen extends StatefulWidget {
  const BalloonSortScreen({super.key});

  @override
  State<BalloonSortScreen> createState() => _BalloonSortScreenState();
}

class _BalloonSortScreenState extends State<BalloonSortScreen> with TickerProviderStateMixin {
  // --- VARIABLES ---
  final Random _random = Random(); // Random numbers generate karne ke liye
  int _score = 0; // User ka current score
  List<BalloonItem> _balloons = []; // Screen par jitne balloons hain, unki list
  Timer? _loopTimer; // Game engine ka timer jo har frame ko update karta hai
  
  String _questionText = "Tap the BIGGEST number!"; // Screen par dikhne wala sawal
  bool _findBiggest = true; // Agar true hai toh sabse bada number dhundna hai, false hai toh sabse chhota
  int _targetNumber = 0; // Is round ka Sahi Jawab (Right Answer)
  
  // Ye lock isliye hai taaki jab user sahi jawab de de, 
  // toh jab tak naya round shuru na ho, wo doosre balloons par tap na kar sake
  bool _isTransitioning = false; 

  @override
  void initState() {
    super.initState();
    _startNewRound(); // Screen khulte hi pehla round start karna
    
    // GAME ENGINE LOOP: Har 50 milliseconds mein screen update hogi (Smooth floating effect ke liye)
    _loopTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) => _updateBalloons());
  }

  @override
  void dispose() {
    _loopTimer?.cancel(); // Screen band hone par timer ko band karna zaroori hai (memory leak bachane ke liye)
    super.dispose();
  }

  // --- LANGUAGE UPDATE LOGIC ---
  // Jab bhi user upar se bhasha (Hindi/Nepali/English) badlega, toh ye function question text update karega
  void _updateLanguageText() {
    setState(() {
      if (currentLanguage == 'hi-IN') {
        _questionText = _findBiggest ? "सबसे बड़ा नंबर टैप करें!" : "सबसे छोटा नंबर टैप करें!";
      } else if (currentLanguage == 'ne-NP') {
        _questionText = _findBiggest ? "ठूलो संख्यामा ट्याप गर्नुहोस्!" : "सानो संख्यामा ट्याप गर्नुहोस्!";
      } else {
        _questionText = _findBiggest ? "Tap the BIGGEST number!" : "Tap the SMALLEST number!";
      }
    });
    speak(_questionText); // Text-to-speech se naya question bolna
  }

  // --- NEW ROUND LOGIC ---
  // Ye function naye balloons banata hai aur naya sawal set karta hai
  void _startNewRound() {
    setState(() {
      _isTransitioning = false; // Naye round mein tap ka lock khol do
      _balloons.clear(); // Purane balloons ko screen se hatao
      _findBiggest = _random.nextBool(); // Randomly decide karo ki bada number dhundna hai ya chhota

      // 1. EXACTLY 3 UNIQUE NUMBERS GENERATE KARNA
      List<int> nums = [];
      while(nums.length < 3) {
        int n = _random.nextInt(99) + 1; // 1 se 99 tak ke beech ka number
        if (!nums.contains(n)) nums.add(n); // Agar number pehle se list mein nahi hai, tabhi add karo
      }

      // 2. IS ROUND KA SAHI JAWAB SET KARNA (Min ya Max)
      _targetNumber = _findBiggest ? nums.reduce(max) : nums.reduce(min);

      // 3. 3 NAYE BALLOONS BANANA
      for (int i = 0; i < 3; i++) {
        _balloons.add(BalloonItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          number: nums[i],
          columnIndex: i, // 0 = Left Column, 1 = Center Column, 2 = Right Column
          y: 1.1 + (_random.nextDouble() * 0.3), // Starting height: Screen ke bilkul thoda sa niche se aayenge
          speed: _random.nextDouble() * 0.004 + 0.005, // Base speed: yahan values badha kar speed fast kar sakte ho
        ));
      }
    });
    
    _updateLanguageText(); // Naye round ka sawal screen par dikhao aur bolo
  }

  // --- BALLOON MOVEMENT & PHYSICS LOGIC ---
  void _updateBalloons() {
    if (!mounted) return;
    setState(() {
      // Har balloon ko uski speed ke hisaab se upar (y-axis mein minus) bhejo
      for (var b in _balloons) {
        b.y -= b.speed; 
      }
      
      // Agar balloon screen ke bilkul upar se bahar nikal jaye (-0.3 height), toh usko list se delete kar do
      _balloons.removeWhere((b) => b.y < -0.3 && b.state == BalloonState.normal);

      // Agar user ne kisi ko tap nahi kiya aur teeno balloons screen se upar ud gaye, 
      // toh automatically naya round start kar do
      if (!_isTransitioning && _balloons.where((b) => b.state == BalloonState.normal).isEmpty) {
        _startNewRound();
      }
    });
  }

  // --- TAP (CLICK) LOGIC ---
  void _handleTap(BalloonItem tappedBalloon) {
    // Agar game dusre round mein ja raha hai ya balloon pehle hi phat chuka hai, toh kuch mat karo
    if (tappedBalloon.state != BalloonState.normal || _isTransitioning) return; 

    if (tappedBalloon.number == _targetNumber) {
      // ✅ SAHI JAWAB (CORRECT ANSWER)
      playSound("success.mp3"); // Khushi wali aawaz
      PlayerStats.addXP(15); // XP points badhao
      
      setState(() {
        _isTransitioning = true; // Baaki balloons par tap block kar do
        _score += 10; // Score badhao
        tappedBalloon.state = BalloonState.smiling; // Emoji ko smile me badal do
        tappedBalloon.speed = 0.04; // Sahi balloon ko rocket ki tarah tezi se upar uda do
      });

      // 1.5 second baad naya round start karo (Animation khatam hone ka wait)
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _startNewRound();
      });

    } else {
      // ❌ GALAT JAWAB (WRONG ANSWER)
      playSound("tap.mp3"); // Balloon phatne ki aawaz (Pop sound)
      setState(() {
        tappedBalloon.state = BalloonState.popped; // Emoji ko phate hue blast me badlo
      });

      // 400 milliseconds baad us phate hue balloon ko screen se hata do
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _balloons.remove(tappedBalloon);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 PERFECT SPACING MATH LOGIC (Sabse important hissa) 🔥
    double screenWidth = MediaQuery.of(context).size.width; // Phone ki total chaurayi (width)
    double balloonWidth = 100.0; // Balloon ki fixed width (agar balloon ka size change karo, toh isko bhi karna)
    
    // Total screen width mein se 3 balloons ki width minus ki. 
    // Jo khali jagah bachi usko 4 hisso mein baanta (Left edge, bich me 2 gap, Right edge)
    double gap = (screenWidth - (3 * balloonWidth)) / 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // ... (APPBAR UI: Back button, Score star, aur Language button) ...
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
            // FLOATING BALLOONS RENDER KARNA
            ..._balloons.map((balloon) {
              // Har balloon ko math logic se uski perfect left position assign karna
              // columnIndex 0, 1, 2 hoga. Uss hisaab se wo apne gap par place ho jayega
              double leftPosition = gap + balloon.columnIndex * (balloonWidth + gap);

              return Positioned(
                left: leftPosition, 
                top: MediaQuery.of(context).size.height * balloon.y, // Upar jane wala floating logic
                child: GestureDetector(
                  onTap: () => _handleTap(balloon),
                  child: _buildBalloonWidget(balloon),
                ),
              );
            }).toList(),

            // QUESTION CARD (Top par dikhne wala text)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 14, right: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2
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

  // --- BALLOON UI WIDGET ---
  // Ye function decide karta hai ki balloon kaisa dikhega (Sahi hone par, Galat hone par, ya Normal halat mein)
  Widget _buildBalloonWidget(BalloonItem balloon) {
    
    // GALAT JAWAB (Phata hua Balloon / Popped)
    if (balloon.state == BalloonState.popped) {
      return const SizedBox(
        width: 100, height: 210, // Height utni hi rakhi taaki phatne par jagah na hile
        child: Align(
          alignment: Alignment.topCenter,
          child: Text("💥", style: TextStyle(fontSize: 85))
        ),
      );
    } 
    
    // SAHI JAWAB (Udta hua Smiling face)
    if (balloon.state == BalloonState.smiling) {
      return const SizedBox(
        width: 100, height: 210,
        child: Align(
          alignment: Alignment.topCenter,
          child: Text("😊", style: TextStyle(fontSize: 85))
        ),
      );
    }

    // NORMAL STATE (Asli udta hua balloon jisme Number likha hai)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Balloon ka Main Body (Ande jaisa shape - Elliptical)
        Container(
          width: 110,  
          height: 130, 
          decoration: BoxDecoration(
            color: balloon.color.withOpacity(0.85),
            borderRadius: const BorderRadius.all(Radius.elliptical(55, 65)), // Hamesha Width aur Height ka exactly AADHA (half) 
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: [
              BoxShadow(color: balloon.color.withOpacity(0.5), blurRadius: 10) // Piche thoda glow effect
            ]
          ),
          child: Center(
            child: Text(
              getLocalizedNumber(balloon.number), // Number (Hindi/Nepali me bhi change hoga)
              style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        
        // 2. Balloon ki Gaath (Knot - Triangle shape)
        CustomPaint(
          size: const Size(18, 12), 
          painter: BalloonKnotPainter(color: balloon.color.withOpacity(0.85)),
        ),
        
        // 3. Balloon ka Dhaga (Thread - Wavy line)
        CustomPaint(
          size: const Size(25, 90), 
          painter: BalloonStringPainter(),
        ),
      ],
    );
  }
}

// ==========================================
// --- CUSTOM PAINTERS (Drawing Shapes) ---
// ==========================================

// Balloon ke niche wala chhota sa triangle (Gaath / Knot) banane ka logic
class BalloonKnotPainter extends CustomPainter {
  final Color color;
  BalloonKnotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0) // Upar ka center point
      ..lineTo(0, size.height)    // Niche Left ka point
      ..lineTo(size.width, size.height) // Niche Right ka point
      ..close(); // Teeno points ko jod kar triangle complete kar do
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Balloon ke niche latakne wala lehrata hua dhaga (Wavy String) banane ka logic
class BalloonStringPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke // Hamein outline chahiye, bhara hua color nahi
      ..strokeWidth = 1.5;

    // Bezier Curves ka use karke S-shape wave banayi gayi hai
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(0, size.height * 0.25, size.width / 2, size.height * 0.5)
      ..quadraticBezierTo(size.width, size.height * 0.75, size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// --- DATA MODELS ---
// ==========================================

// Balloon ki halat (Normal hai, phat gaya, ya udd raha hai)
enum BalloonState { normal, popped, smiling }

// Ek Balloon object ka blueprint
class BalloonItem {
  String id;
  int number; // Balloon ke andar ka number
  int columnIndex; // Screen par kaunsi jagah hai: Left (0), Center (1), Right (2)
  double y; // Y-Axis position (Height par kahan hai)
  double speed; // Kitni tezi se upar jayega
  BalloonState state;
  Color color; // Balloon ka color

  BalloonItem({
    required this.id, 
    required this.number, 
    required this.columnIndex, 
    required this.y, 
    required this.speed, 
    this.state = BalloonState.normal,
  }) : color = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent, Colors.purpleAccent][Random().nextInt(5)]; 
  // Balloon ka color in 5 me se randomly set hoga
}
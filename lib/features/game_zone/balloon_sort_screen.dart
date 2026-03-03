import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  final Random _random = Random();
  int _score = 0;
  List<BalloonItem> _balloons = [];
  Timer? _spawnTimer;
  Timer? _loopTimer;
  
  String _questionText = "Tap the BIGGEST number!";
  bool _findBiggest = true; 

  @override
  void initState() {
    super.initState();
    _startNewRound();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) => _spawnBalloon());
    _loopTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) => _updateBalloons());
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _loopTimer?.cancel();
    super.dispose();
  }

  // ALAG SE FUNCTION BANAYA HAI LANGUAGE UPDATE KE LIYE
  void _updateLanguageText() {
    setState(() {
      if (currentLanguage == 'hi-IN') {
        _questionText = _findBiggest ? "सबसे बड़ा नंबर फोड़ें!" : "सबसे छोटा नंबर फोड़ें!";
      } else if (currentLanguage == 'ne-NP') {
        _questionText = _findBiggest ? "सबैभन्दा ठूलो नम्बर फुटाउनुहोस्!" : "सबैभन्दा सानो नम्बर फुटाउनुहोस्!";
      } else {
        _questionText = _findBiggest ? "Tap the BIGGEST number!" : "Tap the SMALLEST number!";
      }
    });
    speak(_questionText);
  }

  void _startNewRound() {
    _findBiggest = _random.nextBool();
    _updateLanguageText(); // Calls the language function
  }

  void _spawnBalloon() {
    if (!mounted || _balloons.length > 5) return; 
    setState(() {
      _balloons.add(BalloonItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        number: _random.nextInt(99) + 1, 
        x: _random.nextDouble() * 0.7 + 0.1, 
        y: 1.1, 
        speed: _random.nextDouble() * 0.004 + 0.003,
      ));
    });
  }

  void _updateBalloons() {
    setState(() {
      for (var b in _balloons) {
        b.y -= b.speed; 
      }
      _balloons.removeWhere((b) => b.y < -0.2 && b.state == BalloonState.normal);
    });
  }

  void _handleTap(BalloonItem tappedBalloon) {
    if (tappedBalloon.state != BalloonState.normal) return; 

    List<int> visibleNumbers = _balloons
        .where((b) => b.state == BalloonState.normal)
        .map((b) => b.number)
        .toList();
        
    if (visibleNumbers.isEmpty) return;

    int targetNumber = _findBiggest 
        ? visibleNumbers.reduce(max) 
        : visibleNumbers.reduce(min);

    if (tappedBalloon.number == targetNumber) {
      playSound("success.mp3");
      PlayerStats.addXP(15);
      
      setState(() {
        _score += 10;
        tappedBalloon.state = BalloonState.smiling;
        tappedBalloon.speed = 0.03; 
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _startNewRound();
      });

    } else {
      playSound("tap.mp3"); 
      setState(() {
        tappedBalloon.state = BalloonState.popped;
      });

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
        // YAHAN PAR LANGUAGE CHANGE HONE PAR TEXT UPDATE HOGA
        actions: [LanguageButton(onChanged: () => _updateLanguageText())],
      ),
      body: BackgroundWrapper(
        child: Stack(
          children: [
            ..._balloons.map((balloon) {
              return Positioned(
                left: MediaQuery.of(context).size.width * balloon.x,
                top: MediaQuery.of(context).size.height * balloon.y,
                child: GestureDetector(
                  onTap: () => _handleTap(balloon),
                  child: _buildBalloonWidget(balloon),
                ),
              );
            }).toList(),

            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 100, left: 14, right: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
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

  Widget _buildBalloonWidget(BalloonItem balloon) {
    if (balloon.state == BalloonState.popped) {
      return const SizedBox(
        width: 90, height: 90,
        child: Center(child: Text("💥", style: TextStyle(fontSize: 60))),
      );
    } 
    
    if (balloon.state == BalloonState.smiling) {
      return const SizedBox(
        width: 90, height: 90,
        child: Center(child: Text("😊", style: TextStyle(fontSize: 60))),
      );
    }

    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: balloon.color.withOpacity(0.85),
        borderRadius: const BorderRadius.all(Radius.elliptical(40, 50)),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(color: balloon.color.withOpacity(0.5), blurRadius: 10)
        ]
      ),
      child: Center(
        child: Text(
          getLocalizedNumber(balloon.number),
          style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

enum BalloonState { normal, popped, smiling }

class BalloonItem {
  String id;
  int number;
  double x;
  double y;
  double speed;
  BalloonState state;
  Color color;

  BalloonItem({
    required this.id, required this.number, required this.x, required this.y, required this.speed, this.state = BalloonState.normal,
  }) : color = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent, Colors.purpleAccent][Random().nextInt(5)];
}
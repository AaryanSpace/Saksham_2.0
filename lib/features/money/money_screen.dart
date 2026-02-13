import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});
  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  final Random random = Random();
  late Map<String, dynamic> targetNote;
  List<bool> noteSides = [];
  int? _animatingIndex;

  final List<Map<String, dynamic>> allNotes = [
    {"value": 5, "front": "assets/notes/front/5.jpg", "back": "assets/notes/back/5.jpg"},
    {"value": 10, "front": "assets/notes/front/10.jpg", "back": "assets/notes/back/10.jpg"},
    {"value": 20, "front": "assets/notes/front/20.jpg", "back": "assets/notes/back/20.jpg"},
    {"value": 50, "front": "assets/notes/front/50.jpg", "back": "assets/notes/back/50.jpg"},
    {"value": 100, "front": "assets/notes/front/100.jpg", "back": "assets/notes/back/100.jpg"},
    {"value": 500, "front": "assets/notes/front/500.jpg", "back": "assets/notes/back/500.jpg"},
    {"value": 1000, "front": "assets/notes/front/1000.jpg", "back": "assets/notes/back/1000.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomNote();
  }

  void _pickRandomNote() {
    setState(() {
      targetNote = allNotes[random.nextInt(allNotes.length)];
      noteSides = List.generate(allNotes.length, (index) => random.nextBool());
    });

    speak(currentLanguage == "en-US"
        ? "Find ${targetNote['value']} rupees"
        : (currentLanguage == "hi-IN"
            ? "${targetNote['value']} रुपये खोजें"
            : "${targetNote['value']} रुपैयाँ खोज्नुहोस्"));
  }

  void _handleTap(int index, int value) async {
    setState(() {
      _animatingIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 150));
    _checkAnswer(value);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted)
      setState(() {
        _animatingIndex = null;
      });
  }

  void _checkAnswer(int value) {
    if (value == targetNote['value']) {
      PlayerStats.addXP(50);
      speak("Correct!");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Correct! +50 XP",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppTheme.accentGreen,
          duration: Duration(milliseconds: 500)));
      Future.delayed(const Duration(milliseconds: 1000), _pickRandomNote);
    } else {
      speak("Try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money Practice"),
        actions: [
          LanguageButton(
              onChanged: () => setState(() {
                    _pickRandomNote();
                  }))
        ],
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currentLanguage == "en-US"
                          ? "Find: ₹${targetNote['value']}"
                          : "खोजें: ₹${getLocalizedNumber(targetNote['value'])}",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.8,
                      child: Image.asset(targetNote['front'],
                          height: 60, fit: BoxFit.contain),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: allNotes.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 35),
                itemBuilder: (ctx, i) {
                  final note = allNotes[i];
                  final bool showFront = noteSides[i];
                  final String imagePath =
                      showFront ? note['front'] : note['back'];
                  final bool isAnimating = _animatingIndex == i;

                  return Center(
                    child: GestureDetector(
                      onTap: () => _handleTap(i, note['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.identity()
                          ..scale(isAnimating ? 1.15 : 1.0)
                          ..rotateZ(
                              isAnimating ? (i % 2 == 0 ? 0.05 : -0.05) : 0),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 15))
                            ]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              imagePath,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (c, o, s) => const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.white54),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "₹${getLocalizedNumber(note['value'])}",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black54, blurRadius: 10)
                                  ]),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
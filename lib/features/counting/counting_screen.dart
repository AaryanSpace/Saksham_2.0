import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/globals.dart';
import '../../core/widgets/background_wrapper.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/language_button.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});
  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  int start = 1;
  int targetNumber = 0;
  final Random random = Random();
  bool isLearningMode = true;
  Map<int, Color> cardColors = {};

  @override
  void initState() {
    super.initState();
    _pickRandomTarget();
  }

  void _pickRandomTarget() {
    setState(() {
      cardColors.clear();
      targetNumber = start + random.nextInt(10);
    });
    if (!isLearningMode) {
      speak(currentLanguage == "en-US"
          ? "Find $targetNumber"
          : getLocalizedNumber(targetNumber));
    }
  }

  List<int> get currentNumbers => List.generate(10, (index) => start + index);

  void onNumberTap(int number) async {
    if (isLearningMode) {
      speak(getLocalizedNumber(number));
      setState(() =>
          cardColors[number] = AppTheme.accentPink.withValues(alpha: 0.5));
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => cardColors.remove(number));
    } else {
      if (number == targetNumber) {
        PlayerStats.addXP(10);
        setState(() => cardColors[number] = AppTheme.accentGreen);
        speak("Correct!");
        await Future.delayed(const Duration(milliseconds: 1000));
        _pickRandomTarget();
      } else {
        setState(() => cardColors[number] = Colors.redAccent);
        speak("Try again");
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() => cardColors.remove(number));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
            "${getLocalizedNumber(start)} - ${getLocalizedNumber(start + 9)}",
            style: const TextStyle( fontSize: 30,fontWeight: FontWeight.bold)),
        actions: [LanguageButton(onChanged: () => setState(() {}))],
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () => Navigator.pop(context)),
      ),
      body: BackgroundWrapper(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLearningMode
                          ? (currentLanguage == "en-US"
                              ? "Tap to Learn"
                              : "सीखें")
                          : (currentLanguage == "en-US"
                              ? "Find: $targetNumber"
                              : "खोजें: ${getLocalizedNumber(targetNumber)}"),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Switch(
                      value: !isLearningMode,
                      onChanged: (val) => setState(() {
                        isLearningMode = !val;
                        _pickRandomTarget();
                      }),
                      activeThumbColor: AppTheme.accentYellow,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.85,
                ),
                itemCount: currentNumbers.length,
                itemBuilder: (context, index) {
                  final number = currentNumbers[index];
                  final bool isSelected = cardColors.containsKey(number);
                  return GlassCard(
                    onTap: () => onNumberTap(number),
                    color: isSelected ? cardColors[number] : null,
                    child: Center(
                      child: Text(
                        getLocalizedNumber(number),
                        style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.blueAccent,
                                  blurRadius: 15)
                            ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                      child: GlassCard(
                          onTap: () => setState(() {
                                if (start > 1) start -= 10;
                                _pickRandomTarget();
                              }),
                          child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                  child: Icon(Icons.arrow_back_ios,
                                      color: Colors.white))))),
                  const SizedBox(width: 20),
                  Expanded(
                      child: GlassCard(
                          onTap: () => setState(() {
                                if (start < 91) start += 10;
                                _pickRandomTarget();
                              }),
                          child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(
                                  child: Icon(Icons.arrow_forward_ios,
                                      color: Colors.white))))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
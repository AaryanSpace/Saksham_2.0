import 'package:flutter/material.dart';
import '../utils/globals.dart';


/// A custom widget that toggles the app's language state 
/// and updates the Text-to-Speech (TTS) voice accordingly.
/// Currently supports English, Hindi, and Nepali.
class LanguageButton extends StatelessWidget {
  final VoidCallback onChanged;
  const LanguageButton({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: InkWell(
          onTap: () {
            if (currentLanguage == "en-US") {
              currentLanguage = "hi-IN";
              speak("हिंदी");
            } else if (currentLanguage == "hi-IN") {
              currentLanguage = "ne-NP";
              speak("नेपाली");
            } else {
              currentLanguage = "en-US";
              speak("English");
            }
            onChanged();
          },
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
    );
  }
}
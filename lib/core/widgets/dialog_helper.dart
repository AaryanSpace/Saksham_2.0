import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/globals.dart'; // To access currentLanguage & tts

Future<void> showEntryDialog(BuildContext context, String title, String message, Widget targetScreen) async {
  bool? proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Force user to choose
    builder: (context) => Stack(
      children: [
        // 1. BLUR EFFECT
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
        ),
        
        // 2. THE DIALOG BOX
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
                // --- USE YOUR APP THEME GRADIENT HERE ---
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E3192), // Dark Blue (Your App's Main Color)
                    Color(0xFF1BFFFF), // Cyan (Your App's Accent)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // ----------------------------------------
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1BFFFF).withValues(alpha: 0.3), // Cyan glow
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TOP ICON ---
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  // --- TITLE ---
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- MESSAGE ---
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- ACTION BUTTONS ---
                  Row(
                    children: [
                      // NO BUTTON (Outlined)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text(
                            currentLanguage == "hi-IN" ? "नहीं (No)" : currentLanguage == "ne-NP" ? "होइन (No)" : "No",
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // YES BUTTON (Filled Green)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 121, 247, 3),
                            foregroundColor: const Color(0xFF003300), // Dark Green Text
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                          ),
                          child: Text(
                            currentLanguage == "hi-IN" ? "हाँ (Yes)" : currentLanguage == "ne-NP" ? "हो (Yes)" : "Start",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Logic to navigate if they clicked Yes
  if (proceed == true) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)).then((_) {
      tts.stop();
    });
  }
}
import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _glowOrb(Colors.purple),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _glowOrb(Colors.blueAccent),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _glowOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 100)
          ]),
    );
  }
}
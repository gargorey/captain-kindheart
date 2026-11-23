import 'package:flutter/material.dart';

/// Cheerful palette from the brief: sky blue, teal, warm yellow, coral,
/// cream and soft green. Deliberately no police-style navy/red pairing.
abstract final class AppColors {
  static const Color sky = Color(0xFF6EC6FF);
  static const Color skyDeep = Color(0xFF3FA7E8);
  static const Color teal = Color(0xFF2BB3A6);
  static const Color tealDeep = Color(0xFF1C8C82);
  static const Color yellow = Color(0xFFFFD166);
  static const Color coral = Color(0xFFFF8A73);
  static const Color cream = Color(0xFFFFF8EC);
  static const Color green = Color(0xFF9ADE7B);
  static const Color greenDeep = Color(0xFF5DB85C);
  static const Color lilac = Color(0xFFC3B1F5);
  static const Color ink = Color(0xFF263445);
  static const Color inkSoft = Color(0xFF5B6B7D);
  static const Color card = Colors.white;
  static const Color skin = Color(0xFFF2C29B);

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3F5FF), cream],
  );
}

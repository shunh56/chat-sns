import 'package:flutter/material.dart';

class AppColors {
  static const primaryPink = Color(0xFFFF006E);
  static const primaryOrange = Color(0xFFFB5607);
  static const primaryYellow = Color(0xFFFFBE0B);
  static const primaryPurple = Color(0xFF8338EC);
  static const primaryBlue = Color(0xFF3A86FF);

  static const backgroundDark = Color(0xFF0A0A0A);
  static const backgroundMedium = Color(0xFF1A0A1A);
  static const backgroundLight = Color(0xFF0F1419);

  static const glassBackground = Color(0x14FFFFFF);
  static const glassBorder = Color(0x26FFFFFF);

  static List<Color> get cosmicGradient => [
        primaryPink,
        primaryOrange,
        primaryYellow,
        primaryPurple,
        primaryBlue,
      ];

  static LinearGradient get titleGradient => const LinearGradient(
        colors: [primaryPink, primaryPurple, primaryBlue, primaryYellow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get planetGradient => const LinearGradient(
        colors: [primaryPink, primaryPurple, primaryBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppConstants {
  static const double phoneWidth = 375.0;
  static const double phoneHeight = 812.0;
  static const double borderRadius = 40.0;
  static const double containerPadding = 3.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration slowAnimation = Duration(milliseconds: 1200);

  // Sizes
  static const double primaryPlanetSize = 120.0;
  static const double secondaryPlanetSize = 80.0;
  static const double tertiaryPlanetSize = 60.0;

  // Star counts
  static const int starCount = 60;
}

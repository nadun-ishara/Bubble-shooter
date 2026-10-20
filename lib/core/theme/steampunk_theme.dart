import 'package:flutter/material.dart';

class SteampunkTheme {
  // Rich Victorian & Clockwork Palette
  static const Color darkBrassBg = Color(0xFF191310);
  static const Color deepBronzeBg = Color(0xFF241711);
  static const Color mahoganyPanel = Color(0xFF3E2723);
  static const Color richCopper = Color(0xFF8D5B4C);
  static const Color polishedBrass = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFFFD54F);
  static const Color lightAmber = Color(0xFFFFECB3);
  static const Color antiqueDark = Color(0xFF140D09);
  static const Color steamGlow = Color(0xFF81D4FA);
  static const Color dangerRuby = Color(0xFFEF5350);

  // Gradients
  static const LinearGradient brassButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF9C4),
      Color(0xFFFFD54F),
      Color(0xFFDAA520),
      Color(0xFFB8860B),
    ],
    stops: [0.0, 0.25, 0.65, 1.0],
  );

  static const LinearGradient brassDarkButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5D4037),
      Color(0xFF3E2723),
      Color(0xFF271A15),
    ],
  );

  static const LinearGradient plaqueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4E342E),
      Color(0xFF2B1D15),
      Color(0xFF1A110B),
    ],
  );

  // Box Shadows
  static const List<BoxShadow> brassGlowShadow = [
    BoxShadow(
      color: Color(0x66FFD54F),
      blurRadius: 16,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black87,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkDepthsShadow = [
    BoxShadow(
      color: Colors.black87,
      blurRadius: 18,
      spreadRadius: 2,
      offset: Offset(0, 6),
    ),
  ];
}

import 'dart:math';
import 'package:flutter/material.dart';

enum BubbleType {
  ruby,
  sapphire,
  emerald,
  amber,
  amethyst,
  aquamarine;

  /// Primary vibrant color
  Color get primaryColor {
    switch (this) {
      case BubbleType.ruby:
        return const Color(0xFFE53935);
      case BubbleType.sapphire:
        return const Color(0xFF1E88E5);
      case BubbleType.emerald:
        return const Color(0xFF43A047);
      case BubbleType.amber:
        return const Color(0xFFFFA000);
      case BubbleType.amethyst:
        return const Color(0xFF8E24AA);
      case BubbleType.aquamarine:
        return const Color(0xFF00ACC1);
    }
  }

  /// Radial gradient colors (highlight -> midtone -> deep jewel shadow)
  List<Color> get gradientColors {
    switch (this) {
      case BubbleType.ruby:
        return const [
          Color(0xFFFF8A80),
          Color(0xFFE53935),
          Color(0xFFB71C1C),
          Color(0xFF5D0B0B),
        ];
      case BubbleType.sapphire:
        return const [
          Color(0xFF82B1FF),
          Color(0xFF2979FF),
          Color(0xFF0D47A1),
          Color(0xFF061E47),
        ];
      case BubbleType.emerald:
        return const [
          Color(0xFFB9F6CA),
          Color(0xFF00E676),
          Color(0xFF1B5E20),
          Color(0xFF082D0E),
        ];
      case BubbleType.amber:
        return const [
          Color(0xFFFFE57F),
          Color(0xFFFFD600),
          Color(0xFFFF6F00),
          Color(0xFF4E2600),
        ];
      case BubbleType.amethyst:
        return const [
          Color(0xFFEA80FC),
          Color(0xFFAA00FF),
          Color(0xFF4A148C),
          Color(0xFF240445),
        ];
      case BubbleType.aquamarine:
        return const [
          Color(0xFF84FFFF),
          Color(0xFF00E5FF),
          Color(0xFF006064),
          Color(0xFF002A2C),
        ];
    }
  }

  /// Outer magical glow color
  Color get glowColor {
    switch (this) {
      case BubbleType.ruby:
        return const Color(0x80FF5252);
      case BubbleType.sapphire:
        return const Color(0x80448AFF);
      case BubbleType.emerald:
        return const Color(0x8069F0AE);
      case BubbleType.amber:
        return const Color(0x80FFD740);
      case BubbleType.amethyst:
        return const Color(0x80E040FB);
      case BubbleType.aquamarine:
        return const Color(0x8018FFFF);
    }
  }

  /// Pick a random bubble type from active types in play
  static BubbleType random([Random? rng, List<BubbleType>? pool]) {
    final r = rng ?? Random();
    final list = (pool != null && pool.isNotEmpty) ? pool : BubbleType.values;
    return list[r.nextInt(list.length)];
  }
}

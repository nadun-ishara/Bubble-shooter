import 'dart:math';
import 'package:flutter/material.dart';

enum BubbleType {
  ruby, // Red / Garnet
  aquamarine, // Teal / Cyan
  emerald, // Radiant Green
  amber, // Topaz / Gold
  amethyst, // Purple / Violet
  sapphire; // Deep Cobalt Blue

  String get displayName {
    switch (this) {
      case BubbleType.ruby:
        return 'Ruby';
      case BubbleType.aquamarine:
        return 'Aquamarine';
      case BubbleType.emerald:
        return 'Emerald';
      case BubbleType.amber:
        return 'Amber';
      case BubbleType.amethyst:
        return 'Amethyst';
      case BubbleType.sapphire:
        return 'Sapphire';
    }
  }

  Color get primaryColor {
    switch (this) {
      case BubbleType.ruby:
        return const Color(0xFFEF5350);
      case BubbleType.aquamarine:
        return const Color(0xFF26C6DA);
      case BubbleType.emerald:
        return const Color(0xFF66BB6A);
      case BubbleType.amber:
        return const Color(0xFFFFA726);
      case BubbleType.amethyst:
        return const Color(0xFFAB47BC);
      case BubbleType.sapphire:
        return const Color(0xFF42A5F5);
    }
  }

  Color get glowColor {
    switch (this) {
      case BubbleType.ruby:
        return const Color(0x99EF5350);
      case BubbleType.aquamarine:
        return const Color(0x9926C6DA);
      case BubbleType.emerald:
        return const Color(0x9966BB6A);
      case BubbleType.amber:
        return const Color(0x99FFA726);
      case BubbleType.amethyst:
        return const Color(0x99AB47BC);
      case BubbleType.sapphire:
        return const Color(0x9942A5F5);
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case BubbleType.ruby:
        return const [
          Color(0xFFFFCDD2),
          Color(0xFFE53935),
          Color(0xFFC62828),
          Color(0xFF4A0E0E),
        ];
      case BubbleType.aquamarine:
        return const [
          Color(0xFFE0F7FA),
          Color(0xFF00BCD4),
          Color(0xFF00838F),
          Color(0xFF00363A),
        ];
      case BubbleType.emerald:
        return const [
          Color(0xFFE8F5E9),
          Color(0xFF43A047),
          Color(0xFF2E7D32),
          Color(0xFF1B5E20),
        ];
      case BubbleType.amber:
        return const [
          Color(0xFFFFF8E1),
          Color(0xFFFFB300),
          Color(0xFFFF8F00),
          Color(0xFFE65100),
        ];
      case BubbleType.amethyst:
        return const [
          Color(0xFFF3E5F5),
          Color(0xFF8E24AA),
          Color(0xFF6A1B9A),
          Color(0xFF38006B),
        ];
      case BubbleType.sapphire:
        return const [
          Color(0xFFE3F2FD),
          Color(0xFF1E88E5),
          Color(0xFF1565C0),
          Color(0xFF0D47A1),
        ];
    }
  }

  static BubbleType random([Random? random, List<BubbleType>? pool]) {
    final rng = random ?? Random();
    final source = (pool != null && pool.isNotEmpty) ? pool : values;
    return source[rng.nextInt(source.length)];
  }
}

import 'package:flutter/services.dart';

class AudioHelper {
  static bool soundEnabled = true;

  static void playPop() {
    if (!soundEnabled) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playFire() {
    if (!soundEnabled) return;
    try {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playSwap() {
    if (!soundEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static void playBounce() {
    if (!soundEnabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static void playDefeat() {
    if (!soundEnabled) return;
    try {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  static void playVictory() {
    if (!soundEnabled) return;
    try {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }
}

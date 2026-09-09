import 'package:flutter/services.dart';

/// Safe haptic feedback wrapper.
/// Slap: heavy impact.
/// Correct guess: light impact.
class HapticUtils {
  HapticUtils._();

  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignored on unsupported platforms
    }
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignored on unsupported platforms
    }
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Ignored on unsupported platforms
    }
  }

  static Future<void> doubleSlap() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Ignored on unsupported platforms
    }
  }
}

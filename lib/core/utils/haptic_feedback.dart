import 'package:flutter/services.dart';

class HapticHelper {
  /// Light haptic feedback
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently handle any errors
    }
  }

  /// Medium haptic feedback
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently handle any errors
    }
  }

  /// Heavy haptic feedback
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently handle any errors
    }
  }

  /// Selection haptic feedback
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently handle any errors
    }
  }

  /// Success haptic feedback (light + medium combination)
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently handle any errors
    }
  }

  /// Error haptic feedback (heavy + light combination)
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently handle any errors
    }
  }
}

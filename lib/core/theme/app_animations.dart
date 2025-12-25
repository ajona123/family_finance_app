// ============================================================================
// FILE: lib/core/theme/app_animations.dart
// DESCRIPTION: Professional animation system
// PRINCIPLE: Subtle, smooth, purposeful (no excessive motion)
// ============================================================================

import 'package:flutter/material.dart';

/// Professional animation system
/// Based on Material Design motion principles
/// Optimized for financial apps (no playful bouncing)
class AppAnimations {
  AppAnimations._();

  // ========================================
  // DURATION CONSTANTS
  // Standard animation durations
  // ========================================
  
  /// 100ms - Instant feedback (micro-interactions)
  static const Duration instant = Duration(milliseconds: 100);
  
  /// 150ms - Very fast (hover states, ripples)
  static const Duration veryFast = Duration(milliseconds: 150);
  
  /// 200ms - Fast (button press, state changes)
  static const Duration fast = Duration(milliseconds: 200);
  
  /// 250ms - Standard (most UI transitions)
  static const Duration standard = Duration(milliseconds: 250);
  
  /// 300ms - Medium (page transitions, dialogs)
  static const Duration medium = Duration(milliseconds: 300);
  
  /// 400ms - Slow (complex animations)
  static const Duration slow = Duration(milliseconds: 400);
  
  /// 500ms - Very slow (elaborate transitions)
  static const Duration verySlow = Duration(milliseconds: 500);
  
  // ========================================
  // EASING CURVES
  // Professional motion curves
  // ========================================
  
  /// Standard ease - Smooth in and out
  static const Curve ease = Curves.easeInOut;
  
  /// Ease out - Starts fast, ends smooth (most common)
  static const Curve easeOut = Curves.easeOut;
  
  /// Ease in - Starts smooth, ends fast
  static const Curve easeIn = Curves.easeIn;
  
  /// Ease in out - Smooth acceleration and deceleration
  static const Curve easeInOut = Curves.easeInOutCubic;
  
  /// Sharp - Quick movement (for dismissals)
  static const Curve sharp = Curves.easeInExpo;
  
  /// Emphasized - Material 3 emphasized curve
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  
  /// Decelerate - Fast start, slow end (for entering elements)
  static const Curve decelerate = Curves.decelerate;
  
  /// Accelerate - Slow start, fast end (for exiting elements)
  static const Curve accelerate = Curves.fastOutSlowIn;
}

// ============================================================================
// PAGE TRANSITION SYSTEM
// Professional page transitions
// ============================================================================

class AppPageTransitions {
  AppPageTransitions._();

  /// Fade transition for pages
  static PageRouteBuilder fade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
  
  /// Slide from right (standard push)
  static PageRouteBuilder slideFromRight<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppAnimations.emphasized),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Slide from bottom (modal style)
  static PageRouteBuilder slideFromBottom<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppAnimations.decelerate),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  /// Fade + Scale (elegant)
  static PageRouteBuilder fadeScale<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: AppAnimations.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

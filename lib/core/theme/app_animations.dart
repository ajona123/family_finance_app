import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppAnimations {
  // Card shadow for normal state
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Card shadow with pressed state variation
  static List<BoxShadow> cardShadowPressed(bool isPressed) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return cardShadow;
  }

  // Elevation shadow
  static List<BoxShadow> get elevationShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Soft shadow
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Strong shadow
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Primary gradient shadow
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Income gradient shadow
  static List<BoxShadow> get incomeShadow => [
    BoxShadow(
      color: AppColors.income.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Expense gradient shadow
  static List<BoxShadow> get expenseShadow => [
    BoxShadow(
      color: AppColors.expense.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Standard duration
  static const Duration standardDuration = Duration(milliseconds: 300);
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Standard curve
  static const Curve standardCurve = Curves.easeInOutCubic;
}

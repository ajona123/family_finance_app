import 'package:flutter/material.dart';

class AppColors {
  // 🎨 PRIMARY GRADIENT (Biru → Ungu)
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  // 💚 INCOME GRADIENT (Hijau fresh)
  static const incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  // ❤️ EXPENSE GRADIENT (Merah soft)
  static const expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
  );

  // 🌅 SUNSET GRADIENT (Oren → Pink)
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
  );

  // 🌊 OCEAN GRADIENT (Biru laut)
  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  // 🎯 SOLID COLORS
  static const primary = Color(0xFF667EEA);
  static const primaryDark = Color(0xFF764BA2);

  static const income = Color(0xFF38EF7D);
  static const expense = Color(0xFFFF6B6B);

  static const background = Color(0xFFF8F9FA);
  static const cardBackground = Colors.white;

  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textTertiary = Color(0xFFB2BEC3);

  static const border = Color(0xFFDFE6E9);
  static const divider = Color(0xFFECF0F1);

  static const success = Color(0xFF00B894);
  static const warning = Color(0xFFFDCB6E);
  static const error = Color(0xFFD63031);

  // 🎭 CATEGORY COLORS (untuk icon background)
  static const categoryColors = [
    Color(0xFFFFE5E5), // Pink muda
    Color(0xFFE5F5FF), // Biru muda
    Color(0xFFFFF5E5), // Kuning muda
    Color(0xFFE5FFE9), // Hijau muda
    Color(0xFFF5E5FF), // Ungu muda
    Color(0xFFFFE5F5), // Magenta muda
  ];

  // 🌑 SHADOW COLORS
  static final shadowLight = Colors.black.withOpacity(0.05);
  static final shadowMedium = Colors.black.withOpacity(0.08);
  static final shadowHeavy = Colors.black.withOpacity(0.12);
}
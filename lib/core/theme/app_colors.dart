// ============================================================================
// FILE: lib/core/theme/app_colors.dart
// DESCRIPTION: Enterprise-grade color system for Family Finance App
// INSPIRED BY: Revolut, N26, Stripe Dashboard
// ============================================================================

import 'package:flutter/material.dart';

/// Professional color system with sophisticated palette
/// Designed for financial management applications
class AppColors {
  AppColors._();

  // ========================================
  // PRIMARY PALETTE - Deep Slate Blue
  // Represents: Trust, Stability, Professionalism
  // ========================================
  
  /// Main primary color - Deep slate for trustworthy feel
  static const Color primary = Color(0xFF0F172A);
  
  /// Lighter variant - For hover states and variations
  static const Color primaryLight = Color(0xFF1E293B);
  
  /// Darker variant - For pressed states
  static const Color primaryDark = Color(0xFF020617);
  
  /// Ultra light - For subtle backgrounds
  static const Color primaryUltraLight = Color(0xFF334155);
  
  // ========================================
  // SECONDARY PALETTE - Sophisticated Teal
  // Represents: Innovation, Growth, Technology
  // ========================================
  
  /// Main secondary color - Deep teal
  static const Color secondary = Color(0xFF0891B2);
  
  /// Lighter variant
  static const Color secondaryLight = Color(0xFF06B6D4);
  
  /// Darker variant
  static const Color secondaryDark = Color(0xFF0E7490);
  
  /// Background tint
  static const Color secondaryBackground = Color(0xFFECFEFF);
  
  // ========================================
  // ACCENT PALETTE - Premium Indigo
  // Represents: Premium, Quality, Excellence
  // ========================================
  
  /// Main accent color - For CTAs and highlights
  static const Color accent = Color(0xFF6366F1);
  
  /// Lighter variant - For hover effects
  static const Color accentLight = Color(0xFF818CF8);
  
  /// Darker variant - For pressed states
  static const Color accentDark = Color(0xFF4F46E5);
  
  /// Background tint
  static const Color accentBackground = Color(0xFFEEF2FF);
  
  // ========================================
  // NEUTRAL PALETTE - Professional Grays
  // Foundation: 10-step gray scale for maximum flexibility
  // ========================================
  
  /// Almost white - Subtle backgrounds
  static const Color neutral50 = Color(0xFFFAFAFA);
  
  /// Very light gray - Card backgrounds
  static const Color neutral100 = Color(0xFFF5F5F5);
  
  /// Light gray - Borders, dividers
  static const Color neutral200 = Color(0xFFE5E5E5);
  
  /// Medium light gray - Disabled states
  static const Color neutral300 = Color(0xFFD4D4D4);
  
  /// Medium gray - Icons
  static const Color neutral400 = Color(0xFFA3A3A3);
  
  /// Base gray - Secondary text
  static const Color neutral500 = Color(0xFF737373);
  
  /// Medium dark gray - Body text
  static const Color neutral600 = Color(0xFF525252);
  
  /// Dark gray - Headings
  static const Color neutral700 = Color(0xFF404040);
  
  /// Very dark gray - Strong headings
  static const Color neutral800 = Color(0xFF262626);
  
  /// Almost black - Primary text
  static const Color neutral900 = Color(0xFF171717);
  
  // ========================================
  // FINANCIAL STATUS COLORS
  // Refined colors for income/expense/transfer
  // ========================================
  
  // INCOME - Sophisticated Green (Success)
  /// Main income color
  static const Color income = Color(0xFF10B981);
  
  /// Lighter income - For hover
  static const Color incomeLight = Color(0xFF34D399);
  
  /// Darker income - For emphasis
  static const Color incomeDark = Color(0xFF059669);
  
  /// Income background tint
  static const Color incomeBackground = Color(0xFFECFDF5);
  
  /// Income border
  static const Color incomeBorder = Color(0xFFA7F3D0);
  
  // EXPENSE - Refined Red (Danger)
  /// Main expense color
  static const Color expense = Color(0xFFEF4444);
  
  /// Lighter expense - For hover
  static const Color expenseLight = Color(0xFFF87171);
  
  /// Darker expense - For emphasis
  static const Color expenseDark = Color(0xFFDC2626);
  
  /// Expense background tint
  static const Color expenseBackground = Color(0xFFFEF2F2);
  
  /// Expense border
  static const Color expenseBorder = Color(0xFFFECACA);
  
  // TRANSFER - Professional Blue (Info)
  /// Main transfer color
  static const Color transfer = Color(0xFF3B82F6);
  
  /// Lighter transfer - For hover
  static const Color transferLight = Color(0xFF60A5FA);
  
  /// Darker transfer - For emphasis
  static const Color transferDark = Color(0xFF2563EB);
  
  /// Transfer background tint
  static const Color transferBackground = Color(0xFFEFF6FF);
  
  /// Transfer border
  static const Color transferBorder = Color(0xFFBAE6FD);
  
  // ========================================
  // SEMANTIC STATUS COLORS
  // For alerts, notifications, status indicators
  // ========================================
  
  /// Success state
  static const Color success = Color(0xFF10B981);
  static const Color successBackground = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  
  /// Warning state
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);
  
  /// Error state
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  
  /// Info state
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBackground = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBAE6FD);
  
  // ========================================
  // SURFACE & BACKGROUND COLORS
  // Layered approach for depth
  // ========================================
  
  /// Main background - Subtle gray for eye comfort
  static const Color background = Color(0xFFFAFAFA);
  
  /// Main surface - Pure white for cards
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Card background - Slightly tinted white for cards
  static const Color cardBackground = Color(0xFFFAFAFA);
  
  /// Elevated surface - Cards with elevation
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  /// Overlay surface - For modals, dialogs
  static const Color surfaceOverlay = Color(0xFFF5F5F5);
  
  /// Tinted surface - For special sections
  static const Color surfaceTinted = Color(0xFFF8FAFC);
  
  // ========================================
  // TEXT COLORS - Optimized Contrast
  // WCAG AA compliant
  // ========================================
  
  /// Primary text - High emphasis (90% opacity equivalent)
  static const Color textPrimary = Color(0xFF0F172A);
  
  /// Secondary text - Medium emphasis (70% opacity equivalent)
  static const Color textSecondary = Color(0xFF64748B);
  
  /// Tertiary text - Low emphasis (50% opacity equivalent)
  static const Color textTertiary = Color(0xFF94A3B8);
  
  /// Disabled text - Minimal emphasis (38% opacity equivalent)
  static const Color textDisabled = Color(0xFFCBD5E1);
  
  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Text on dark surfaces
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  /// Text on colored backgrounds
  static const Color textOnColor = Color(0xFFFFFFFF);
  
  // ========================================
  // BORDER & DIVIDER COLORS
  // Subtle separations
  // ========================================
  
  /// Main border color - Standard borders
  static const Color border = Color(0xFFE2E8F0);
  
  /// Light border - Subtle separations
  static const Color borderLight = Color(0xFFF1F5F9);
  
  /// Dark border - Emphasized separations
  static const Color borderDark = Color(0xFFCBD5E1);
  
  /// Divider lines
  static const Color divider = Color(0xFFE2E8F0);
  
  /// Focus border - For input fields
  static const Color borderFocus = Color(0xFF6366F1);
  
  // ========================================
  // INTERACTIVE STATES
  // For buttons and interactive elements
  // ========================================
  
  /// Hover overlay (8% opacity)
  static const Color hoverOverlay = Color(0x14000000);
  
  /// Pressed overlay (12% opacity)
  static const Color pressedOverlay = Color(0x1F000000);
  
  /// Focus overlay (12% opacity)
  static const Color focusOverlay = Color(0x1F6366F1);
  
  /// Disabled overlay (38% opacity)
  static const Color disabledOverlay = Color(0x61000000);
  
  // ========================================
  // SHADOW COLORS
  // Elevation system
  // ========================================
  
  /// Light shadow - Subtle elevation
  static const Color shadowLight = Color(0x0A000000); // 4% opacity
  
  /// Medium shadow - Standard elevation
  static const Color shadowMedium = Color(0x14000000); // 8% opacity
  
  /// Strong shadow - High elevation
  static const Color shadowStrong = Color(0x1F000000); // 12% opacity
  
  /// Extra strong shadow - Modal elevation
  static const Color shadowExtraStrong = Color(0x29000000); // 16% opacity
  
  // ========================================
  // GRADIENT DEFINITIONS
  // Subtle & Professional gradients
  // ========================================
  
  /// Primary gradient - Deep slate
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Accent gradient - Premium indigo
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF818CF8),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Income gradient - Success
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF34D399),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Expense gradient - Danger
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFF87171),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Card gradient - Subtle depth
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFDFDFD),
    ],
    stops: [0.0, 1.0],
  );
  
  /// Hero gradient - For main balance display
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
      Color(0xFF334155),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // ========================================
  // SHIMMER/SKELETON LOADING COLORS
  // For loading states
  // ========================================
  
  /// Shimmer base color
  static const Color shimmerBase = Color(0xFFE5E5E5);
  
  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  
  /// Shimmer gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE5E5E5),
      Color(0xFFF5F5F5),
      Color(0xFFE5E5E5),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // ========================================
  // CHART COLORS
  // For data visualization
  // ========================================
  
  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
  ];
  
  // ========================================
  // CATEGORY COLORS
  // For transaction categories
  // ========================================
  
  static const Color categoryFood = Color(0xFFEF4444);
  static const Color categoryTransport = Color(0xFF3B82F6);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryEntertainment = Color(0xFF8B5CF6);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryEducation = Color(0xFFF59E0B);
  static const Color categoryBills = Color(0xFF64748B);
  static const Color categoryOthers = Color(0xFF6366F1);
}
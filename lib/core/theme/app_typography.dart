// ============================================================================
// FILE: lib/core/theme/app_typography.dart
// DESCRIPTION: Enterprise-grade typography system
// FONT: Poppins (or Inter/Outfit as alternative)
// HIERARCHY: Display > Heading > Body > Label > Caption
// ============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Professional typography system with clear hierarchy
/// Optimized for financial data and readability
class AppTypography {
  AppTypography._();

  // ========================================
  // FONT CONFIGURATION
  // ========================================
  
  /// Primary font family
  static const String fontFamily = 'Poppins';
  
  // ========================================
  // FONT WEIGHTS
  // Professional weight scale
  // ========================================
  
  static const FontWeight light = FontWeight.w300;      // 300
  static const FontWeight regular = FontWeight.w400;    // 400
  static const FontWeight medium = FontWeight.w500;     // 500
  static const FontWeight semiBold = FontWeight.w600;   // 600
  static const FontWeight bold = FontWeight.w700;       // 700
  static const FontWeight extraBold = FontWeight.w800;  // 800
  
  // ========================================
  // DISPLAY STYLES
  // For hero sections, large balance displays
  // Usage: Welcome screens, main balance hero
  // ========================================
  
  /// Extra large display - 48px
  /// Usage: Main app hero, splash screen
  static const TextStyle display1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );
  
  /// Large display - 40px
  /// Usage: Page hero titles
  static const TextStyle display2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );
  
  /// Medium display - 36px
  /// Usage: Section heroes
  static const TextStyle display3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
  
  // ========================================
  // HEADING STYLES
  // For section titles and card headers
  // ========================================
  
  /// Heading 1 - 32px
  /// Usage: Main page titles
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
  
  /// Heading 2 - 28px
  /// Usage: Section titles
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );
  
  /// Heading 3 - 24px
  /// Usage: Card titles, modal titles
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Heading 4 - 20px
  /// Usage: Sub-section titles
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Heading 5 - 18px
  /// Usage: List group titles
  static const TextStyle h5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.45,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Heading 6 - 16px
  /// Usage: Small section titles
  static const TextStyle h6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  // ========================================
  // BODY TEXT STYLES
  // For main content, descriptions
  // ========================================
  
  /// Body Large - 16px
  /// Usage: Main content, primary descriptions
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Body Large Medium - 16px (Medium weight)
  /// Usage: Emphasized body text
  static const TextStyle bodyLargeMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Body Medium - 14px
  /// Usage: Standard body text, descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Body Medium Semi - 14px (Medium weight)
  /// Usage: Slightly emphasized text
  static const TextStyle bodyMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Body Small - 13px
  /// Usage: Secondary descriptions, helper text
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );
  
  // ========================================
  // LABEL STYLES
  // For input labels, tags, badges
  // ========================================
  
  /// Label Large - 14px
  /// Usage: Form labels, filter labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );
  
  /// Label Medium - 12px
  /// Usage: Small labels, input hints
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );
  
  /// Label Small - 11px
  /// Usage: Tiny labels, badges
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );
  
  /// Label Small Semibold - 11px
  /// Usage: Status badges, tags
  static const TextStyle labelSmallSemibold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.3,
    color: AppColors.textSecondary,
  );
  
  // ========================================
  // CAPTION STYLES
  // For timestamps, footnotes, metadata
  // ========================================
  
  /// Caption Regular - 12px
  /// Usage: Timestamps, metadata
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textTertiary,
  );
  
  /// Caption Medium - 12px
  /// Usage: Emphasized captions
  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textTertiary,
  );
  
  /// Caption Small - 10px
  /// Usage: Very small footnotes
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textTertiary,
  );
  
  // ========================================
  // BUTTON TEXT STYLES
  // For interactive elements
  // ========================================
  
  /// Button Large - 16px
  /// Usage: Primary CTAs, main buttons
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.2,
  );
  
  /// Button Medium - 14px
  /// Usage: Standard buttons
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.2,
  );
  
  /// Button Small - 12px
  /// Usage: Small action buttons
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.3,
  );
  
  // ========================================
  // SPECIAL PURPOSE STYLES
  // Financial-specific text styles
  // ========================================
  
  /// Price Display - 32px
  /// Usage: Transaction amounts, balance display
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
  
  /// Price Large - 40px
  /// Usage: Main balance hero display
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: bold,
    height: 1.1,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );
  
  /// Price Extra Large - 48px
  /// Usage: Hero balance display on home
  static const TextStyle priceXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: bold,
    height: 1.1,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
  );
  
  /// Price Medium - 24px
  /// Usage: Card balance displays
  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );
  
  /// Price Small - 18px
  /// Usage: List item amounts
  static const TextStyle priceSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  
  /// Overline - 10px Uppercase
  /// Usage: Section overlines, category labels
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: semiBold,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
  
  /// Overline Large - 11px Uppercase
  /// Usage: Larger overlines
  static const TextStyle overlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );
  
  // ========================================
  // NUMBER & CURRENCY STYLES
  // Monospace-like for better number alignment
  // ========================================
  
  /// Number Display - 20px
  /// Usage: Stats, metrics
  static const TextStyle number = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  /// Number Large - 28px
  /// Usage: Large stats
  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  /// Number Small - 14px
  /// Usage: Small numbers, percentages
  static const TextStyle numberSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  // ========================================
  // LINK STYLES
  // For clickable text
  // ========================================
  
  /// Link - 14px
  /// Usage: Inline links
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.accent,
    decoration: TextDecoration.underline,
  );
  
  /// Link Small - 12px
  /// Usage: Small links, footnote links
  static const TextStyle linkSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.accent,
    decoration: TextDecoration.underline,
  );
  
  // ========================================
  // CONVENIENCE ALIASES
  // For backwards compatibility and common names
  // ========================================
  
  /// Alias for h3 (24px) - Heading for cards and sections
  static const TextStyle headingSmall = h3;
  
  /// Alias for h2 (28px) - Main heading for sections
  static const TextStyle headingMedium = h2;
  
  /// Alias for h1 (32px) - Large heading for pages
  static const TextStyle headingLarge = h1;
  
  /// Alias for display3 (36px) - Display for special emphasis
  static const TextStyle displaySmall = display3;
  
  /// Alias for display2 (40px) - Display for page heroes
  static const TextStyle displayMedium = display2;
  
  /// Alias for display1 (48px) - Display for app heroes
  static const TextStyle displayLarge = display1;
}

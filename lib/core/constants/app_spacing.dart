// ============================================================================
// FILE: lib/core/constants/app_spacing.dart
// DESCRIPTION: Comprehensive spacing, sizing & layout system
// BASE: 4px grid system (industry standard)
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Professional spacing system with 4px base unit
/// Ensures consistent rhythm throughout the app
class AppSpacing {
  AppSpacing._();

  // ========================================
  // BASE SPACING SCALE (4px base)
  // Usage: Padding, margins, gaps
  // ========================================
  
  /// 4px - Minimal spacing
  static const double xs = 4.0;
  
  /// 8px - Tight spacing (between related elements)
  static const double sm = 8.0;
  
  /// 12px - Compact spacing
  static const double md = 12.0;
  
  /// 16px - Standard spacing (most common)
  static const double lg = 16.0;
  
  /// 24px - Generous spacing (between sections)
  static const double xl = 24.0;
  
  /// 32px - Large spacing (major sections)
  static const double xxl = 32.0;
  
  /// 48px - Extra large spacing (page sections)
  static const double xxxl = 48.0;
  
  /// 64px - Huge spacing (hero sections)
  static const double huge = 64.0;
  
  // ========================================
  // SCREEN PADDING
  // Standard padding for different screen areas
  // ========================================
  
  /// Horizontal screen padding (left & right)
  static const double screenHorizontal = 20.0;
  
  /// Vertical screen padding (top & bottom)
  static const double screenVertical = 20.0;
  
  /// Horizontal padding for small screens
  static const double screenHorizontalSmall = 16.0;
  
  /// Screen padding EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );
  
  /// Screen padding horizontal only
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );
  
  /// Screen padding for small screens
  static const EdgeInsets screenPaddingSmall = EdgeInsets.symmetric(
    horizontal: screenHorizontalSmall,
    vertical: 16.0,
  );
  
  // ========================================
  // CARD PADDING
  // Padding inside cards and containers
  // ========================================
  
  /// Standard card padding
  static const double cardPadding = 16.0;
  
  /// Large card padding
  static const double cardPaddingLarge = 20.0;
  
  /// Small card padding
  static const double cardPaddingSmall = 12.0;
  
  /// Card padding EdgeInsets
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  
  /// Large card padding EdgeInsets
  static const EdgeInsets cardPaddingLargeAll = EdgeInsets.all(cardPaddingLarge);
  
  /// Small card padding EdgeInsets
  static const EdgeInsets cardPaddingSmallAll = EdgeInsets.all(cardPaddingSmall);
  
  // ========================================
  // LIST PADDING
  // For list items and tiles
  // ========================================
  
  /// List item horizontal padding
  static const double listHorizontal = 16.0;
  
  /// List item vertical padding
  static const double listVertical = 12.0;
  
  /// List item padding
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: listHorizontal,
    vertical: listVertical,
  );
  
  /// Dense list item padding
  static const EdgeInsets listPaddingDense = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  
  /// Comfortable list item padding
  static const EdgeInsets listPaddingComfortable = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 16.0,
  );
  
  // ========================================
  // BUTTON PADDING
  // Internal button padding
  // ========================================
  
  /// Large button padding
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 16.0,
  );
  
  /// Medium button padding (standard)
  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  
  /// Small button padding
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  
  /// Icon button padding
  static const EdgeInsets buttonPaddingIcon = EdgeInsets.all(12.0);
  
  // ========================================
  // GAP SPACING
  // For spacing between widgets (Column, Row)
  // ========================================
  
  /// Gap 4px
  static const double gapXs = 4.0;
  
  /// Gap 8px
  static const double gapSm = 8.0;
  
  /// Gap 12px
  static const double gapMd = 12.0;
  
  /// Gap 16px (standard)
  static const double gapLg = 16.0;
  
  /// Gap 24px
  static const double gapXl = 24.0;
  
  /// Gap 32px
  static const double gapXxl = 32.0;
  
  // SizedBox helpers for gaps
  static const SizedBox gapXsBox = SizedBox(height: gapXs);
  static const SizedBox gapSmBox = SizedBox(height: gapSm);
  static const SizedBox gapMdBox = SizedBox(height: gapMd);
  static const SizedBox gapLgBox = SizedBox(height: gapLg);
  static const SizedBox gapXlBox = SizedBox(height: gapXl);
  static const SizedBox gapXxlBox = SizedBox(height: gapXxl);
  
  // Horizontal gaps
  static const SizedBox gapXsHorizontal = SizedBox(width: gapXs);
  static const SizedBox gapSmHorizontal = SizedBox(width: gapSm);
  static const SizedBox gapMdHorizontal = SizedBox(width: gapMd);
  static const SizedBox gapLgHorizontal = SizedBox(width: gapLg);
  static const SizedBox gapXlHorizontal = SizedBox(width: gapXl);
  static const SizedBox gapXxlHorizontal = SizedBox(width: gapXxl);
}

// ============================================================================
// BORDER RADIUS SYSTEM
// Consistent corner rounding
// ============================================================================

class AppRadius {
  AppRadius._();

  // ========================================
  // RADIUS VALUES
  // ========================================
  
  /// No radius (square corners)
  static const double none = 0.0;
  
  /// 4px - Subtle rounding
  static const double xs = 4.0;
  
  /// 8px - Small rounding
  static const double sm = 8.0;
  
  /// 12px - Standard rounding (most common)
  static const double md = 12.0;
  
  /// 16px - Large rounding
  static const double lg = 16.0;
  
  /// 20px - Extra large rounding
  static const double xl = 20.0;
  
  /// 24px - Huge rounding
  static const double xxl = 24.0;
  
  /// 999px - Full rounding (pills)
  static const double full = 999.0;
  
  // ========================================
  // BORDER RADIUS OBJECTS
  // Ready-to-use BorderRadius
  // ========================================
  
  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
  
  // ========================================
  // SPECIFIC COMPONENT RADIUS
  // ========================================
  
  /// Button radius - 12px
  static const BorderRadius button = radiusMd;
  
  /// Card radius - 16px
  static const BorderRadius card = radiusLg;
  
  /// Modal radius - 20px
  static const BorderRadius modal = radiusXl;
  
  /// Input field radius - 12px
  static const BorderRadius input = radiusMd;
  
  /// Chip/Badge radius - 999px (full pill)
  static const BorderRadius chip = radiusFull;
  
  /// Bottom sheet radius - 24px
  static const BorderRadius bottomSheet = radiusXxl;
}

// ============================================================================
// SHADOW SYSTEM
// Elevation with subtle shadows
// ============================================================================

class AppShadows {
  AppShadows._();

  // ========================================
  // SHADOW DEFINITIONS
  // Professional, subtle shadows
  // ========================================
  
  /// No shadow
  static const List<BoxShadow> none = [];
  
  /// Shadow XS - Subtle hint of elevation
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  /// Shadow SM - Small elevation (cards at rest)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  /// Shadow MD - Medium elevation (standard cards)
  static const List<BoxShadow> md = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  /// Shadow LG - Large elevation (hover cards)
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  /// Shadow XL - Extra large elevation (modals)
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: AppColors.shadowStrong,
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  /// Shadow XXL - Huge elevation (bottom sheets)
  static const List<BoxShadow> xxl = [
    BoxShadow(
      color: AppColors.shadowStrong,
      offset: Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
  
  // ========================================
  // COLORED SHADOWS
  // For special effects
  // ========================================
  
  /// Accent shadow (for primary buttons)
  static const List<BoxShadow> accent = [
    BoxShadow(
      color: Color(0x206366F1), // 12% opacity of accent
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  /// Success shadow (for income/success elements)
  static const List<BoxShadow> success = [
    BoxShadow(
      color: Color(0x2010B981), // 12% opacity of green
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  /// Danger shadow (for expense/danger elements)
  static const List<BoxShadow> danger = [
    BoxShadow(
      color: Color(0x20EF4444), // 12% opacity of red
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
}

// ============================================================================
// ICON SIZES
// Consistent icon sizing
// ============================================================================

class AppIconSize {
  AppIconSize._();

  /// 12px - Tiny icons
  static const double xs = 12.0;
  
  /// 16px - Small icons
  static const double sm = 16.0;
  
  /// 20px - Medium icons (standard)
  static const double md = 20.0;
  
  /// 24px - Large icons (common)
  static const double lg = 24.0;
  
  /// 28px - Extra large icons
  static const double xl = 28.0;
  
  /// 32px - Huge icons
  static const double xxl = 32.0;
  
  /// 48px - Hero icons
  static const double hero = 48.0;
}

// ============================================================================
// BUTTON SIZES
// Consistent button dimensions
// ============================================================================

class AppButtonSize {
  AppButtonSize._();

  /// Small button height
  static const double small = 36.0;
  
  /// Medium button height (standard)
  static const double medium = 44.0;
  
  /// Large button height
  static const double large = 52.0;
  
  /// Icon button size
  static const double icon = 40.0;
}

// ============================================================================
// INPUT FIELD SIZES
// Consistent input heights
// ============================================================================

class AppInputSize {
  AppInputSize._();

  /// Small input height
  static const double small = 40.0;
  
  /// Medium input height (standard)
  static const double medium = 48.0;
  
  /// Large input height
  static const double large = 56.0;
}

// ============================================================================
// AVATAR SIZES
// Consistent avatar/profile picture sizing
// ============================================================================

class AppAvatarSize {
  AppAvatarSize._();

  /// 24px - Tiny avatar
  static const double xs = 24.0;
  
  /// 32px - Small avatar
  static const double sm = 32.0;
  
  /// 40px - Medium avatar
  static const double md = 40.0;
  
  /// 48px - Large avatar
  static const double lg = 48.0;
  
  /// 64px - Extra large avatar
  static const double xl = 64.0;
  
  /// 80px - Huge avatar
  static const double xxl = 80.0;
  
  /// 120px - Profile avatar
  static const double profile = 120.0;
}

// ============================================================================
// BREAKPOINTS
// Responsive design breakpoints
// ============================================================================

class AppBreakpoints {
  AppBreakpoints._();

  /// Mobile breakpoint
  static const double mobile = 480.0;
  
  /// Tablet breakpoint
  static const double tablet = 768.0;
  
  /// Desktop breakpoint
  static const double desktop = 1024.0;
  
  /// Large desktop breakpoint
  static const double desktopLarge = 1440.0;
}

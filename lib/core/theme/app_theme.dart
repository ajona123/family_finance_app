// ============================================================================
// FILE: lib/core/theme/app_theme.dart
// DESCRIPTION: Complete theme configuration for Flutter app
// USAGE: Set this in MaterialApp
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  AppTheme._();

  // ========================================
  // LIGHT THEME (Main Theme)
  // ========================================
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      
      // ========================================
      // COLOR SCHEME
      // ========================================
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        error: AppColors.error,
        errorContainer: AppColors.errorBackground,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceVariant: AppColors.surfaceOverlay,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onTertiary: AppColors.textOnPrimary,
        onError: AppColors.textOnPrimary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadowMedium,
      ),
      
      // ========================================
      // SCAFFOLD
      // ========================================
      scaffoldBackgroundColor: AppColors.background,
      
      // ========================================
      // APP BAR THEME
      // ========================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.h5,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // ========================================
      // CARD THEME
      // ========================================
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),
      
      // ========================================
      // ELEVATED BUTTON THEME
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppSpacing.buttonPaddingMedium,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // ========================================
      // OUTLINED BUTTON THEME
      // ========================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: AppSpacing.buttonPaddingMedium,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // ========================================
      // TEXT BUTTON THEME
      // ========================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPaddingMedium,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // ========================================
      // ICON BUTTON THEME
      // ========================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          iconSize: AppIconSize.md,
        ),
      ),
      
      // ========================================
      // INPUT DECORATION THEME
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        
        // Border styles
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1.5),
        ),
        
        // Text styles
        labelStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        helperStyle: AppTypography.captionMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        errorStyle: AppTypography.captionMedium.copyWith(
          color: AppColors.error,
        ),
      ),
      
      // ========================================
      // FLOATING ACTION BUTTON THEME
      // ========================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // ========================================
      // DIVIDER THEME
      // ========================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // ========================================
      // DIALOG THEME
      // ========================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modal,
        ),
        titleTextStyle: AppTypography.h4,
        contentTextStyle: AppTypography.bodyMedium,
      ),
      
      // ========================================
      // BOTTOM SHEET THEME
      // ========================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
      ),
      
      // ========================================
      // SNACKBAR THEME
      // ========================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textOnPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
      ),
      
      // ========================================
      // PROGRESS INDICATOR THEME
      // ========================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),
      
      // ========================================
      // SWITCH THEME
      // ========================================
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accent;
          }
          return AppColors.neutral400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.accentLight;
          }
          return AppColors.neutral300;
        }),
      ),
      
      // ========================================
      // LIST TILE THEME
      // ========================================
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listPadding,
        titleTextStyle: AppTypography.bodyMediumMedium,
        subtitleTextStyle: AppTypography.bodySmall,
        leadingAndTrailingTextStyle: AppTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
      ),
      
      // ========================================
      // BOTTOM NAVIGATION BAR THEME
      // ========================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // ========================================
      // TAB BAR THEME
      // ========================================
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.labelLarge,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      
      // ========================================
      // TEXT THEME
      // ========================================
      textTheme: TextTheme(
        displayLarge: AppTypography.display1,
        displayMedium: AppTypography.display2,
        displaySmall: AppTypography.display3,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.h5,
        titleSmall: AppTypography.h6,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // ========================================
      // FONT FAMILY
      // ========================================
      fontFamily: AppTypography.fontFamily,
    );
  }
  
  // ========================================
  // DARK THEME (Optional - for future)
  // ========================================
  static ThemeData dark() {
    // Implement dark theme here if needed
    return light(); // Placeholder
  }
}
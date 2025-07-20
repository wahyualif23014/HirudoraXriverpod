// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart'; 

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark, 
    primaryColor: AppColors.accentBlue, 
    scaffoldBackgroundColor: AppColors.primaryBackground, 
    cardColor: AppColors.secondaryBackground, 

    // Konfigurasi AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, 
      elevation: 0,
      foregroundColor: AppColors.primaryText,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.primaryText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Konfigurasi Text
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.primaryText),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryText),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.primaryText),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.primaryText),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryText),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryText),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryText),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.secondaryText),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.secondaryText),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryText),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryText),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.tertiaryText),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryText),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.tertiaryText),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.tertiaryText),
    ),

    // Konfigurasi Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentBlue, 
        foregroundColor: AppColors.primaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentBlue,
      ),
    ),

    // Konfigurasi Input Field
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondaryBackground,
      labelStyle: const TextStyle(color: AppColors.secondaryText),
      hintStyle: const TextStyle(color: AppColors.tertiaryText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accentBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // Konfigurasi BottomSheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Konfigurasi Progress Indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.accentBlue,
      linearTrackColor: AppColors.secondaryBackground,
      circularTrackColor: AppColors.secondaryBackground,
    ),
  );
}

// lib/app/theme/text_styles.dart (Buat file ini jika belum ada)
// Ini adalah placeholder. Anda bisa mendefinisikan gaya teks kustom di sini.
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.normal);
  static const TextStyle displayMedium = TextStyle(fontSize: 45, fontWeight: FontWeight.normal);
  static const TextStyle displaySmall = TextStyle(fontSize: 36, fontWeight: FontWeight.normal);
  static const TextStyle headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle titleSmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
}
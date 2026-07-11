import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Premium Palette
  static const Color primaryGreen = Color(0xFF2E7D32); // Emerald Green
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  
  static const Color accentBlue = Color(0xFF00B0FF); // Cyan/Blue accent
  static const Color accentBlueLight = Color(0xFF40C4FF);
  
  static const Color backgroundLight = Color(0xFFF4F7F5);
  static const Color backgroundDark = Color(0xFF0C1911);
  
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF12261A);
  
  static const Color textPrimaryLight = Color(0xFF1A2E22);
  static const Color textPrimaryDark = Color(0xFFE8F5E9);
  
  static const Color textSecondaryLight = Color(0xFF556B5C);
  static const Color textSecondaryDark = Color(0xFFA5D6A7);

  // Status colors for medicine remaining stock
  static const Color statusGreen = Color(0xFF2E7D32);  // Enough stock
  static const Color statusYellow = Color(0xFFFBC02D); // Low stock
  static const Color statusRed = Color(0xFFD32F2F);    // Critical stock

  // Card Glassmorphic properties
  static final BorderRadius cardRadius = BorderRadius.circular(24.0);
  static final BorderRadius outerCardRadius = BorderRadius.circular(28.0);
  
  static List<BoxShadow> getCardShadow(Brightness brightness) {
    if (brightness == Brightness.light) {
      return [
        BoxShadow(
          color: Colors.black.withAlpha(12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primaryGreen.withAlpha(8),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withAlpha(60),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(30),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ];
    }
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentBlue,
        background: backgroundLight,
        surface: surfaceLight,
        error: statusRed,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryLight),
          bodyLarge: const TextStyle(color: textPrimaryLight),
          bodyMedium: const TextStyle(color: textSecondaryLight),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        color: surfaceLight,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryLight),
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreenLight,
        secondary: accentBlueLight,
        background: backgroundDark,
        surface: surfaceDark,
        error: statusRed,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryDark),
          bodyLarge: const TextStyle(color: textPrimaryDark),
          bodyMedium: const TextStyle(color: textSecondaryDark),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        color: surfaceDark,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimaryDark),
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreenLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

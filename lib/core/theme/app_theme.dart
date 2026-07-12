import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Unified Medium-Dark Marine Blue Palette ────────────────────────────
  // Consistent across ALL pages: login, dashboard, medicine, tracker, etc.
  static const Color primaryGreen = Color(0xFF3B82F6);    // Electric Blue accent
  static const Color primaryGreenLight = Color(0xFF60A5FA); // Lighter blue
  static const Color primaryGreenDark = Color(0xFF1D4ED8);  // Deeper blue

  static const Color accentBlue = Color(0xFF38BDF8);      // Cyan accent
  static const Color accentBlueLight = Color(0xFF7DD3FC); // Light cyan

  // Background: medium-dark marine blue — darker than pure light, lighter than pitch black
  static const Color backgroundLight = Color(0xFF0E1F38); // Marine night blue
  static const Color backgroundDark  = Color(0xFF091528); // Slightly deeper for dark mode

  // Card surfaces: dark steel blue (semi-transparent in cards)
  static const Color surfaceLight = Color(0xFF162033);
  static const Color surfaceDark  = Color(0xFF0D1A2D);

  // Text: high contrast for readability
  static const Color textPrimaryLight   = Color(0xFFF0F7FF); // Near-white
  static const Color textPrimaryDark    = Color(0xFFE2EEFF);
  static const Color textSecondaryLight = Color(0xFFB0C4DE); // Steel blue-gray
  static const Color textSecondaryDark  = Color(0xFF8BA5C0);

  // Status colors
  static const Color statusGreen  = Color(0xFF22C55E);
  static const Color statusYellow = Color(0xFFF59E0B);
  static const Color statusRed    = Color(0xFFEF4444);

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
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: accentBlue,
        background: backgroundLight,
        surface: surfaceLight,
        error: statusRed,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryLight),
          bodyLarge: const TextStyle(color: textPrimaryLight),
          bodyMedium: const TextStyle(color: textSecondaryLight),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        color: surfaceLight.withOpacity(0.12),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155).withOpacity(0.4),
        labelStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        floatingLabelStyle: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14),
        prefixIconColor: const Color(0xFFCBD5E1),
        suffixIconColor: const Color(0xFFCBD5E1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.0),
        ),
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
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(fontWeight: FontWeight.w600, color: textPrimaryDark),
          bodyLarge: const TextStyle(color: textPrimaryDark),
          bodyMedium: const TextStyle(color: textSecondaryDark),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        color: surfaceDark.withOpacity(0.12),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155).withOpacity(0.4),
        labelStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
        floatingLabelStyle: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14),
        prefixIconColor: const Color(0xFFCBD5E1),
        suffixIconColor: const Color(0xFFCBD5E1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF334155).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.0),
        ),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0F766E);
  static const secondaryColor = Color(0xFF14B8A6);
  static const ctaColor = Color(0xFF0369A1);
  static const accentColor = Color(0xFF2ECC71);
  static const warningColor = Color(0xFFF39C12);
  static const errorColor = Color(0xFFE74C3C);
  static const backgroundColor = Color(0xFFF0FDFA);
  static const surfaceColor = Colors.white;
  static const textColor = Color(0xFF134E4A);

  static ThemeData get lightTheme {
    final arabicTextTheme = GoogleFonts.notoSansArabicTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: arabicTextTheme.copyWith(
        headlineLarge: GoogleFonts.notoNaskhArabic(
          fontSize: 32, fontWeight: FontWeight.bold, color: textColor,
        ),
        headlineMedium: GoogleFonts.notoNaskhArabic(
          fontSize: 24, fontWeight: FontWeight.w600, color: textColor,
        ),
        titleLarge: GoogleFonts.notoNaskhArabic(
          fontSize: 20, fontWeight: FontWeight.w600, color: textColor,
        ),
        titleMedium: GoogleFonts.notoSansArabic(
          fontSize: 16, fontWeight: FontWeight.w600, color: textColor,
        ),
        bodyLarge: GoogleFonts.notoSansArabic(
          fontSize: 16, fontWeight: FontWeight.normal, color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSansArabic(
          fontSize: 14, fontWeight: FontWeight.normal, color: textColor,
        ),
        labelLarge: GoogleFonts.notoSansArabic(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoNaskhArabic(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ctaColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF14B8A6),
        secondary: Color(0xFF2DD4BF),
        surface: Color(0xFF1E293B),
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}

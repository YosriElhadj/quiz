import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme. fromSeed(
        seedColor: const Color(AppConstants.primaryColor),
        primary: const Color(AppConstants.primaryColor),
        secondary: const Color(AppConstants.secondaryColor),
        tertiary: const Color(AppConstants. accentColor),
        background: const Color(AppConstants.backgroundColor),
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(AppConstants.primaryColor),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.primaryColor),
          letterSpacing: 0.5,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. circular(16),
          ),
          side: const BorderSide(
            color: Color(AppConstants.primaryColor),
            width: 2,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25,
        ),
        displayMedium:  TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight. w600,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize:  14,
          letterSpacing: 0.25,
          height: 1.5,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide. none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:  BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(AppConstants.primaryColor),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme:  ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.primaryColor),
        primary: const Color(AppConstants. primaryColor),
        secondary: const Color(AppConstants.secondaryColor),
        tertiary: const Color(AppConstants.accentColor),
        background: const Color(0xFF0F172A),
        surface: const Color(0xFF1E293B),
        brightness: Brightness. dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      
      // Same theme settings as light but adapted for dark mode
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize:  24,
          fontWeight:  FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior:  Clip.antiAlias,
      ),
    );
  }
}
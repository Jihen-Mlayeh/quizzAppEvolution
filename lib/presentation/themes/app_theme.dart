import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1a0b2e),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFa855f7),
        secondary: Color(0xFFec4899),
        surface: Color(0xFF2d1b4e),
        background: Color(0xFF1a0b2e),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  static const Gradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFec4899),
      Color(0xFFa855f7),
      Color(0xFF6366f1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
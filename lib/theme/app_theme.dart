import 'package:flutter/material.dart';

class AppTheme {
  // Lavender Mist Palette
  static const Color mysticPurple = Color(0xFF7F5A83); // Primary
  static const Color softLilac = Color(0xFFA188A6); // Secondary
  static const Color sageGrey = Color(0xFF9DA9A0); // Tertiary
  static const Color burntSienna = Color(0xFFE76F51); // Accent / Error
  static const Color paleLinen = Color(0xFFFFFBF0); // Surface
  static const Color thistle = Color(0xFFD1C4E9); // Primary Container

  static const Color textMain = Color(
    0xFF2E2335,
  ); // On Surface (Deep Purple Black)
  static const Color textSoft = Color(0xFF6D5D75); // On Surface Variant

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A161C); // Deep Violet-Black
  static const Color darkSurface = Color(0xFF262029); // Slightly lighter
  static const Color darkTextMain = Color(0xFFF3E5F5);
  static const Color darkTextSoft = Color(0xFFCE93D8);

  // Helper to create semi-transparent mysticPurple for dark theme
  static const Color _mysticPurpleHalfAlpha = Color(0x807F5A83);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mysticPurple,
      primary: mysticPurple,
      secondary: softLilac,
      tertiary: sageGrey,
      surface: paleLinen,
      onSurface: textMain,
      onSurfaceVariant: textSoft,
      primaryContainer: thistle,
      error: burntSienna,
    ),
    scaffoldBackgroundColor: paleLinen,
    cardColor: Colors.white,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mysticPurple,
      brightness: Brightness.dark,
      primary: thistle, // Lighter purple for dark mode
      secondary: softLilac,
      tertiary: sageGrey,
      surface: darkBackground,
      surfaceContainer: darkSurface,
      onSurface: darkTextMain,
      onSurfaceVariant: darkTextSoft,
      primaryContainer: _mysticPurpleHalfAlpha,
      error: burntSienna,
    ),
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkSurface,
  );
}

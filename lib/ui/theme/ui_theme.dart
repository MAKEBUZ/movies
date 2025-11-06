import 'package:flutter/material.dart';

class UiColors {
  static const Color pinkBackground = Color(0xFFFFD6E3); // fondo rosado
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color accentRed = Color(0xFFFF3B3B); // chip seleccionado
  static const Color imdbYellow = Color(0xFFF5C518); // color oficial IMDb
}

ThemeData buildUiTheme() {
  return ThemeData(
    fontFamily: 'Morn',
    colorScheme: ColorScheme.fromSeed(seedColor: UiColors.accentRed),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: UiColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: UiColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: UiColors.textSecondary,
      ),
    ),
  );
}
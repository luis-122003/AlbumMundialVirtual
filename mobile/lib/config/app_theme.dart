import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // LIGHT COLORS
  // =========================
  static const Color primaryColor = Color(0xFF4A3FCD);
  static const Color secondaryColor = Color(0xFFF29E38);
  static const Color accentColor = Color(0xFF4CD964);

  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF666666);

  // =========================
  // DARK COLORS
  // =========================
  static const Color darkPrimaryColor = Color(0xFF6B5DE7);
  static const Color darkSecondaryColor = Color(0xFFFFBA3D);
  static const Color darkAccentColor = Color(0xFF5FD370);

  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkCardColor = Color(0xFF2A2A2A);

  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0);

  // =========================
  // GLOBAL VALUES
  // =========================
  static const double radius = 12;

  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: cardColor,
      ),

      scaffoldBackgroundColor: backgroundColor,

      // =========================
      // APP BAR
      // =========================
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // =========================
      // CARD
      // =========================
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // =========================
      // ELEVATED BUTTON
      // =========================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),

      // =========================
      // OUTLINED BUTTON
      // =========================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),

      // =========================
      // TEXT BUTTON
      // =========================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),

      // =========================
      // INPUTS
      // =========================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),

      // =========================
      // SNACKBAR
      // =========================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      // =========================
      // PROGRESS
      // =========================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // =========================
      // NAVIGATION BAR
      // =========================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,

        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryColor);
          }

          return const IconThemeData(
            color: textSecondaryColor,
          );
        }),
      ),

      // =========================
      // TEXT THEME
      // =========================
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),

        displayMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        displaySmall: TextStyle(
          color: textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),

        headlineSmall: TextStyle(
          color: textPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),

        titleLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        titleMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
        ),

        bodyMedium: TextStyle(
          color: textSecondaryColor,
          fontSize: 14,
        ),

        bodySmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================
  // DARK THEME
  // =========================
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        tertiary: darkAccentColor,
        surface: darkCardColor,
      ),

      scaffoldBackgroundColor: darkBackgroundColor,

      // =========================
      // APP BAR
      // =========================
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: darkTextPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // =========================
      // CARD
      // =========================
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      // =========================
      // FLOATING BUTTON
      // =========================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
      ),

      // =========================
      // ELEVATED BUTTON
      // =========================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),

      // =========================
      // INPUTS
      // =========================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: darkPrimaryColor,
            width: 2,
          ),
        ),
      ),

      // =========================
      // SNACKBAR
      // =========================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkPrimaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      // =========================
      // NAVIGATION BAR
      // =========================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCardColor,

        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: darkPrimaryColor,
            );
          }

          return const IconThemeData(
            color: darkTextSecondaryColor,
          );
        }),
      ),

      // =========================
      // TEXT THEME
      // =========================
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),

        displayMedium: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),

        displaySmall: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),

        headlineSmall: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),

        titleLarge: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        titleMedium: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: TextStyle(
          color: darkTextPrimaryColor,
          fontSize: 16,
        ),

        bodyMedium: TextStyle(
          color: darkTextSecondaryColor,
          fontSize: 14,
        ),

        bodySmall: TextStyle(
          color: darkTextSecondaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
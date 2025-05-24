import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';

/// Classe utilitaire pour gérer les thèmes de l'application
class AppThemes {
  AppThemes._(); // Constructeur privé pour empêcher l'instanciation

  // Définit les styles de texte partagés entre les thèmes clair et foncé
  static const _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: "OpenSans-Bold", fontSize: 24.0),
    displayMedium: TextStyle(fontFamily: "OpenSans-Bold", fontSize: 22.0),
    displaySmall: TextStyle(fontFamily: "OpenSans-Bold", fontSize: 20.0),
    headlineLarge: TextStyle(fontFamily: "OpenSans-Bold", fontSize: 18.0),
    headlineMedium: TextStyle(fontFamily: "OpenSans-Bold", fontSize: 16.0),
    headlineSmall: TextStyle(fontFamily: "OpenSans-SemiBold", fontSize: 14.0),
    titleLarge: TextStyle(fontFamily: "OpenSans-SemiBold", fontSize: 16.0),
    titleMedium: TextStyle(fontFamily: "OpenSans-SemiBold", fontSize: 14.0),
    titleSmall: TextStyle(fontFamily: "OpenSans-Medium", fontSize: 12.0),
    bodyLarge: TextStyle(
      fontFamily: "OpenSans",
      fontSize: AppSizes.textSizeLarge,
    ),
    bodyMedium: TextStyle(
      fontFamily: "OpenSans",
      fontSize: AppSizes.textSizeMedium,
    ),
    bodySmall: TextStyle(
      fontFamily: "OpenSans",
      fontSize: AppSizes.textSizeSmall,
    ),
    labelLarge: TextStyle(fontFamily: "OpenSans-Medium", fontSize: 14.0),
    labelMedium: TextStyle(fontFamily: "OpenSans", fontSize: 12.0),
    labelSmall: TextStyle(fontFamily: "OpenSans", fontSize: 10.0),
  );

  /// Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: AppColors.primarySwatch,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primary.withAlpha(10),
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.secondary.withAlpha(10),
        onSecondaryContainer: AppColors.secondary,
        tertiary: AppColors.primaryPurple,
        onTertiary: AppColors.white,
        tertiaryContainer: AppColors.primaryPurple.withAlpha(10),
        onTertiaryContainer: AppColors.primaryPurple,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.black,
        surfaceContainerHighest: AppColors.lightGrey,
        onSurfaceVariant: AppColors.darkGrey,
        surfaceTint: AppColors.primary,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        shadowColor: AppColors.shadow3,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontFamily: "OpenSans-SemiBold",
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      // Scaffolding
      scaffoldBackgroundColor: AppColors.lightBackground,
      // Input Decoration (TextFields, etc.)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
        ),
        hintStyle: TextStyle(color: AppColors.mediumGrey),
        labelStyle: TextStyle(color: AppColors.darkGrey),
      ),
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          shadowColor: AppColors.shadow2,
          textStyle: const TextStyle(
            fontFamily: "OpenSans-SemiBold",
            fontSize: 16,
          ),
        ),
      ),
      // Card
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.shadow2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGrey,
        selectedLabelStyle: const TextStyle(
          fontFamily: "OpenSans",
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: "OpenSans",
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      // Text Theme
      textTheme: _baseTextTheme.apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withAlpha(30),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  /// Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: AppColors.primarySwatch,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.black,
        primaryContainer: AppColors.primary.withAlpha(20),
        onPrimaryContainer: AppColors.primary.withAlpha(90),
        secondary: AppColors.secondary,
        onSecondary: AppColors.black,
        secondaryContainer: AppColors.secondary.withAlpha(20),
        onSecondaryContainer: AppColors.secondary.withAlpha(90),
        tertiary: AppColors.primaryPurple,
        onTertiary: AppColors.black,
        tertiaryContainer: AppColors.primaryPurple.withAlpha(20),
        onTertiaryContainer: AppColors.primaryPurple.withAlpha(90),
        error: AppColors.error,
        onError: AppColors.black,
        surface: Color(0xFF1E1E1E),
        onSurface: AppColors.white,
        surfaceContainerHighest: Color(0xFF2C2C2C),
        onSurfaceVariant: AppColors.lightGrey,
        surfaceTint: AppColors.primary,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: AppColors.white,
        shadowColor: AppColors.shadow3,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontFamily: "OpenSans-SemiBold",
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      // Scaffolding
      scaffoldBackgroundColor: AppColors.darkBackground,
      // Input Decoration (TextFields, etc.)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFF3C3C3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFF3C3C3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
        ),
        hintStyle: TextStyle(color: AppColors.mediumGrey),
        labelStyle: TextStyle(color: AppColors.lightGrey),
      ),
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
          shadowColor: AppColors.shadow1,
          textStyle: const TextStyle(
            fontFamily: "OpenSans-SemiBold",
            fontSize: 16,
          ),
        ),
      ),
      // Card
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: AppColors.shadow1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightGrey,
        selectedLabelStyle: const TextStyle(
          fontFamily: "OpenSans",
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: "OpenSans",
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      // Text Theme
      textTheme: _baseTextTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withAlpha(30),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  // Définit les objets ThemeData pour les thèmes clair et foncé (pour la compatibilité avec votre code existant)
  static final appThemeData = {
    AppTheme.lightTheme: lightTheme,
    AppTheme.darkTheme: darkTheme,
  };
}

// Énumération pour représenter les deux thèmes disponibles
enum AppTheme { lightTheme, darkTheme }

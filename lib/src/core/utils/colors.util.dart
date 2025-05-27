import 'package:flutter/material.dart';

/// Classe utilitaire contenant toutes les couleurs de l'application KartIA
class AppColors {
  AppColors._(); // Constructeur privé pour empêcher l'instanciation

  // Couleurs Primaires
  static const Color primary = Color(0xFF2D9CDB); // Bleu KartIA
  static const Color primaryOrange = Color(0xFFF2994A); // Orange KartIA
  static const Color primaryPurple = Color(0xFF9B51E0); // Violet KartIA
  static const int primaryValue =
      0xFF2D9CDB; // Valeur hexadécimale de la couleur primaire

  // Couleurs Secondaires
  static const Color secondary = Color(
    0xFFF2994A,
  ); // Orange comme couleur secondaire
  static const Color secondaryYellow = Color(0xFFF2C94C); // Jaune KartIA
  static const Color secondaryDarkBlue = Color(0xFF2F80ED); // Bleu foncé
  static const Color secondaryRedOrange = Color(0xFFEB5757); // Rouge-Orangé

  // Couleurs Neutres
  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF4F4F4F);
  static const Color mediumGrey = Color(0xFF828282);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Couleurs d'état
  static const Color success = Color(0xFF27AE60); // Succès (vert)
  static const Color warning = Color(0xFFF2994A); // Avertissement (orange)
  static const Color error = Color(0xFFEB5757); // Erreur (rouge)
  static const Color info = Color(0xFF2D9CDB); // Information (bleu)

  // Ombres
  static const Color shadow1 = Color(0x33000000); // Ombre 20%
  static const Color shadow2 = Color(0x1E000000); // Ombre 12%
  static const Color shadow3 = Color(0x14000000); // Ombre 8%

  // Couleurs de fond
  static const Color lightBackground = Color(0xFFFCFCFC);
  static const Color darkBackground = Color(0xFF121212);

  // ========== COULEURS SPÉCIFIQUES AU THÈME SOMBRE ==========

  /// Surface sombre pour les cartes et conteneurs
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Surface secondaire sombre
  static const Color darkSurfaceSecondary = Color(0xFF2C2C2C);

  /// Couleur de bordure pour le thème sombre
  static const Color darkBorder = Color(0xFF3C3C3C);

  // Couleurs par module
  static const Color civactModuleColor = primaryOrange;
  static const Color cityAiGuideModuleColor = primary;
  static const Color santeMapModuleColor = success;
  static const Color osmHelperModuleColor = primaryPurple;
  static const Color cartoPrixModuleColor = secondaryYellow;

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primary],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryYellow, primaryPurple],
  );

  static const LinearGradient kartiaLogoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryYellow, primaryOrange, primaryPurple, primary],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ========== GRADIENTS SPÉCIALISÉS POUR LES MODULES ==========

  /// Gradient pour CityAI Guide
  static const LinearGradient cityAiGradient = LinearGradient(
    colors: [primary, info],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient pour SantéMap
  static const LinearGradient santeMapGradient = LinearGradient(
    colors: [success, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient pour CivAct
  static const LinearGradient civactGradient = LinearGradient(
    colors: [primaryOrange, warning],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient pour CartoPrix
  static const LinearGradient cartoPrixGradient = LinearGradient(
    colors: [secondaryYellow, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // MaterialColor pour primarySwatch
  static const MaterialColor primarySwatch = MaterialColor(
    primaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2D9CDB), // primary
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  // MaterialColor pour secondarySwatch
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFF2994A, // primaryOrange
    <int, Color>{
      50: Color(0xFFFFF3E0),
      100: Color(0xFFFFE0B2),
      200: Color(0xFFFFCC80),
      300: Color(0xFFFFB74D),
      400: Color(0xFFFFA726),
      500: Color(0xFFF2994A), // primaryOrange
      600: Color(0xFFFB8C00),
      700: Color(0xFFF57C00),
      800: Color(0xFFEF6C00),
      900: Color(0xFFE65100),
    },
  );

  // ========== MÉTHODES ADAPTATIVES POUR LES THÈMES ==========

  /// Retourne la couleur de surface adaptée au thème
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : white;
  }

  /// Retourne la couleur de fond adaptée au thème
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// Retourne la couleur de surface secondaire adaptée au thème
  static Color surfaceSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceSecondary
        : lightGrey.withAlpha(30);
  }

  /// Retourne la couleur de texte primaire adaptée au thème
  static Color onSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? white : black;
  }

  /// Retourne la couleur de texte secondaire adaptée au thème
  static Color onSurfaceSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? lightGrey
        : mediumGrey;
  }

  /// Retourne la couleur de bordure adaptée au thème
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightGrey;
  }

  /// Retourne la couleur d'ombre adaptée au thème
  static Color shadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? shadow1 : shadow2;
  }

  /// Retourne la couleur pour les éléments désactivés
  static Color disabledColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? lightGrey.withAlpha(60)
        : mediumGrey.withAlpha(60);
  }

  /// Retourne la couleur pour les dividers
  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder.withAlpha(50)
        : lightGrey;
  }

  /// Retourne la couleur pour les overlays
  static Color overlayColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? black.withAlpha(80)
        : black.withAlpha(50);
  }

  // ========== MÉTHODES UTILITAIRES ==========

  /// Mélange deux couleurs avec un ratio donné
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }

  /// Assombrit une couleur
  static Color darken(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );
    return darkened.toColor();
  }

  /// Éclaircit une couleur
  static Color lighten(Color color, [double amount = 0.2]) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lightened.toColor();
  }

  /// Applique une opacité à une couleur
  static Color withOpacity(Color color, double opacity) {
    return color.withAlpha((255 * opacity).round());
  }

  /// Retourne une couleur contrastée pour du texte
  static Color getContrastColor(Color backgroundColor) {
    // Calcul de la luminance relative
    final luminance = backgroundColor.computeLuminance();

    // Si la couleur est claire, retourner du noir, sinon du blanc
    return luminance > 0.5 ? black : white;
  }

  /// Génère un gradient personnalisé
  static LinearGradient createGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(colors: colors, begin: begin, end: end, stops: stops);
  }

  // ========== GRADIENTS ADAPTATIFS POUR LES MODULES ==========

  /// Retourne le gradient adapté pour CityAI Guide
  static LinearGradient getCityAiGradient({bool isDark = false}) {
    if (isDark) {
      return LinearGradient(
        colors: [primary.withAlpha(120), info.withAlpha(100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return cityAiGradient;
  }

  /// Retourne le gradient adapté pour SantéMap
  static LinearGradient getSanteMapGradient({bool isDark = false}) {
    if (isDark) {
      return LinearGradient(
        colors: [success.withAlpha(120), primary.withAlpha(100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return santeMapGradient;
  }

  /// Retourne le gradient adapté pour CivAct
  static LinearGradient getCivactGradient({bool isDark = false}) {
    if (isDark) {
      return LinearGradient(
        colors: [primaryOrange.withAlpha(120), warning.withAlpha(100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return civactGradient;
  }

  /// Retourne le gradient adapté pour CartoPrix
  static LinearGradient getCartoPrixGradient({bool isDark = false}) {
    if (isDark) {
      return LinearGradient(
        colors: [secondaryYellow.withAlpha(120), primaryOrange.withAlpha(100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return cartoPrixGradient;
  }
}

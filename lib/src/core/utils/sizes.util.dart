// lib/src/core/utils/sizes.util.dart

import 'package:flutter/material.dart';

/// Classe utilitaire pour gérer les tailles et espacements de l'application
class AppSizes {
  AppSizes._(); // Constructeur privé pour empêcher l'instanciation

  // =============================================================================
  // ESPACEMENTS DE BASE
  // =============================================================================

  /// Espacement très petit (4px)
  static const double spacingXS = 4.0;

  /// Espacement petit (8px)
  static const double spacingS = 8.0;

  /// Espacement moyen (16px)
  static const double spacingM = 16.0;

  /// Espacement large (24px)
  static const double spacingL = 24.0;

  /// Espacement très large (32px)
  static const double spacingXL = 32.0;

  /// Espacement extra large (48px)
  static const double spacingXXL = 48.0;

  // =============================================================================
  // TAILLES DE TEXTE
  // =============================================================================

  /// Taille de texte très petite
  static const double textSizeXS = 10.0;

  /// Taille de texte petite
  static const double textSizeSmall = 12.0;

  /// Taille de texte moyenne
  static const double textSizeMedium = 14.0;

  /// Taille de texte large
  static const double textSizeLarge = 16.0;

  /// Taille de texte très large
  static const double textSizeXL = 18.0;

  /// Taille de texte extra large
  static const double textSizeXXL = 20.0;

  // =============================================================================
  // TAILLES D'ICÔNES
  // =============================================================================

  /// Taille d'icône petite
  static const double iconSizeSmall = 16.0;

  /// Taille d'icône moyenne
  static const double iconSizeMedium = 24.0;

  /// Taille d'icône large
  static const double iconSizeLarge = 32.0;

  /// Taille d'icône très large
  static const double iconSizeXL = 48.0;

  // =============================================================================
  // RAYONS DE BORDURE
  // =============================================================================

  /// Rayon de bordure petit
  static const double radiusSmall = 4.0;

  /// Rayon de bordure moyen
  static const double radiusMedium = 8.0;

  /// Rayon de bordure large
  static const double radiusLarge = 12.0;

  /// Rayon de bordure très large
  static const double radiusXL = 16.0;

  /// Rayon de bordure extra large
  static const double radiusXXL = 20.0;

  /// Rayon de bordure circulaire
  static const double radiusCircular = 100.0;

  // =============================================================================
  // ÉLÉVATIONS
  // =============================================================================

  /// Élévation nulle
  static const double elevationNone = 0.0;

  /// Élévation légère
  static const double elevationLow = 2.0;

  /// Élévation moyenne
  static const double elevationMedium = 4.0;

  /// Élévation haute
  static const double elevationHigh = 8.0;

  /// Élévation très haute
  static const double elevationXL = 16.0;

  // =============================================================================
  // TAILLES DE BOUTONS
  // =============================================================================

  /// Hauteur de bouton petit
  static const double buttonHeightSmall = 32.0;

  /// Hauteur de bouton moyen
  static const double buttonHeightMedium = 40.0;

  /// Hauteur de bouton large
  static const double buttonHeightLarge = 48.0;

  /// Hauteur de bouton très large
  static const double buttonHeightXL = 56.0;

  // =============================================================================
  // DIMENSIONS D'AVATAR
  // =============================================================================

  /// Taille d'avatar petite
  static const double avatarSizeSmall = 32.0;

  /// Taille d'avatar moyenne
  static const double avatarSizeMedium = 48.0;

  /// Taille d'avatar large
  static const double avatarSizeLarge = 64.0;

  /// Taille d'avatar très large
  static const double avatarSizeXL = 96.0;

  // =============================================================================
  // DIMENSIONS DE CARTES
  // =============================================================================

  /// Hauteur de carte petite
  static const double cardHeightSmall = 120.0;

  /// Hauteur de carte moyenne
  static const double cardHeightMedium = 160.0;

  /// Hauteur de carte large
  static const double cardHeightLarge = 200.0;

  // =============================================================================
  // LARGEURS MAXIMALES
  // =============================================================================

  /// Largeur maximale pour le contenu mobile
  static const double maxWidthMobile = 480.0;

  /// Largeur maximale pour le contenu tablette
  static const double maxWidthTablet = 768.0;

  /// Largeur maximale pour le contenu desktop
  static const double maxWidthDesktop = 1200.0;

  // =============================================================================
  // BREAKPOINTS RESPONSIFS
  // =============================================================================

  /// Breakpoint mobile
  static const double breakpointMobile = 480.0;

  /// Breakpoint tablette
  static const double breakpointTablet = 768.0;

  /// Breakpoint desktop
  static const double breakpointDesktop = 1024.0;
}

// =============================================================================
// WIDGETS D'ESPACEMENT PRÉDÉFINIS
// =============================================================================

/// Widget d'espacement horizontal
class WidthSpace extends StatelessWidget {
  final double? width;

  const WidthSpace({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width ?? AppSizes.spacingM);
  }
}

/// Widget d'espacement vertical
class HeightSpace extends StatelessWidget {
  final double? height;

  const HeightSpace({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height ?? AppSizes.spacingM);
  }
}

// =============================================================================
// INSTANCES GLOBALES POUR LA COMPATIBILITÉ
// =============================================================================

/// Instance globale pour l'espacement horizontal (compatibilité avec le code existant)
final widthSpace = const WidthSpace(width: 20);

/// Instance globale pour l'espacement vertical (compatibilité avec le code existant)
final heightSpace = const HeightSpace(height: 20);

/// Padding fixe global (compatibilité avec le code existant)
final fixPadding = AppSizes.spacingM;

// =============================================================================
// EXTENSIONS UTILES
// =============================================================================

/// Extension pour les dimensions d'écran
extension ScreenSize on BuildContext {
  /// Obtenir la taille de l'écran
  Size get screenSize => MediaQuery.of(this).size;

  /// Obtenir la largeur de l'écran
  double get screenWidth => screenSize.width;

  /// Obtenir la hauteur de l'écran
  double get screenHeight => screenSize.height;

  /// Vérifier si c'est un écran mobile
  bool get isMobile => screenWidth < AppSizes.breakpointMobile;

  /// Vérifier si c'est un écran tablette
  bool get isTablet =>
      screenWidth >= AppSizes.breakpointMobile &&
      screenWidth < AppSizes.breakpointDesktop;

  /// Vérifier si c'est un écran desktop
  bool get isDesktop => screenWidth >= AppSizes.breakpointDesktop;

  /// Obtenir le padding de sécurité
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Obtenir la hauteur disponible (sans les barres système)
  double get availableHeight =>
      screenHeight - safeAreaPadding.top - safeAreaPadding.bottom;
}

/// Extension pour les espacements responsifs
extension ResponsiveSpacing on double {
  /// Adapter l'espacement selon la taille d'écran
  double responsiveSpacing(BuildContext context) {
    if (context.isMobile) {
      return this * 0.8; // Réduire sur mobile
    } else if (context.isTablet) {
      return this; // Normal sur tablette
    } else {
      return this * 1.2; // Augmenter sur desktop
    }
  }
}

/// Extension pour les tailles de texte responsives
extension ResponsiveText on double {
  /// Adapter la taille de texte selon l'écran
  double responsiveText(BuildContext context) {
    if (context.isMobile) {
      return this;
    } else if (context.isTablet) {
      return this * 1.1;
    } else {
      return this * 1.2;
    }
  }
}

/// Classe helper pour les dimensions adaptatives
class AdaptiveDimensions {
  final BuildContext context;

  AdaptiveDimensions(this.context);

  /// Obtenir un espacement adaptatif
  double spacing({
    double mobile = AppSizes.spacingM,
    double tablet = AppSizes.spacingL,
    double desktop = AppSizes.spacingXL,
  }) {
    if (context.isMobile) return mobile;
    if (context.isTablet) return tablet;
    return desktop;
  }

  /// Obtenir une taille de texte adaptative
  double textSize({
    double mobile = AppSizes.textSizeMedium,
    double tablet = AppSizes.textSizeLarge,
    double desktop = AppSizes.textSizeXL,
  }) {
    if (context.isMobile) return mobile;
    if (context.isTablet) return tablet;
    return desktop;
  }

  /// Obtenir une hauteur de bouton adaptative
  double buttonHeight({
    double mobile = AppSizes.buttonHeightMedium,
    double tablet = AppSizes.buttonHeightLarge,
    double desktop = AppSizes.buttonHeightXL,
  }) {
    if (context.isMobile) return mobile;
    if (context.isTablet) return tablet;
    return desktop;
  }

  /// Obtenir un padding adaptatif
  EdgeInsets padding({
    EdgeInsets mobile = const EdgeInsets.all(AppSizes.spacingM),
    EdgeInsets tablet = const EdgeInsets.all(AppSizes.spacingL),
    EdgeInsets desktop = const EdgeInsets.all(AppSizes.spacingXL),
  }) {
    if (context.isMobile) return mobile;
    if (context.isTablet) return tablet;
    return desktop;
  }
}

/// Extension pour accéder facilement aux dimensions adaptatives
extension AdaptiveExtension on BuildContext {
  AdaptiveDimensions get adaptive => AdaptiveDimensions(this);
}

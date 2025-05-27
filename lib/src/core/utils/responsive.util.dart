// lib/src/core/utils/responsive.util.dart

import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';

/// Utilitaires pour la responsivité de l'application Kartia
///
/// Cette classe fournit des méthodes pour adapter l'interface utilisateur
/// à différentes tailles d'écran (mobile, tablette, desktop)
class ResponsiveUtils {
  ResponsiveUtils._(); // Constructeur privé pour empêcher l'instanciation

  // ============================================================================
  // BREAKPOINTS POUR LES DIFFÉRENTES TAILLES D'ÉCRAN
  // ============================================================================

  /// Largeur minimale pour considérer un écran comme tablette
  static const double tabletBreakpoint = 768.0;

  /// Largeur minimale pour considérer un écran comme desktop
  static const double desktopBreakpoint = 1024.0;

  /// Largeur minimale pour les très grands écrans
  static const double largeDesktopBreakpoint = 1440.0;

  // ============================================================================
  // DÉTECTION DU TYPE D'ÉCRAN
  // ============================================================================

  /// Vérifie si l'écran est de taille mobile
  /// Retourne true si la largeur < 768px
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Vérifie si l'écran est de taille tablette
  /// Retourne true si 768px ≤ largeur < 1024px
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Vérifie si l'écran est de taille desktop
  /// Retourne true si 1024px ≤ largeur < 1440px
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint && width < largeDesktopBreakpoint;
  }

  /// Vérifie si l'écran est un grand desktop
  /// Retourne true si largeur ≥ 1440px
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  /// Retourne le type d'écran sous forme d'énumération
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < tabletBreakpoint) {
      return ScreenType.mobile;
    } else if (width < desktopBreakpoint) {
      return ScreenType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  // ============================================================================
  // GRILLES ADAPTATIVES
  // ============================================================================

  /// Retourne le nombre de colonnes optimal pour une grille
  /// Mobile: 2, Tablet: 3, Desktop: 4, Large Desktop: 5
  static int getGridCrossAxisCount(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
    }
  }

  /// Retourne le ratio optimal pour les items de grille
  /// Plus l'écran est grand, plus le ratio est ajusté
  static double getGridChildAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return 1.5; // Format plus rectangulaire sur mobile
      case ScreenType.tablet:
        return 1.4;
      case ScreenType.desktop:
        return 1.3;
      case ScreenType.largeDesktop:
        return 1.2; // Plus carré sur grand écran
    }
  }

  /// Retourne l'espacement entre items de grille
  static double getGridSpacing(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return 12.0;
      case ScreenType.tablet:
        return 16.0;
      case ScreenType.desktop:
        return 20.0;
      case ScreenType.largeDesktop:
        return 24.0;
    }
  }

  // ============================================================================
  // PADDING ET MARGIN ADAPTATIFS
  // ============================================================================

  /// Retourne le padding horizontal adaptatif
  /// Utilise les valeurs de AppSizes comme base
  static double getHorizontalPadding(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return fixPadding; // Utilise la valeur de AppSizes
      case ScreenType.tablet:
        return fixPadding * 1.5;
      case ScreenType.desktop:
        return fixPadding * 2;
      case ScreenType.largeDesktop:
        return fixPadding * 2.5;
    }
  }

  /// Retourne le padding vertical adaptatif
  static double getVerticalPadding(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return fixPadding;
      case ScreenType.tablet:
        return fixPadding * 1.25;
      case ScreenType.desktop:
        return fixPadding * 1.5;
      case ScreenType.largeDesktop:
        return fixPadding * 1.75;
    }
  }

  /// Retourne un padding adaptatif basé sur une valeur de base
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final hPadding = horizontal ?? getHorizontalPadding(context);
    final vPadding = vertical ?? getVerticalPadding(context);

    if (all != null) {
      final adaptedPadding = getAdaptiveValue(context, all);
      return EdgeInsets.all(adaptedPadding);
    }

    return EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding);
  }

  // ============================================================================
  // TAILLES DE POLICE ADAPTATIVES
  // ============================================================================

  /// Retourne la taille de police adaptative
  /// Utilise les valeurs de AppSizes comme référence
  static double getAdaptiveFontSize(
    BuildContext context, {
    required double baseFontSize,
  }) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
      case ScreenType.largeDesktop:
        return baseFontSize * 1.3;
    }
  }

  /// Retourne la taille de police pour les titres
  static double getAdaptiveTitleFontSize(BuildContext context) {
    return getAdaptiveFontSize(context, baseFontSize: AppSizes.textSizeLarge);
  }

  /// Retourne la taille de police pour le corps de texte
  static double getAdaptiveBodyFontSize(BuildContext context) {
    return getAdaptiveFontSize(context, baseFontSize: AppSizes.textSizeMedium);
  }

  /// Retourne la taille de police pour les sous-titres
  static double getAdaptiveSubtitleFontSize(BuildContext context) {
    return getAdaptiveFontSize(context, baseFontSize: AppSizes.textSizeSmall);
  }

  // ============================================================================
  // ESPACEMENT ADAPTATIF
  // ============================================================================

  /// Retourne l'espacement adaptatif basé sur une valeur de base
  static double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing;
      case ScreenType.tablet:
        return baseSpacing * 1.25;
      case ScreenType.desktop:
        return baseSpacing * 1.5;
      case ScreenType.largeDesktop:
        return baseSpacing * 1.75;
    }
  }

  /// Retourne l'espacement adaptatif pour les hauteurs
  static double getAdaptiveHeight(
    BuildContext context, {
    required double mobileHeight,
    double? tabletHeight,
    double? desktopHeight,
    double? largeDesktopHeight,
  }) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return mobileHeight;
      case ScreenType.tablet:
        return tabletHeight ?? mobileHeight * 1.25;
      case ScreenType.desktop:
        return desktopHeight ?? mobileHeight * 1.5;
      case ScreenType.largeDesktop:
        return largeDesktopHeight ?? mobileHeight * 1.75;
    }
  }

  /// Retourne une valeur adaptative générique
  static double getAdaptiveValue(
    BuildContext context,
    double baseValue, {
    double tabletMultiplier = 1.25,
    double desktopMultiplier = 1.5,
    double largeDesktopMultiplier = 1.75,
  }) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return baseValue;
      case ScreenType.tablet:
        return baseValue * tabletMultiplier;
      case ScreenType.desktop:
        return baseValue * desktopMultiplier;
      case ScreenType.largeDesktop:
        return baseValue * largeDesktopMultiplier;
    }
  }

  // ============================================================================
  // CONTRAINTES DE LARGEUR
  // ============================================================================

  /// Retourne les contraintes de largeur maximale pour le contenu
  static BoxConstraints getContentConstraints(BuildContext context) {
    final screenType = getScreenType(context);

    double maxWidth = double.infinity;

    switch (screenType) {
      case ScreenType.mobile:
        maxWidth = double.infinity; // Pas de limite sur mobile
        break;
      case ScreenType.tablet:
        maxWidth = 800.0;
        break;
      case ScreenType.desktop:
        maxWidth = 1200.0;
        break;
      case ScreenType.largeDesktop:
        maxWidth = 1400.0;
        break;
    }

    return BoxConstraints(maxWidth: maxWidth);
  }

  /// Retourne la largeur optimale pour les cartes
  static double getCardWidth(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 350.0;
      case ScreenType.desktop:
        return 400.0;
      case ScreenType.largeDesktop:
        return 450.0;
    }
  }

  // ============================================================================
  // HELPERS POUR L'ORIENTATION
  // ============================================================================

  /// Vérifie si l'écran est en mode portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Vérifie si l'écran est en mode paysage
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Retourne le nombre de colonnes adapté à l'orientation
  static int getOrientationAwareColumns(BuildContext context) {
    final baseColumns = getGridCrossAxisCount(context);

    if (isLandscape(context) && isMobile(context)) {
      return baseColumns + 1; // Une colonne de plus en paysage sur mobile
    }

    return baseColumns;
  }
}

// ============================================================================
// WIDGETS ADAPTATIFS
// ============================================================================

/// Widget adaptatif qui affiche différents layouts selon la taille d'écran
class ResponsiveLayout extends StatelessWidget {
  /// Layout pour mobile
  final Widget mobile;

  /// Layout pour tablette (optionnel, utilise mobile par défaut)
  final Widget? tablet;

  /// Layout pour desktop (optionnel, utilise tablet ou mobile par défaut)
  final Widget? desktop;

  /// Layout pour grand desktop (optionnel)
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Widget de grille adaptative
class ResponsiveGrid extends StatelessWidget {
  /// Liste des widgets enfants
  final List<Widget> children;

  /// Espacement entre les items
  final double? spacing;

  /// Ratio largeur/hauteur des items
  final double? childAspectRatio;

  /// Nombre de colonnes personnalisé
  final int? crossAxisCount;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Shrink wrap
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.childAspectRatio,
    this.crossAxisCount,
    this.physics,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final columns =
        crossAxisCount ?? ResponsiveUtils.getGridCrossAxisCount(context);
    final aspectRatio =
        childAspectRatio ?? ResponsiveUtils.getGridChildAspectRatio(context);
    final gridSpacing = spacing ?? ResponsiveUtils.getGridSpacing(context);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Widget de padding adaptatif
class ResponsivePadding extends StatelessWidget {
  /// Widget enfant
  final Widget child;

  /// Padding horizontal personnalisé
  final double? horizontalPadding;

  /// Padding vertical personnalisé
  final double? verticalPadding;

  /// Padding uniforme
  final double? allPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontalPadding,
    this.verticalPadding,
    this.allPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getAdaptivePadding(
      context,
      horizontal: horizontalPadding,
      vertical: verticalPadding,
      all: allPadding,
    );

    return Padding(padding: padding, child: child);
  }
}

/// Widget de conteneur avec largeur maximale
class ResponsiveContainer extends StatelessWidget {
  /// Widget enfant
  final Widget child;

  /// Centrer le contenu
  final bool center;

  /// Contraintes personnalisées
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.center = true,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final containerConstraints =
        constraints ?? ResponsiveUtils.getContentConstraints(context);

    Widget content = ConstrainedBox(
      constraints: containerConstraints,
      child: child,
    );

    if (center) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Énumération des types d'écran
enum ScreenType { mobile, tablet, desktop, largeDesktop }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe utilitaire pour gérer les configurations de l'application
class AppConfigs {
  AppConfigs._(); // Constructeur privé pour empêcher l'instanciation

  // =============================================================================
  // CONFIGURATION GRAYLOG
  // =============================================================================

  /// URL de l'instance Graylog pour les logs centralisés
  static String? get graylogUrl => dotenv.env['GRAYLOG_URL'];

  // =============================================================================
  // CONFIGURATION DE L'APPLICATION
  // =============================================================================

  /// Environnement de l'application (development, staging, production)
  static String get appEnvironment =>
      dotenv.env['APP_ENVIRONMENT'] ?? 'development';

  /// API KEY MAPBOX
  static String? get mapboxApiKey => dotenv.env['MAPBOX_API_KEY'];

  // =============================================================================
  // MÉTHODES UTILITAIRES
  // =============================================================================

  /// Vérifier si l'application est en mode développement
  static bool get isDevelopment => appEnvironment == 'development';

  /// Vérifier si l'application est en mode staging
  static bool get isStaging => appEnvironment == 'staging';

  /// Vérifier si l'application est en mode production
  static bool get isProduction => appEnvironment == 'production';

  /// Obtenir un résumé de la configuration pour les logs
  static Map<String, dynamic> getConfigSummary() {
    return {
      'appEnvironment': appEnvironment,
      'hasGraylogUrl': graylogUrl != null,
      'mapboxApiKey': mapboxApiKey?.isNotEmpty ?? false,
    };
  }

  /// Initialiser les configurations (à appeler au démarrage de l'app)
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");

      // Log de la configuration en mode développement
      if (isDevelopment) {
        debugPrint('=== Configuration Kartia ===');
        final summary = getConfigSummary();
        summary.forEach((key, value) {
          debugPrint('$key: $value');
        });
        debugPrint('============================');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des configurations: $e');
      // En mode production, vous pourriez vouloir utiliser des valeurs par défaut
      // ou lancer une exception selon votre stratégie
    }
  }
}

/// Classe pour les configurations par défaut
class DefaultConfigs {
  DefaultConfigs._();

  // Configurations par défaut en cas d'absence de fichier .env
  static const String defaultApiVersion = 'v1';
  static const String defaultAppEnvironment = 'development';
  static const bool defaultDebugLogs = true;
  static const bool defaultDevTools = true;
}

/// Extensions utiles pour les configurations
extension ConfigExtensions on String? {
  /// Vérifie si une configuration est présente et non vide
  bool get isConfigured => this != null && this!.isNotEmpty;

  /// Obtient une valeur de configuration avec une valeur par défaut
  String withDefault(String defaultValue) => this ?? defaultValue;
}

/// Énumération pour les environnements
enum AppEnvironment {
  development,
  staging,
  production;

  /// Créer un environnement à partir d'une chaîne
  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  /// Vérifier si c'est un environnement de développement
  bool get isDevelopment => this == AppEnvironment.development;

  /// Vérifier si c'est un environnement de staging
  bool get isStaging => this == AppEnvironment.staging;

  /// Vérifier si c'est un environnement de production
  bool get isProduction => this == AppEnvironment.production;
}

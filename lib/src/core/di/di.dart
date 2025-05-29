// lib/src/core/di/di.dart (VERSION MISE À JOUR COMPLÈTE)

import 'package:flutter/material.dart';
import 'package:kartia/src/core/database/db.dart';
import 'package:kartia/src/core/helpers/network.helper.dart';
import 'package:kartia/src/core/helpers/sharedpreferences.helper.dart';
import 'package:kartia/src/core/services/account_upgrade.service.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';
import 'package:kartia/src/core/services/location.service.dart';
import 'package:kartia/src/core/services/user_sync.service.dart';
// ✅ NOUVEAUX SERVICES
import 'package:kartia/src/core/services/image_upload.service.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // === SERVICES DE BASE ===

  // Enregistrement des instances des différents helpers
  getIt.registerLazySingleton<NetworkInfoHelper>(() => NetworkInfoHelper());
  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(),
  );

  // Services principaux
  getIt.registerLazySingleton<LogService>(() => LogService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreUserService>(
    () => FirestoreUserService(),
  );
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // ✅ NOUVEAUX SERVICES

  // Service d'upload d'images
  getIt.registerLazySingleton<ImageUploadService>(() => ImageUploadService());

  // Service de synchronisation utilisateur
  getIt.registerLazySingleton<UserSyncService>(
    () => UserSyncService(
      firestoreUserService: getIt<FirestoreUserService>(),
      locationService: getIt<LocationService>(),
      logger: getIt<LogService>(),
    ),
  );

  // Service de mise à niveau de compte
  getIt.registerLazySingleton<AccountUpgradeService>(
    () => AccountUpgradeService(
      firestoreUserService: getIt<FirestoreUserService>(),
      logger: getIt<LogService>(),
    ),
  );

  // ✅ MISE À JOUR : Repository d'authentification avec tous les nouveaux services
  getIt.registerLazySingleton<AuthRepositoryInterface>(
    () => AuthRepository(
      authService: getIt<AuthService>(),
      firestoreUserService: getIt<FirestoreUserService>(),
      imageUploadService: getIt<ImageUploadService>(), // ✅ NOUVEAU
      logger: getIt<LogService>(),
    ),
  );

  // === DATABASE ===

  // Enregistrement des instances des DAO pour accéder à la base de données
  getIt.registerLazySingleton<MyDatabase>(() => MyDatabase());

  // === BLOCS ===

  // Enregistrement des instances des différents blocs
  getIt.registerFactory<GpsBloc>(() => GpsBloc(logger: getIt()));
  getIt.registerFactory<AppBloc>(() => AppBloc(logger: getIt()));
  getIt.registerFactory<SplashBloc>(() => SplashBloc());

  // ✅ MISE À JOUR : AuthBloc avec tous les services nécessaires
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepositoryInterface>(),
      locationService: getIt<LocationService>(),
      userSyncService: getIt<UserSyncService>(),
      logger: getIt<LogService>(),
    ),
  );

  // Initialiser le service de logging
  await getIt<LogService>().initialize();

  // Logger l'initialisation du DI
  getIt<LogService>().info(
    'Dependency Injection initialisé avec succès avec tous les nouveaux services',
  );
}

Future<void> dispose() async {
  try {
    getIt<LogService>().info('Nettoyage des ressources DI...');

    // Fermer la base de données
    await getIt<MyDatabase>().close();

    // Nettoyer les services de localisation
    getIt<LocationService>().dispose();

    // ✅ NOUVEAU : Nettoyer les autres services si nécessaire
    // (Les services n'ont pas de méthode dispose pour le moment,
    // mais on peut l'ajouter si nécessaire)

    // Nettoyer GetIt
    await getIt.reset();

    debugPrint('Ressources DI nettoyées avec succès');
  } catch (e) {
    debugPrint('Erreur lors du nettoyage des ressources DI: $e');
  }
}

/// ✅ NOUVELLES MÉTHODES UTILITAIRES

/// Obtenir un service de manière sécurisée avec type générique
T getService<T extends Object>() {
  try {
    return getIt<T>();
  } catch (e) {
    throw Exception(
      'Service $T non disponible. Assurez-vous qu\'il est enregistré dans le DI.',
    );
  }
}

/// Vérifier si un service est disponible
bool isServiceAvailable<T extends Object>() {
  return getIt.isRegistered<T>();
}

/// Obtenir tous les services d'authentification en une fois
class AuthServices {
  final AuthService authService;
  final AuthRepositoryInterface authRepository;
  final FirestoreUserService firestoreUserService;
  final ImageUploadService imageUploadService;
  final AccountUpgradeService accountUpgradeService;
  final UserSyncService userSyncService;
  final LocationService locationService;
  final LogService logger;

  AuthServices._({
    required this.authService,
    required this.authRepository,
    required this.firestoreUserService,
    required this.imageUploadService,
    required this.accountUpgradeService,
    required this.userSyncService,
    required this.locationService,
    required this.logger,
  });

  static AuthServices get instance => AuthServices._(
    authService: getIt<AuthService>(),
    authRepository: getIt<AuthRepositoryInterface>(),
    firestoreUserService: getIt<FirestoreUserService>(),
    imageUploadService: getIt<ImageUploadService>(),
    accountUpgradeService: getIt<AccountUpgradeService>(),
    userSyncService: getIt<UserSyncService>(),
    locationService: getIt<LocationService>(),
    logger: getIt<LogService>(),
  );
}

/// Extensions utiles pour GetIt
extension GetItExtensions on GetIt {
  /// Vérifier si un service est enregistré
  bool isRegistered<T extends Object>({
    Object? instance,
    String? instanceName,
  }) {
    return GetIt.instance.isRegistered<T>(
      instance: instance,
      instanceName: instanceName,
    );
  }

  /// Obtenir un service avec gestion d'erreur
  T? getSafe<T extends Object>({
    Object? param1,
    Object? param2,
    String? instanceName,
  }) {
    try {
      return GetIt.instance.get<T>(
        param1: param1,
        param2: param2,
        instanceName: instanceName,
      );
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération du service ${T.toString()}: $e',
      );
      return null;
    }
  }

  /// ✅ NOUVEAU : Forcer la réinitialisation d'un service
  Future<void> resetService<T extends Object>() async {
    try {
      if (isRegistered<T>()) {
        await unregister<T>();
      }
    } catch (e) {
      debugPrint(
        'Erreur lors de la réinitialisation du service ${T.toString()}: $e',
      );
    }
  }
}

/// Classe pour gérer l'état de l'injection de dépendances
class DIManager {
  static bool _isInitialized = false;
  static final List<String> _initializedServices = [];

  /// Vérifier si le DI est initialisé
  static bool get isInitialized => _isInitialized;

  /// Obtenir la liste des services initialisés
  static List<String> get initializedServices =>
      List.unmodifiable(_initializedServices);

  /// Marquer le DI comme initialisé
  static void markAsInitialized() {
    _isInitialized = true;
    _trackInitializedServices();
  }

  /// ✅ NOUVEAU : Suivre les services initialisés
  static void _trackInitializedServices() {
    _initializedServices.clear();
    _initializedServices.addAll([
      'NetworkInfoHelper',
      'SharedPreferencesHelper',
      'LogService',
      'AuthService',
      'FirestoreUserService',
      'LocationService',
      'ImageUploadService', // ✅ NOUVEAU
      'UserSyncService',
      'AccountUpgradeService', // ✅ NOUVEAU
      'AuthRepository',
      'MyDatabase',
      'GpsBloc',
      'AppBloc',
      'SplashBloc',
      'AuthBloc',
    ]);
  }

  /// Réinitialiser l'état du DI
  static void reset() {
    _isInitialized = false;
    _initializedServices.clear();
  }

  /// Initialiser le DI avec gestion d'erreur
  static Future<bool> safeInit() async {
    try {
      if (!_isInitialized) {
        await init();
        markAsInitialized();

        // ✅ NOUVEAU : Vérifier que tous les services critiques sont disponibles
        final criticalServices = [
          'AuthService',
          'AuthRepositoryInterface',
          'ImageUploadService',
          'UserSyncService',
          'AccountUpgradeService',
        ];

        for (final serviceType in criticalServices) {
          if (!_isServiceRegistered(serviceType)) {
            debugPrint('Service critique manquant: $serviceType');
            return false;
          }
        }

        debugPrint('✅ Tous les services critiques sont disponibles');
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du DI: $e');
      return false;
    }
  }

  /// ✅ NOUVEAU : Vérifier si un service est enregistré par nom
  static bool _isServiceRegistered(String serviceType) {
    try {
      switch (serviceType) {
        case 'AuthService':
          return getIt.isRegistered<AuthService>();
        case 'AuthRepositoryInterface':
          return getIt.isRegistered<AuthRepositoryInterface>();
        case 'ImageUploadService':
          return getIt.isRegistered<ImageUploadService>();
        case 'UserSyncService':
          return getIt.isRegistered<UserSyncService>();
        case 'AccountUpgradeService':
          return getIt.isRegistered<AccountUpgradeService>();
        case 'FirestoreUserService':
          return getIt.isRegistered<FirestoreUserService>();
        case 'LocationService':
          return getIt.isRegistered<LocationService>();
        case 'LogService':
          return getIt.isRegistered<LogService>();
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// ✅ NOUVEAU : Obtenir des informations de diagnostic du DI
  static Map<String, dynamic> getDiagnosticInfo() {
    return {
      'isInitialized': _isInitialized,
      'initializedServices': _initializedServices,
      'serviceCount': _initializedServices.length,
      'criticalServicesAvailable': {
        'AuthService': _isServiceRegistered('AuthService'),
        'AuthRepository': _isServiceRegistered('AuthRepositoryInterface'),
        'ImageUploadService': _isServiceRegistered('ImageUploadService'),
        'UserSyncService': _isServiceRegistered('UserSyncService'),
        'AccountUpgradeService': _isServiceRegistered('AccountUpgradeService'),
      },
    };
  }

  /// ✅ NOUVEAU : Vérifier la santé du DI
  static bool checkHealth() {
    if (!_isInitialized) return false;

    final criticalServices = [
      'AuthService',
      'AuthRepositoryInterface',
      'ImageUploadService',
      'UserSyncService',
      'AccountUpgradeService',
    ];

    return criticalServices.every(_isServiceRegistered);
  }
}

/// ✅ NOUVEAU : Classe pour les constantes de services
class ServiceKeys {
  static const String authService = 'AuthService';
  static const String authRepository = 'AuthRepositoryInterface';
  static const String imageUploadService = 'ImageUploadService';
  static const String userSyncService = 'UserSyncService';
  static const String accountUpgradeService = 'AccountUpgradeService';
  static const String firestoreUserService = 'FirestoreUserService';
  static const String locationService = 'LocationService';
  static const String logService = 'LogService';
}

/// ✅ NOUVEAU : Helper pour l'injection de dépendances en mode debug
class DIDebugHelper {
  /// Afficher toutes les informations de diagnostic
  static void printDiagnosticInfo() {
    if (!DIManager.isInitialized) {
      debugPrint('❌ DI non initialisé');
      return;
    }

    final info = DIManager.getDiagnosticInfo();
    debugPrint('📊 DIAGNOSTIC DI:');
    debugPrint('✅ Initialisé: ${info['isInitialized']}');
    debugPrint('📦 Services: ${info['serviceCount']}');
    debugPrint('🔧 Services critiques:');

    final criticalServices =
        info['criticalServicesAvailable'] as Map<String, dynamic>;
    criticalServices.forEach((service, available) {
      final status = available ? '✅' : '❌';
      debugPrint('  $status $service');
    });
  }
}

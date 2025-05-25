import 'package:flutter/material.dart';
import 'package:kartia/src/core/database/db.dart';
import 'package:kartia/src/core/helpers/network.helper.dart';
import 'package:kartia/src/core/helpers/sharedpreferences.helper.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  //Utils
  // Enregistrement des instances des différents helpers
  getIt.registerLazySingleton<NetworkInfoHelper>(() => NetworkInfoHelper());
  getIt.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(),
  );
  getIt.registerLazySingleton<LogService>(() => LogService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  getIt.registerLazySingleton<AuthRepositoryInterface>(
    () => AuthRepository(
      authService: getIt<AuthService>(),
      logger: getIt<LogService>(),
    ),
  );

  // Database
  // Enregistrement des instances des DAO pour accéder à la base de données
  getIt.registerLazySingleton<MyDatabase>(() => MyDatabase());

  //Bloc
  // Enregistrement des instances des différents blocs
  getIt.registerFactory<GpsBloc>(() => GpsBloc(logger: getIt()));
  getIt.registerFactory<AppBloc>(() => AppBloc(logger: getIt()));
  getIt.registerFactory<SplashBloc>(() => SplashBloc());

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepositoryInterface>(),
      logger: getIt<LogService>(),
    ),
  );

  // Initialiser le service de logging
  await getIt<LogService>().initialize();

  // Logger l'initialisation du DI
  getIt<LogService>().info('Dependency Injection initialisé avec succès');
}

Future<void> dispose() async {
  try {
    getIt<LogService>().info('Nettoyage des ressources DI...');

    // Fermer la base de données
    await getIt<MyDatabase>().close();

    // Nettoyer GetIt
    await getIt.reset();

    debugPrint('Ressources DI nettoyées avec succès');
  } catch (e) {
    debugPrint('Erreur lors du nettoyage des ressources DI: $e');
  }
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
}

/// Classe pour gérer l'état de l'injection de dépendances
class DIManager {
  static bool _isInitialized = false;

  /// Vérifier si le DI est initialisé
  static bool get isInitialized => _isInitialized;

  /// Marquer le DI comme initialisé
  static void markAsInitialized() {
    _isInitialized = true;
  }

  /// Réinitialiser l'état du DI
  static void reset() {
    _isInitialized = false;
  }

  /// Initialiser le DI avec gestion d'erreur
  static Future<bool> safeInit() async {
    try {
      if (!_isInitialized) {
        await init();
        markAsInitialized();
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du DI: $e');
      return false;
    }
  }
}

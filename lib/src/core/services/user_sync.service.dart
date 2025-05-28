// lib/src/core/services/user_sync.service.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';
import 'package:kartia/src/core/services/location.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Service pour synchroniser automatiquement les données utilisateur
class UserSyncService {
  final FirestoreUserService _firestoreUserService;
  final LocationService _locationService;
  final LogService _logger;

  UserSyncService({
    required FirestoreUserService firestoreUserService,
    required LocationService locationService,
    required LogService logger,
  }) : _firestoreUserService = firestoreUserService,
       _locationService = locationService,
       _logger = logger;

  /// Synchroniser les données utilisateur au démarrage de l'application
  Future<FirestoreUserModel?> syncUserDataOnAppStart({
    required UserModel authUser,
    FirestoreUserModel? existingFirestoreUser,
  }) async {
    try {
      _logger.info(
        'Début de la synchronisation des données utilisateur: ${authUser.uid}',
      );

      // Récupérer les données actuelles du système
      final currentAppInfo = await _getCurrentAppInfo();
      final currentDeviceInfo = await _getCurrentDeviceInfo();
      final currentLocation = await _getCurrentLocationIfPermitted();

      // Si l'utilisateur n'existe pas dans Firestore, le créer
      if (existingFirestoreUser == null) {
        _logger.info('Utilisateur non trouvé dans Firestore, création...');
        return await _createNewFirestoreUser(
          authUser,
          currentAppInfo,
          currentDeviceInfo,
          currentLocation,
        );
      }

      // Sinon, vérifier et mettre à jour les données si nécessaire
      return await _updateUserDataIfNeeded(
        authUser,
        existingFirestoreUser,
        currentAppInfo,
        currentDeviceInfo,
        currentLocation,
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de la synchronisation des données utilisateur',
        e,
      );
      return existingFirestoreUser;
    }
  }

  /// Créer un nouvel utilisateur Firestore
  Future<FirestoreUserModel> _createNewFirestoreUser(
    UserModel authUser,
    AppInfo appInfo,
    DeviceInfo deviceInfo,
    UserLocation? location,
  ) async {
    final fullName =
        authUser.displayName ??
        authUser.email?.split('@')[0] ??
        authUser.phoneNumber ??
        'Utilisateur';

    return await _firestoreUserService.createUser(
      authUser: authUser,
      fullName: fullName,
    );
  }

  /// Mettre à jour les données utilisateur si nécessaire
  Future<FirestoreUserModel> _updateUserDataIfNeeded(
    UserModel authUser,
    FirestoreUserModel existingUser,
    AppInfo currentAppInfo,
    DeviceInfo currentDeviceInfo,
    UserLocation? currentLocation,
  ) async {
    final updates = <String, dynamic>{};
    bool hasChanges = false;

    // 1. Vérifier et mettre à jour les informations de base de Firebase Auth
    final authUpdates = _checkAuthInfoUpdates(authUser, existingUser);
    if (authUpdates.isNotEmpty) {
      updates.addAll(authUpdates);
      hasChanges = true;
      _logger.info(
        'Mises à jour détectées dans les informations d\'authentification',
      );
    }

    // 2. Vérifier et mettre à jour les informations de l'application
    final appUpdates = _checkAppInfoUpdates(
      currentAppInfo,
      existingUser.appInfo,
    );
    if (appUpdates.isNotEmpty) {
      updates['appInfo'] = appUpdates;
      hasChanges = true;
      _logger.info(
        'Mises à jour détectées dans les informations de l\'application',
      );
    }

    // 3. Vérifier et mettre à jour les informations de l'appareil
    final deviceUpdates = _checkDeviceInfoUpdates(
      currentDeviceInfo,
      existingUser.deviceInfo,
    );
    if (deviceUpdates.isNotEmpty) {
      updates['deviceInfo'] = deviceUpdates;
      hasChanges = true;
      _logger.info(
        'Mises à jour détectées dans les informations de l\'appareil',
      );
    }

    // 4. Mettre à jour la localisation si disponible et autorisée
    if (currentLocation != null &&
        existingUser.preferences.locationSharingEnabled) {
      updates['currentLocation'] = currentLocation.toMap();
      updates['locationHistory'] =
          existingUser.locationHistory.length > 50
              ? [currentLocation.toMap()] // Réinitialiser si trop d'entrées
              : [
                ...existingUser.locationHistory.map((l) => l.toMap()),
                currentLocation.toMap(),
              ];
      hasChanges = true;
      _logger.info('Position mise à jour');
    }

    // 5. Mettre à jour la dernière connexion
    updates['lastSignInAt'] = DateTime.now();
    hasChanges = true;

    // Appliquer les mises à jour si nécessaire
    if (hasChanges) {
      await _firestoreUserService.updateUser(authUser.uid, updates);
      _logger.info('Données utilisateur mises à jour avec succès');

      // Retourner la version mise à jour
      return existingUser.copyWith(
        email: authUser.email,
        phoneNumber: authUser.phoneNumber,
        photoURL: authUser.photoURL,
        emailVerified: authUser.emailVerified,
        phoneVerified: authUser.phoneNumber != null,
        lastSignInAt: DateTime.now(),
        appInfo: currentAppInfo,
        deviceInfo: currentDeviceInfo,
        currentLocation: currentLocation,
      );
    }
  }

  /// Vérifier les mises à jour des informations d'authentification
  Map<String, dynamic> _checkAuthInfoUpdates(
    UserModel authUser,
    FirestoreUserModel existingUser,
  ) {
    final updates = <String, dynamic>{};

    // Email
    if (authUser.email != existingUser.email) {
      updates['email'] = authUser.email;
    }

    // Numéro de téléphone
    if (authUser.phoneNumber != existingUser.phoneNumber) {
      updates['phoneNumber'] = authUser.phoneNumber;
      updates['phoneVerified'] = authUser.phoneNumber != null;
    }

    // Photo de profil
    if (authUser.photoURL != existingUser.photoURL) {
      updates['photoURL'] = authUser.photoURL;
    }

    // Statut de vérification de l'email
    if (authUser.emailVerified != existingUser.emailVerified) {
      updates['emailVerified'] = authUser.emailVerified;
    }

    // Nom d'affichage (seulement si ce n'est pas vide et différent)
    if (authUser.displayName != null &&
        authUser.displayName!.isNotEmpty &&
        authUser.displayName != existingUser.fullName) {
      updates['fullName'] = authUser.displayName;
    }

    return updates;
  }

  /// Vérifier les mises à jour des informations de l'application
  Map<String, dynamic> _checkAppInfoUpdates(
    AppInfo currentAppInfo,
    AppInfo existingAppInfo,
  ) {
    final updates = <String, dynamic>{};

    // Version de l'application
    if (currentAppInfo.version != existingAppInfo.version) {
      updates['version'] = currentAppInfo.version;
    }

    // Numéro de build
    if (currentAppInfo.buildNumber != existingAppInfo.buildNumber) {
      updates['buildNumber'] = currentAppInfo.buildNumber;
    }

    // Plateforme (normalement ne change pas, mais au cas où)
    if (currentAppInfo.platform != existingAppInfo.platform) {
      updates['platform'] = currentAppInfo.platform;
    }

    // Environnement
    if (currentAppInfo.environment != existingAppInfo.environment) {
      updates['environment'] = currentAppInfo.environment;
    }

    return updates.isNotEmpty ? currentAppInfo.toMap() : {};
  }

  /// Vérifier les mises à jour des informations de l'appareil
  Map<String, dynamic> _checkDeviceInfoUpdates(
    DeviceInfo currentDeviceInfo,
    DeviceInfo existingDeviceInfo,
  ) {
    final updates = <String, dynamic>{};

    // Version du système d'exploitation
    if (currentDeviceInfo.osVersion != existingDeviceInfo.osVersion) {
      updates['osVersion'] = currentDeviceInfo.osVersion;
    }

    // Version de la plateforme
    if (currentDeviceInfo.platformVersion !=
        existingDeviceInfo.platformVersion) {
      updates['platformVersion'] = currentDeviceInfo.platformVersion;
    }

    // Langue du système
    if (currentDeviceInfo.language != existingDeviceInfo.language) {
      updates['language'] = currentDeviceInfo.language;
    }

    // Pays
    if (currentDeviceInfo.country != existingDeviceInfo.country) {
      updates['country'] = currentDeviceInfo.country;
    }

    // Fuseau horaire
    if (currentDeviceInfo.timezone != existingDeviceInfo.timezone) {
      updates['timezone'] = currentDeviceInfo.timezone;
    }

    // Nom de l'appareil (peut changer si l'utilisateur renomme son appareil)
    if (currentDeviceInfo.deviceName != existingDeviceInfo.deviceName) {
      updates['deviceName'] = currentDeviceInfo.deviceName;
    }

    return updates.isNotEmpty ? currentDeviceInfo.toMap() : {};
  }

  /// Récupérer les informations actuelles de l'application
  Future<AppInfo> _getCurrentAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      return AppInfo(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        platform: Platform.operatingSystem,
        environment: _getEnvironment(),
        installDate:
            DateTime.now(), // Cette date ne sera pas utilisée pour les mises à jour
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de la récupération des infos app actuelles',
        e,
      );
      return AppInfo(
        version: 'unknown',
        buildNumber: 'unknown',
        platform: Platform.operatingSystem,
        environment: 'unknown',
        installDate: DateTime.now(),
      );
    }
  }

  /// Récupérer les informations actuelles de l'appareil
  Future<DeviceInfo> _getCurrentDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return DeviceInfo(
          deviceId: androidInfo.id,
          deviceName: androidInfo.device,
          model: androidInfo.model,
          brand: androidInfo.brand,
          osVersion: androidInfo.version.release,
          platformVersion: androidInfo.version.sdkInt.toString(),
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          language: Platform.localeName.split('_')[0],
          country:
              Platform.localeName.split('_').length > 1
                  ? Platform.localeName.split('_')[1]
                  : 'Unknown',
          timezone: DateTime.now().timeZoneName,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return DeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? 'unknown',
          deviceName: iosInfo.name,
          model: iosInfo.model,
          brand: 'Apple',
          osVersion: iosInfo.systemVersion,
          platformVersion: iosInfo.systemVersion,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          language: Platform.localeName.split('_')[0],
          country:
              Platform.localeName.split('_').length > 1
                  ? Platform.localeName.split('_')[1]
                  : 'Unknown',
          timezone: DateTime.now().timeZoneName,
        );
      } else {
        return DeviceInfo(
          deviceId: 'unknown',
          deviceName: 'unknown',
          model: 'unknown',
          brand: 'unknown',
          osVersion: Platform.operatingSystemVersion,
          platformVersion: Platform.operatingSystemVersion,
          isPhysicalDevice: true,
          language: Platform.localeName.split('_')[0],
          country:
              Platform.localeName.split('_').length > 1
                  ? Platform.localeName.split('_')[1]
                  : 'Unknown',
          timezone: DateTime.now().timeZoneName,
        );
      }
    } catch (e) {
      _logger.error(
        'Erreur lors de la récupération des infos appareil actuelles',
        e,
      );
      return DeviceInfo(
        deviceId: 'unknown',
        deviceName: 'unknown',
        model: 'unknown',
        brand: 'unknown',
        osVersion: 'unknown',
        platformVersion: 'unknown',
        isPhysicalDevice: true,
        language: 'fr',
        country: 'CM',
        timezone: DateTime.now().timeZoneName,
      );
    }
  }

  /// Récupérer la position actuelle si les permissions sont accordées
  Future<UserLocation?> _getCurrentLocationIfPermitted() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (e) {
      _logger.debug('Position non disponible: $e');
      return null;
    }
  }

  /// Déterminer l'environnement de l'application
  String _getEnvironment() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'production';
    } else {
      return 'development';
    }
  }

  /// Vérifier si une synchronisation est nécessaire
  /// (peut être appelé périodiquement pendant l'utilisation de l'app)
  Future<bool> shouldSync(FirestoreUserModel firestoreUser) async {
    try {
      // Vérifier si la dernière synchronisation remonte à plus de 24h
      final lastSync = firestoreUser.updatedAt;
      final now = DateTime.now();
      final difference = now.difference(lastSync);

      if (difference.inHours >= 24) {
        _logger.info(
          'Synchronisation nécessaire: dernière sync il y a ${difference.inHours} heures',
        );
        return true;
      }

      // Vérifier si la version de l'app a changé
      final currentAppInfo = await _getCurrentAppInfo();
      if (currentAppInfo.version != firestoreUser.appInfo.version ||
          currentAppInfo.buildNumber != firestoreUser.appInfo.buildNumber) {
        _logger.info('Synchronisation nécessaire: version de l\'app changée');
        return true;
      }

      return false;
    } catch (e) {
      _logger.error('Erreur lors de la vérification de synchronisation', e);
      return false;
    }
  }
}

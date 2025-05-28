import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Service pour gérer les utilisateurs dans Firestore
class FirestoreUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LogService _logger = LogService();

  static const String _usersCollection = 'users';

  /// Créer un nouvel utilisateur dans Firestore
  Future<FirestoreUserModel> createUser({
    required UserModel authUser,
    required String fullName,
    String? customUsername,
  }) async {
    try {
      _logger.info(
        'Création d\'un nouvel utilisateur Firestore: ${authUser.uid}',
      );

      // Générer un nom d'utilisateur unique
      final username =
          customUsername ?? await _generateUniqueUsername(fullName);

      // Récupérer les informations sur l'appareil et l'application
      final appInfo = await _getAppInfo();
      final deviceInfo = await _getDeviceInfo();

      // Récupérer la position si les permissions sont accordées
      final location = await _getCurrentLocation();

      // Créer le modèle utilisateur Firestore
      final firestoreUser = FirestoreUserModel.fromAuthUser(
        authUser: authUser,
        fullName: fullName,
        username: username,
        appInfo: appInfo,
        deviceInfo: deviceInfo,
        location: location,
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(authUser.uid)
          .set(firestoreUser.toFirestore());

      _logger.info('Utilisateur Firestore créé avec succès: ${authUser.uid}');
      return firestoreUser;
    } catch (e) {
      _logger.error(
        'Erreur lors de la création de l\'utilisateur Firestore',
        e,
      );
      rethrow;
    }
  }

  /// Récupérer un utilisateur depuis Firestore
  Future<FirestoreUserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        _logger.info('Utilisateur non trouvé dans Firestore: $userId');
        return null;
      }

      return FirestoreUserModel.fromFirestore(doc);
    } catch (e) {
      _logger.error('Erreur lors de la récupération de l\'utilisateur', e);
      return null;
    }
  }

  /// Mettre à jour un utilisateur dans Firestore
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Ajouter la date de mise à jour
      updates['updatedAt'] = Timestamp.now();

      await _firestore.collection(_usersCollection).doc(userId).update(updates);

      _logger.info('Utilisateur mis à jour: $userId');
    } catch (e) {
      _logger.error('Erreur lors de la mise à jour de l\'utilisateur', e);
      rethrow;
    }
  }

  /// Mettre à jour la dernière connexion
  Future<void> updateLastSignIn(String userId) async {
    try {
      await updateUser(userId, {'lastSignInAt': Timestamp.now()});
    } catch (e) {
      _logger.error(
        'Erreur lors de la mise à jour de la dernière connexion',
        e,
      );
    }
  }

  /// Mettre à jour la position de l'utilisateur
  Future<void> updateUserLocation(String userId, UserLocation location) async {
    try {
      await updateUser(userId, {
        'currentLocation': location.toMap(),
        'locationHistory': FieldValue.arrayUnion([location.toMap()]),
      });
    } catch (e) {
      _logger.error('Erreur lors de la mise à jour de la position', e);
    }
  }

  /// Vérifier si un nom d'utilisateur existe déjà
  Future<bool> usernameExists(String username) async {
    try {
      final query =
          await _firestore
              .collection(_usersCollection)
              .where('username', isEqualTo: username)
              .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      _logger.error('Erreur lors de la vérification du nom d\'utilisateur', e);
      return true; // En cas d'erreur, considérer que le nom existe
    }
  }

  /// Supprimer un utilisateur de Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();

      _logger.info('Utilisateur supprimé de Firestore: $userId');
    } catch (e) {
      _logger.error('Erreur lors de la suppression de l\'utilisateur', e);
      rethrow;
    }
  }

  /// Générer un nom d'utilisateur unique
  Future<String> _generateUniqueUsername(String fullName) async {
    // Nettoyer le nom complet pour créer une base
    final cleanName = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .substring(0, fullName.length > 15 ? 15 : fullName.length);

    String username = cleanName;
    int attempt = 0;

    // Vérifier l'unicité et ajouter un nombre si nécessaire
    while (await usernameExists(username)) {
      attempt++;
      final random = Random().nextInt(9999);
      username = '$cleanName$random';

      // Limiter à 10 tentatives pour éviter une boucle infinie
      if (attempt > 10) {
        username = '${cleanName}_${DateTime.now().millisecondsSinceEpoch}';
        break;
      }
    }

    return username;
  }

  /// Récupérer les informations sur l'application
  Future<AppInfo> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      return AppInfo(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        platform: Platform.operatingSystem,
        environment: _getEnvironment(),
        installDate: DateTime.now(), // Pour une nouvelle installation
      );
    } catch (e) {
      _logger.error('Erreur lors de la récupération des infos app', e);
      return AppInfo(
        version: 'unknown',
        buildNumber: 'unknown',
        platform: Platform.operatingSystem,
        environment: 'unknown',
        installDate: DateTime.now(),
      );
    }
  }

  /// Récupérer les informations sur l'appareil
  Future<DeviceInfo> _getDeviceInfo() async {
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
      _logger.error('Erreur lors de la récupération des infos appareil', e);
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

  /// Récupérer la position actuelle de l'utilisateur
  Future<UserLocation?> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _logger.info('Permissions de localisation refusées');
        return null;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Récupérer la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
        // L'adresse peut être récupérée via un service de géocodage inverse
      );
    } catch (e) {
      _logger.error('Erreur lors de la récupération de la position', e);
      return null;
    }
  }

  /// Déterminer l'environnement de l'application
  String _getEnvironment() {
    // Vous pouvez personnaliser cette logique selon vos besoins
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'production';
    } else {
      return 'development';
    }
  }

  /// Stream pour écouter les changements d'un utilisateur
  Stream<FirestoreUserModel?> getUserStream(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return FirestoreUserModel.fromFirestore(doc);
    });
  }

  /// Rechercher des utilisateurs par nom d'utilisateur
  Future<List<FirestoreUserModel>> searchUsersByUsername(String query) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_usersCollection)
              .where('username', isGreaterThanOrEqualTo: query)
              .where('username', isLessThan: '$query\uf8ff')
              .limit(20)
              .get();

      return querySnapshot.docs
          .map((doc) => FirestoreUserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.error('Erreur lors de la recherche d\'utilisateurs', e);
      return [];
    }
  }

  /// Mettre à jour les préférences utilisateur
  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      await updateUser(userId, {'preferences': preferences.toMap()});
    } catch (e) {
      _logger.error('Erreur lors de la mise à jour des préférences', e);
      rethrow;
    }
  }
}

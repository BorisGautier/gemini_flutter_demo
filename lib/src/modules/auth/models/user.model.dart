import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour représenter un utilisateur
class UserModel extends Equatable {
  /// Identifiant unique de l'utilisateur
  final String uid;

  /// Adresse email de l'utilisateur
  final String? email;

  /// Nom d'affichage de l'utilisateur
  final String? displayName;

  /// URL de la photo de profil
  final String? photoURL;

  /// Numéro de téléphone de l'utilisateur
  final String? phoneNumber;

  /// Statut de vérification de l'email
  final bool emailVerified;

  /// Indique si l'utilisateur est connecté de manière anonyme
  final bool isAnonymous;

  /// Date de création du compte
  final DateTime? creationTime;

  /// Date de dernière connexion
  final DateTime? lastSignInTime;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified = false,
    this.isAnonymous = false,
    this.creationTime,
    this.lastSignInTime,
  });

  /// Factory pour créer un UserModel à partir d'un Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      phoneNumber: map['phoneNumber'],
      emailVerified: map['emailVerified'] ?? false,
      isAnonymous: map['isAnonymous'] ?? false,
      creationTime:
          map['creationTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['creationTime'])
              : null,
      lastSignInTime:
          map['lastSignInTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastSignInTime'])
              : null,
    );
  }

  /// Convertir le UserModel en Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'creationTime': creationTime?.millisecondsSinceEpoch,
      'lastSignInTime': lastSignInTime?.millisecondsSinceEpoch,
    };
  }

  /// Factory pour créer un UserModel vide
  factory UserModel.empty() {
    return const UserModel(
      uid: '',
      email: null,
      displayName: null,
      photoURL: null,
      phoneNumber: null,
      emailVerified: false,
      isAnonymous: false,
      creationTime: null,
      lastSignInTime: null,
    );
  }

  /// Vérifier si l'utilisateur est vide
  bool get isEmpty => uid.isEmpty;

  /// Vérifier si l'utilisateur n'est pas vide
  bool get isNotEmpty => !isEmpty;

  /// Obtenir le nom d'affichage ou l'email si le nom n'est pas disponible
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return phoneNumber!;
    }
    return 'Utilisateur';
  }

  /// Obtenir les initiales du nom d'affichage
  String get initials {
    final name = displayNameOrEmail;
    if (name.isEmpty) return 'U';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Créer une copie du UserModel avec des modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    bool? isAnonymous,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      creationTime: creationTime ?? this.creationTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    phoneNumber,
    emailVerified,
    isAnonymous,
    creationTime,
    lastSignInTime,
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, '
        'photoURL: $photoURL, phoneNumber: $phoneNumber, '
        'emailVerified: $emailVerified, isAnonymous: $isAnonymous, '
        'creationTime: $creationTime, lastSignInTime: $lastSignInTime)';
  }
}

/// Énumération pour les types d'authentification
enum AuthProvider { email, phone, google, anonymous }

/// Extension pour obtenir le provider d'authentification à partir d'un UserModel
extension UserModelAuthProvider on UserModel {
  /// Obtenir le type de provider d'authentification principal
  AuthProvider get primaryAuthProvider {
    if (isAnonymous) return AuthProvider.anonymous;
    if (email != null && email!.contains('@')) return AuthProvider.email;
    if (phoneNumber != null) return AuthProvider.phone;
    return AuthProvider.email; // Par défaut
  }

  /// Vérifier si l'utilisateur peut se connecter avec le téléphone
  bool get canSignInWithPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
}

// ✅ NOUVEAUX MODÈLES POUR FIRESTORE

/// Modèle de données Firestore pour les utilisateurs
class FirestoreUserModel extends Equatable {
  final String userId;
  final String fullName;
  final String username;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final bool emailVerified;
  final bool phoneVerified;
  final String authProvider;
  final bool isAnonymous;
  final String accountStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSignInAt;
  final AppInfo appInfo;
  final DeviceInfo deviceInfo;
  final UserLocation? currentLocation;
  final List<UserLocation> locationHistory;
  final UserPreferences preferences;
  final Map<String, dynamic> metadata;

  const FirestoreUserModel({
    required this.userId,
    required this.fullName,
    required this.username,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.authProvider,
    this.isAnonymous = false,
    this.accountStatus = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.lastSignInAt,
    required this.appInfo,
    required this.deviceInfo,
    this.currentLocation,
    this.locationHistory = const [],
    required this.preferences,
    this.metadata = const {},
  });

  factory FirestoreUserModel.fromAuthUser({
    required UserModel authUser,
    required String fullName,
    required String username,
    required AppInfo appInfo,
    required DeviceInfo deviceInfo,
    UserLocation? location,
    UserPreferences? preferences,
  }) {
    return FirestoreUserModel(
      userId: authUser.uid,
      fullName: fullName,
      username: username,
      email: authUser.email,
      phoneNumber: authUser.phoneNumber,
      photoURL: authUser.photoURL,
      emailVerified: authUser.emailVerified,
      phoneVerified: authUser.phoneNumber != null,
      authProvider: authUser.primaryAuthProvider.name,
      isAnonymous: authUser.isAnonymous,
      accountStatus: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastSignInAt: authUser.lastSignInTime,
      appInfo: appInfo,
      deviceInfo: deviceInfo,
      currentLocation: location,
      locationHistory: location != null ? [location] : [],
      preferences: preferences ?? UserPreferences.defaultPreferences(),
      metadata: {},
    );
  }

  factory FirestoreUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirestoreUserModel(
      userId: doc.id,
      fullName: data['fullName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      emailVerified: data['emailVerified'] ?? false,
      phoneVerified: data['phoneVerified'] ?? false,
      authProvider: data['authProvider'] ?? 'email',
      isAnonymous: data['isAnonymous'] ?? false,
      accountStatus: data['accountStatus'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastSignInAt:
          data['lastSignInAt'] != null
              ? (data['lastSignInAt'] as Timestamp).toDate()
              : null,
      appInfo: AppInfo.fromMap(data['appInfo'] ?? {}),
      deviceInfo: DeviceInfo.fromMap(data['deviceInfo'] ?? {}),
      currentLocation:
          data['currentLocation'] != null
              ? UserLocation.fromMap(data['currentLocation'])
              : null,
      locationHistory:
          (data['locationHistory'] as List<dynamic>?)
              ?.map((e) => UserLocation.fromMap(e))
              .toList() ??
          [],
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'authProvider': authProvider,
      'isAnonymous': isAnonymous,
      'accountStatus': accountStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSignInAt':
          lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'appInfo': appInfo.toMap(),
      'deviceInfo': deviceInfo.toMap(),
      'currentLocation': currentLocation?.toMap(),
      'locationHistory': locationHistory.map((e) => e.toMap()).toList(),
      'preferences': preferences.toMap(),
      'metadata': metadata,
    };
  }

  FirestoreUserModel copyWith({
    String? userId,
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? photoURL,
    bool? emailVerified,
    bool? phoneVerified,
    String? authProvider,
    bool? isAnonymous,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignInAt,
    AppInfo? appInfo,
    DeviceInfo? deviceInfo,
    UserLocation? currentLocation,
    List<UserLocation>? locationHistory,
    UserPreferences? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return FirestoreUserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      authProvider: authProvider ?? this.authProvider,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      appInfo: appInfo ?? this.appInfo,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      currentLocation: currentLocation ?? this.currentLocation,
      locationHistory: locationHistory ?? this.locationHistory,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullName,
    username,
    email,
    phoneNumber,
    photoURL,
    emailVerified,
    phoneVerified,
    authProvider,
    isAnonymous,
    accountStatus,
    createdAt,
    updatedAt,
    lastSignInAt,
    appInfo,
    deviceInfo,
    currentLocation,
    locationHistory,
    preferences,
    metadata,
  ];
}

/// Informations sur l'application
class AppInfo extends Equatable {
  final String version;
  final String buildNumber;
  final String platform;
  final String environment;
  final DateTime installDate;

  const AppInfo({
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.environment,
    required this.installDate,
  });

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      version: map['version'] ?? '',
      buildNumber: map['buildNumber'] ?? '',
      platform: map['platform'] ?? '',
      environment: map['environment'] ?? '',
      installDate:
          map['installDate'] != null
              ? (map['installDate'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'platform': platform,
      'environment': environment,
      'installDate': Timestamp.fromDate(installDate),
    };
  }

  @override
  List<Object?> get props => [
    version,
    buildNumber,
    platform,
    environment,
    installDate,
  ];
}

/// Informations sur l'appareil
class DeviceInfo extends Equatable {
  final String deviceId;
  final String deviceName;
  final String model;
  final String brand;
  final String osVersion;
  final String platformVersion;
  final bool isPhysicalDevice;
  final String language;
  final String country;
  final String timezone;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.model,
    required this.brand,
    required this.osVersion,
    required this.platformVersion,
    required this.isPhysicalDevice,
    required this.language,
    required this.country,
    required this.timezone,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceId: map['deviceId'] ?? '',
      deviceName: map['deviceName'] ?? '',
      model: map['model'] ?? '',
      brand: map['brand'] ?? '',
      osVersion: map['osVersion'] ?? '',
      platformVersion: map['platformVersion'] ?? '',
      isPhysicalDevice: map['isPhysicalDevice'] ?? true,
      language: map['language'] ?? '',
      country: map['country'] ?? '',
      timezone: map['timezone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'model': model,
      'brand': brand,
      'osVersion': osVersion,
      'platformVersion': platformVersion,
      'isPhysicalDevice': isPhysicalDevice,
      'language': language,
      'country': country,
      'timezone': timezone,
    };
  }

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    model,
    brand,
    osVersion,
    platformVersion,
    isPhysicalDevice,
    language,
    country,
    timezone,
  ];
}

/// Position de l'utilisateur
class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime timestamp;
  final String? address;
  final String? city;
  final String? country;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
    this.address,
    this.city,
    this.country,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble(),
      altitude: map['altitude']?.toDouble(),
      speed: map['speed']?.toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      address: map['address'],
      city: map['city'],
      country: map['country'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'timestamp': Timestamp.fromDate(timestamp),
      'address': address,
      'city': city,
      'country': country,
    };
  }

  String get coordinatesString => '$latitude, $longitude';
  bool get isValid => latitude != 0.0 && longitude != 0.0;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    accuracy,
    altitude,
    speed,
    timestamp,
    address,
    city,
    country,
  ];
}

/// Préférences utilisateur
class UserPreferences extends Equatable {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool locationSharingEnabled;
  final bool analyticsEnabled;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    required this.language,
    required this.theme,
    required this.notificationsEnabled,
    required this.locationSharingEnabled,
    required this.analyticsEnabled,
    this.customSettings = const {},
  });

  factory UserPreferences.defaultPreferences() {
    return const UserPreferences(
      language: 'fr',
      theme: 'system',
      notificationsEnabled: true,
      locationSharingEnabled: true,
      analyticsEnabled: true,
      customSettings: {},
    );
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] ?? 'fr',
      theme: map['theme'] ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      locationSharingEnabled: map['locationSharingEnabled'] ?? true,
      analyticsEnabled: map['analyticsEnabled'] ?? true,
      customSettings: Map<String, dynamic>.from(map['customSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'locationSharingEnabled': locationSharingEnabled,
      'analyticsEnabled': analyticsEnabled,
      'customSettings': customSettings,
    };
  }

  @override
  List<Object?> get props => [
    language,
    theme,
    notificationsEnabled,
    locationSharingEnabled,
    analyticsEnabled,
    customSettings,
  ];
}

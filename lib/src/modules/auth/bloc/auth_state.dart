part of 'auth_bloc.dart';

/// Énumération pour le statut d'authentification
enum AuthStatus {
  /// État initial, en cours de vérification
  unknown,

  /// Utilisateur authentifié
  authenticated,

  /// Utilisateur non authentifié
  unauthenticated,

  /// En cours de traitement d'une demande d'authentification
  loading,

  /// Vérification du numéro de téléphone en cours
  phoneVerificationInProgress,

  /// Code SMS envoyé
  phoneCodeSent,

  /// Erreur d'authentification
  error,

  /// Email non vérifié
  emailNotVerified,
}

/// État d'authentification amélioré avec Firestore
class AuthState extends Equatable {
  /// Statut actuel de l'authentification
  final AuthStatus status;

  /// Utilisateur connecté Firebase Auth (null si non connecté)
  final UserModel? user;

  /// Données utilisateur Firestore (null si non chargées)
  final FirestoreUserModel? firestoreUser;

  /// Message d'erreur en cas d'échec
  final String? errorMessage;

  /// Code d'erreur spécifique
  final String? errorCode;

  /// ID de vérification pour l'authentification par téléphone
  final String? verificationId;

  /// Token de renvoi pour l'authentification par téléphone
  final int? resendToken;

  /// Indique si une opération est en cours
  final bool isLoading;

  /// Position actuelle de l'utilisateur
  final UserLocation? currentLocation;

  /// Indique si le suivi de localisation est actif
  final bool isLocationTrackingActive;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.firestoreUser,
    this.errorMessage,
    this.errorCode,
    this.verificationId,
    this.resendToken,
    this.isLoading = false,
    this.currentLocation,
    this.isLocationTrackingActive = false,
  });

  /// État initial
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.unknown,
      user: null,
      firestoreUser: null,
      errorMessage: null,
      errorCode: null,
      verificationId: null,
      resendToken: null,
      isLoading: false,
      currentLocation: null,
      isLocationTrackingActive: false,
    );
  }

  /// État de chargement
  AuthState loading() {
    return copyWith(
      status: AuthStatus.loading,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );
  }

  /// État d'utilisateur authentifié
  AuthState authenticated(UserModel user, FirestoreUserModel? firestoreUser) {
    return copyWith(
      status: AuthStatus.authenticated,
      user: user,
      firestoreUser: firestoreUser,
      isLoading: false,
      errorMessage: null,
      errorCode: null,
      currentLocation: firestoreUser?.currentLocation,
      isLocationTrackingActive:
          firestoreUser?.preferences.locationSharingEnabled ?? false,
    );
  }

  /// État d'utilisateur non authentifié
  AuthState unauthenticated() {
    return copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      firestoreUser: null,
      isLoading: false,
      errorMessage: null,
      errorCode: null,
      verificationId: null,
      resendToken: null,
      currentLocation: null,
      isLocationTrackingActive: false,
    );
  }

  /// État d'email non vérifié
  AuthState emailNotVerified(
    UserModel user,
    FirestoreUserModel? firestoreUser,
  ) {
    return copyWith(
      status: AuthStatus.emailNotVerified,
      user: user,
      firestoreUser: firestoreUser,
      isLoading: false,
      errorMessage: null,
      errorCode: null,
      currentLocation: firestoreUser?.currentLocation,
      isLocationTrackingActive:
          false, // Pas de suivi pour les emails non vérifiés
    );
  }

  /// État d'erreur
  AuthState error({required String message, String? code}) {
    return copyWith(
      status: AuthStatus.error,
      isLoading: false,
      errorMessage: message,
      errorCode: code,
    );
  }

  /// État de vérification de téléphone en cours
  AuthState phoneVerificationInProgress() {
    return copyWith(
      status: AuthStatus.phoneVerificationInProgress,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );
  }

  /// État de code SMS envoyé
  AuthState phoneCodeSent({required String verificationId, int? resendToken}) {
    return copyWith(
      status: AuthStatus.phoneCodeSent,
      isLoading: false,
      verificationId: verificationId,
      resendToken: resendToken,
      errorMessage: null,
      errorCode: null,
    );
  }

  /// Créer une copie de l'état avec des modifications
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    FirestoreUserModel? firestoreUser,
    String? errorMessage,
    String? errorCode,
    String? verificationId,
    int? resendToken,
    bool? isLoading,
    UserLocation? currentLocation,
    bool? isLocationTrackingActive,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      firestoreUser: firestoreUser ?? this.firestoreUser,
      errorMessage: errorMessage,
      errorCode: errorCode,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isLoading: isLoading ?? this.isLoading,
      currentLocation: currentLocation ?? this.currentLocation,
      isLocationTrackingActive:
          isLocationTrackingActive ?? this.isLocationTrackingActive,
    );
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Vérifier si l'utilisateur n'est pas connecté
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Vérifier si l'email n'est pas vérifié
  bool get isEmailNotVerified => status == AuthStatus.emailNotVerified;

  /// Vérifier s'il y a une erreur
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  /// Vérifier si le code SMS a été envoyé
  bool get isPhoneCodeSent =>
      status == AuthStatus.phoneCodeSent && verificationId != null;

  /// Vérifier si la vérification du téléphone est en cours
  bool get isPhoneVerificationInProgress =>
      status == AuthStatus.phoneVerificationInProgress;

  /// Obtenir le nom d'affichage de l'utilisateur
  String get displayName {
    if (firestoreUser?.fullName.isNotEmpty == true) {
      return firestoreUser!.fullName;
    }
    if (user?.displayName?.isNotEmpty == true) {
      return user!.displayName!;
    }
    if (user?.email?.isNotEmpty == true) {
      return user!.email!.split('@')[0];
    }
    if (user?.phoneNumber?.isNotEmpty == true) {
      return user!.phoneNumber!;
    }
    return 'Utilisateur';
  }

  /// Obtenir le nom d'utilisateur unique
  String? get username => firestoreUser?.username;

  /// Obtenir l'URL de la photo de profil
  String? get photoURL => firestoreUser?.photoURL ?? user?.photoURL;

  /// Vérifier si l'utilisateur a un profil Firestore complet
  bool get hasCompleteProfile {
    return firestoreUser != null &&
        firestoreUser!.fullName.isNotEmpty &&
        firestoreUser!.username.isNotEmpty;
  }

  /// Obtenir les préférences utilisateur
  UserPreferences get preferences {
    return firestoreUser?.preferences ?? UserPreferences.defaultPreferences();
  }

  /// Vérifier si l'utilisateur autorise le partage de localisation
  bool get isLocationSharingEnabled {
    return preferences.locationSharingEnabled && isLocationTrackingActive;
  }

  /// Obtenir les informations sur l'appareil
  DeviceInfo? get deviceInfo => firestoreUser?.deviceInfo;

  /// Obtenir les informations sur l'application
  AppInfo? get appInfo => firestoreUser?.appInfo;

  /// Vérifier si l'utilisateur est anonyme
  bool get isAnonymous => user?.isAnonymous ?? false;

  /// Obtenir l'historique des positions
  List<UserLocation> get locationHistory =>
      firestoreUser?.locationHistory ?? [];

  /// Obtenir la dernière position connue
  UserLocation? get lastKnownLocation {
    if (currentLocation != null) return currentLocation;
    if (locationHistory.isNotEmpty) return locationHistory.last;
    return null;
  }

  /// Vérifier si l'utilisateur peut utiliser certaines fonctionnalités
  bool get canUseLocationFeatures {
    return isAuthenticated && !isEmailNotVerified && isLocationSharingEnabled;
  }

  /// Obtenir un résumé de l'état pour le debug
  String get debugInfo {
    return '''
AuthState Debug Info:
- Status: $status
- User ID: ${user?.uid ?? 'null'}
- Firestore User: ${firestoreUser?.userId ?? 'null'}
- Is Loading: $isLoading
- Has Error: $hasError
- Error Message: $errorMessage
- Location Tracking: $isLocationTrackingActive
- Current Location: ${currentLocation?.coordinatesString ?? 'null'}
- Display Name: $displayName
- Username: ${username ?? 'null'}
- Complete Profile: $hasCompleteProfile
    ''';
  }

  @override
  List<Object?> get props => [
    status,
    user,
    firestoreUser,
    errorMessage,
    errorCode,
    verificationId,
    resendToken,
    isLoading,
    currentLocation,
    isLocationTrackingActive,
  ];

  @override
  String toString() {
    return 'AuthState { '
        'status: $status, '
        'user: ${user?.uid}, '
        'firestoreUser: ${firestoreUser?.userId}, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'errorCode: $errorCode, '
        'verificationId: $verificationId, '
        'resendToken: $resendToken, '
        'isLocationTrackingActive: $isLocationTrackingActive, '
        'currentLocation: ${currentLocation?.coordinatesString} '
        '}';
  }
}

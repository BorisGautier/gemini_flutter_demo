part of 'auth_bloc.dart';

/// Classe abstraite pour tous les événements d'authentification
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour initialiser l'authentification
class AuthInitialized extends AuthEvent {
  const AuthInitialized();

  @override
  String toString() => 'AuthInitialized';
}

/// Événement déclenché lors d'un changement d'état d'authentification
class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'AuthUserChanged { user: $user }';
}

/// Événement pour la connexion avec email et mot de passe
class AuthSignInWithEmailAndPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() =>
      'AuthSignInWithEmailAndPasswordRequested { email: $email }';
}

/// Événement pour l'inscription avec email et mot de passe
class AuthSignUpWithEmailAndPasswordRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpWithEmailAndPasswordRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];

  @override
  String toString() =>
      'AuthSignUpWithEmailAndPasswordRequested { email: $email, displayName: $displayName }';
}

/// Événement pour la connexion anonyme
class AuthSignInAnonymouslyRequested extends AuthEvent {
  const AuthSignInAnonymouslyRequested();

  @override
  String toString() => 'AuthSignInAnonymouslyRequested';
}

/// Événement pour la connexion avec Google
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();

  @override
  String toString() => 'AuthSignInWithGoogleRequested';
}

/// Événement pour la vérification du numéro de téléphone
class AuthVerifyPhoneNumberRequested extends AuthEvent {
  final String phoneNumber;

  const AuthVerifyPhoneNumberRequested({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];

  @override
  String toString() =>
      'AuthVerifyPhoneNumberRequested { phoneNumber: $phoneNumber }';
}

/// Événement déclenché quand le code SMS est envoyé
class AuthPhoneCodeSent extends AuthEvent {
  final String verificationId;
  final int? resendToken;

  const AuthPhoneCodeSent({required this.verificationId, this.resendToken});

  @override
  List<Object?> get props => [verificationId, resendToken];

  @override
  String toString() => 'AuthPhoneCodeSent { verificationId: $verificationId }';
}

/// Événement pour les erreurs de vérification téléphone
class AuthPhoneVerificationFailed extends AuthEvent {
  final String message;
  final String? code;

  const AuthPhoneVerificationFailed({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() =>
      'AuthPhoneVerificationFailed { message: $message, code: $code }';
}

/// Événement pour la connexion avec le code SMS
class AuthSignInWithPhoneNumberRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const AuthSignInWithPhoneNumberRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];

  @override
  String toString() =>
      'AuthSignInWithPhoneNumberRequested { verificationId: $verificationId }';
}

/// Événement pour envoyer un email de réinitialisation de mot de passe
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'AuthPasswordResetRequested { email: $email }';
}

/// Événement pour mettre à jour le profil utilisateur
class AuthUpdateUserProfileRequested extends AuthEvent {
  final String? displayName;
  final String? photoURL;

  const AuthUpdateUserProfileRequested({this.displayName, this.photoURL});

  @override
  List<Object?> get props => [displayName, photoURL];

  @override
  String toString() =>
      'AuthUpdateUserProfileRequested { displayName: $displayName, photoURL: $photoURL }';
}

/// Événement pour mettre à jour le mot de passe
class AuthUpdatePasswordRequested extends AuthEvent {
  final String newPassword;

  const AuthUpdatePasswordRequested({required this.newPassword});

  @override
  List<Object> get props => [newPassword];

  @override
  String toString() => 'AuthUpdatePasswordRequested';
}

/// Événement pour envoyer un email de vérification
class AuthSendEmailVerificationRequested extends AuthEvent {
  const AuthSendEmailVerificationRequested();

  @override
  String toString() => 'AuthSendEmailVerificationRequested';
}

/// Événement pour la déconnexion
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();

  @override
  String toString() => 'AuthSignOutRequested';
}

/// Événement pour supprimer le compte
class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();

  @override
  String toString() => 'AuthDeleteAccountRequested';
}

/// Événement pour effacer les erreurs
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();

  @override
  String toString() => 'AuthErrorCleared';
}

// ✅ NOUVEAUX ÉVÉNEMENTS POUR FIRESTORE ET LOCALISATION

/// Événement pour mettre à jour la localisation
class AuthLocationUpdated extends AuthEvent {
  final UserLocation location;

  const AuthLocationUpdated(this.location);

  @override
  List<Object> get props => [location];

  @override
  String toString() =>
      'AuthLocationUpdated { location: ${location.coordinatesString} }';
}

/// Événement pour démarrer le suivi de localisation
class AuthStartLocationTracking extends AuthEvent {
  const AuthStartLocationTracking();

  @override
  String toString() => 'AuthStartLocationTracking';
}

/// Événement pour arrêter le suivi de localisation
class AuthStopLocationTracking extends AuthEvent {
  const AuthStopLocationTracking();

  @override
  String toString() => 'AuthStopLocationTracking';
}

/// Événement quand les données Firestore de l'utilisateur sont chargées
class AuthFirestoreUserLoaded extends AuthEvent {
  final FirestoreUserModel firestoreUser;

  const AuthFirestoreUserLoaded(this.firestoreUser);

  @override
  List<Object> get props => [firestoreUser];

  @override
  String toString() =>
      'AuthFirestoreUserLoaded { userId: ${firestoreUser.userId} }';
}

/// Événement pour mettre à jour les préférences utilisateur
class AuthUpdateUserPreferences extends AuthEvent {
  final UserPreferences preferences;

  const AuthUpdateUserPreferences(this.preferences);

  @override
  List<Object> get props => [preferences];

  @override
  String toString() => 'AuthUpdateUserPreferences';
}

/// Événement pour mettre à jour des données Firestore spécifiques
class AuthUpdateFirestoreData extends AuthEvent {
  final Map<String, dynamic> updates;

  const AuthUpdateFirestoreData(this.updates);

  @override
  List<Object> get props => [updates];

  @override
  String toString() => 'AuthUpdateFirestoreData { updates: $updates }';
}

// Nouveaux événements à ajouter au fichier auth_event.dart

/// Événement pour synchroniser manuellement les données utilisateur
class AuthSyncUserData extends AuthEvent {
  const AuthSyncUserData();

  @override
  String toString() => 'AuthSyncUserData';
}

/// Événement déclenché par la synchronisation périodique
class AuthPeriodicSyncTriggered extends AuthEvent {
  const AuthPeriodicSyncTriggered();

  @override
  String toString() => 'AuthPeriodicSyncTriggered';
}

/// Événement pour forcer une synchronisation complète
class AuthForceSyncUserData extends AuthEvent {
  const AuthForceSyncUserData();

  @override
  String toString() => 'AuthForceSyncUserData';
}

/// Événement pour mettre à jour spécifiquement les informations de l'appareil
class AuthUpdateDeviceInfo extends AuthEvent {
  const AuthUpdateDeviceInfo();

  @override
  String toString() => 'AuthUpdateDeviceInfo';
}

/// Événement pour mettre à jour spécifiquement les informations de l'application
class AuthUpdateAppInfo extends AuthEvent {
  const AuthUpdateAppInfo();

  @override
  String toString() => 'AuthUpdateAppInfo';
}

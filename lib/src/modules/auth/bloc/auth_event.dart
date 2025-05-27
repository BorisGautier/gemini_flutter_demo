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

/// ✅ NOUVEAU: Événement pour les erreurs de vérification téléphone
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

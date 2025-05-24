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
}

/// État d'authentification
class AuthState extends Equatable {
  /// Statut actuel de l'authentification
  final AuthStatus status;

  /// Utilisateur connecté (null si non connecté)
  final UserModel? user;

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

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.verificationId,
    this.resendToken,
    this.isLoading = false,
  });

  /// État initial
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.unknown,
      user: null,
      errorMessage: null,
      errorCode: null,
      verificationId: null,
      resendToken: null,
      isLoading: false,
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
  AuthState authenticated(UserModel user) {
    return copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
      errorMessage: null,
      errorCode: null,
    );
  }

  /// État d'utilisateur non authentifié
  AuthState unauthenticated() {
    return copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      isLoading: false,
      errorMessage: null,
      errorCode: null,
      verificationId: null,
      resendToken: null,
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
    String? errorMessage,
    String? errorCode,
    String? verificationId,
    int? resendToken,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorCode: errorCode,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Vérifier si l'utilisateur n'est pas connecté
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Vérifier s'il y a une erreur
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  /// Vérifier si le code SMS a été envoyé
  bool get isPhoneCodeSent =>
      status == AuthStatus.phoneCodeSent && verificationId != null;

  /// Vérifier si la vérification du téléphone est en cours
  bool get isPhoneVerificationInProgress =>
      status == AuthStatus.phoneVerificationInProgress;

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    errorCode,
    verificationId,
    resendToken,
    isLoading,
  ];

  @override
  String toString() {
    return 'AuthState { '
        'status: $status, '
        'user: ${user?.uid}, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'errorCode: $errorCode, '
        'verificationId: $verificationId, '
        'resendToken: $resendToken '
        '}';
  }
}

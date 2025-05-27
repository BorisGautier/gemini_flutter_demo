import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC pour gérer l'authentification
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;
  final LogService _logger;
  StreamSubscription<UserModel?>? _userSubscription;

  AuthBloc({
    required AuthRepositoryInterface authRepository,
    required LogService logger,
  }) : _authRepository = authRepository,
       _logger = logger,
       super(AuthState.initial()) {
    // Enregistrement des gestionnaires d'événements
    on<AuthInitialized>(_onAuthInitialized);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthSignInWithEmailAndPasswordRequested>(
      _onSignInWithEmailAndPasswordRequested,
    );
    on<AuthSignUpWithEmailAndPasswordRequested>(
      _onSignUpWithEmailAndPasswordRequested,
    );
    on<AuthSignInAnonymouslyRequested>(_onSignInAnonymouslyRequested);
    on<AuthVerifyPhoneNumberRequested>(_onVerifyPhoneNumberRequested);
    on<AuthPhoneCodeSent>(_onPhoneCodeSent);
    on<AuthPhoneVerificationFailed>(_onPhoneVerificationFailed);
    on<AuthSignInWithPhoneNumberRequested>(_onSignInWithPhoneNumberRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthUpdateUserProfileRequested>(_onUpdateUserProfileRequested);
    on<AuthUpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<AuthSendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  /// Initialiser l'authentification
  void _onAuthInitialized(AuthInitialized event, Emitter<AuthState> emit) {
    _logger.info('BLoC: Initialisation de l\'authentification');

    // Écouter les changements d'état d'authentification
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) {
        _logger.info('BLoC: Changement d\'utilisateur détecté: ${user?.uid}');
        add(AuthUserChanged(user));
      },
      onError: (error) {
        _logger.error('BLoC: Erreur dans authStateChanges: $error', error);
      },
    );

    // ✅ NOUVEAU : Vérifier l'utilisateur actuel au démarrage
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      _logger.info(
        'BLoC: Utilisateur existant trouvé au démarrage: ${currentUser.uid}',
      );
      add(AuthUserChanged(currentUser));
    } else {
      _logger.info('BLoC: Aucun utilisateur trouvé au démarrage');
      emit(state.unauthenticated());
    }
  }

  /// Gérer les changements d'utilisateur
  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    _logger.info('BLoC: Changement d\'utilisateur: ${event.user?.uid}');

    if (event.user != null) {
      // ✅ AMÉLIORATION : Logique plus claire pour la vérification d'email
      final user = event.user!;

      // Si l'utilisateur est anonyme ou a un numéro de téléphone, pas besoin de vérification email
      if (user.isAnonymous || user.phoneNumber != null) {
        _logger.info('BLoC: Utilisateur authentifié (anonyme ou téléphone)');
        emit(state.authenticated(user));
      }
      // Si l'utilisateur a un email mais qu'il n'est pas vérifié
      else if (user.email != null && !user.emailVerified) {
        _logger.info(
          'BLoC: Email non vérifié, utilisateur en attente de vérification',
        );
        emit(state.emailNotVerified(user));
      }
      // Utilisateur complètement authentifié
      else {
        _logger.info('BLoC: Utilisateur authentifié avec succès');
        emit(state.authenticated(user));
      }
    } else {
      _logger.info('BLoC: Aucun utilisateur, état non authentifié');
      emit(state.unauthenticated());
    }
  }

  /// Connexion avec email et mot de passe
  Future<void> _onSignInWithEmailAndPasswordRequested(
    AuthSignInWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      _logger.info('BLoC: Tentative de connexion avec email');

      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        _logger.info('BLoC: Connexion réussie');
        // ✅ L'état sera mis à jour via AuthUserChanged qui vérifie l'email
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de connexion Firebase: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de connexion: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Inscription avec email et mot de passe
  Future<void> _onSignUpWithEmailAndPasswordRequested(
    AuthSignUpWithEmailAndPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      _logger.info('BLoC: Tentative d\'inscription avec email');

      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (user != null) {
        _logger.info('BLoC: Inscription réussie');
        // ✅ L'état sera mis à jour via AuthUserChanged qui détectera l'email non vérifié
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur d\'inscription Firebase: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur d\'inscription: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Connexion anonyme
  Future<void> _onSignInAnonymouslyRequested(
    AuthSignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      _logger.info('BLoC: Tentative de connexion anonyme');

      final user = await _authRepository.signInAnonymously();

      if (user != null) {
        _logger.info('BLoC: Connexion anonyme réussie');
        // L'état sera mis à jour via AuthUserChanged
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de connexion anonyme: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de connexion anonyme: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Vérifier le numéro de téléphone
  Future<void> _onVerifyPhoneNumberRequested(
    AuthVerifyPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.phoneVerificationInProgress());

    try {
      _logger.info('BLoC: Vérification du numéro de téléphone');

      await _authRepository.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Connexion automatique réussie (Android uniquement)
          _logger.info('BLoC: Vérification automatique du téléphone réussie');
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.error(
            'BLoC: Échec de la vérification du téléphone: ${e.code}',
            e,
          );
          // ✅ CORRECTION 2: Ne pas appeler AuthErrorCleared, juste émettre l'erreur
          add(
            AuthPhoneVerificationFailed(
              message: _getLocalizedFirebaseError(e.code),
              code: e.code,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.info('BLoC: Code SMS envoyé');
          add(
            AuthPhoneCodeSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.info('BLoC: Timeout de récupération automatique du code');
        },
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de vérification du téléphone: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Code SMS envoyé
  void _onPhoneCodeSent(AuthPhoneCodeSent event, Emitter<AuthState> emit) {
    _logger.info('BLoC: Code SMS reçu');
    emit(
      state.phoneCodeSent(
        verificationId: event.verificationId,
        resendToken: event.resendToken,
      ),
    );
  }

  /// ✅ CORRECTION 3: Nouveau gestionnaire pour les erreurs de vérification téléphone
  void _onPhoneVerificationFailed(
    AuthPhoneVerificationFailed event,
    Emitter<AuthState> emit,
  ) {
    _logger.error('BLoC: Erreur de vérification téléphone: ${event.message}');
    emit(state.error(message: event.message, code: event.code));
  }

  /// Connexion avec le code SMS
  Future<void> _onSignInWithPhoneNumberRequested(
    AuthSignInWithPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      _logger.info('BLoC: Tentative de connexion avec le code SMS');

      final user = await _authRepository.signInWithPhoneNumber(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      if (user != null) {
        _logger.info('BLoC: Connexion par téléphone réussie');
        // L'état sera mis à jour via AuthUserChanged
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de connexion par téléphone: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de connexion par téléphone: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.loading());

    try {
      _logger.info('BLoC: Demande de réinitialisation du mot de passe');

      await _authRepository.sendPasswordResetEmail(email: event.email);

      _logger.info('BLoC: Email de réinitialisation envoyé');
      emit(state.unauthenticated());
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de réinitialisation: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de réinitialisation: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Mise à jour du profil utilisateur
  Future<void> _onUpdateUserProfileRequested(
    AuthUpdateUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.loading());

    try {
      _logger.info('BLoC: Mise à jour du profil utilisateur');

      await _authRepository.updateUserProfile(
        displayName: event.displayName,
        photoURL: event.photoURL,
      );

      _logger.info('BLoC: Profil utilisateur mis à jour');
      // L'état sera mis à jour via AuthUserChanged
    } catch (e) {
      _logger.error('BLoC: Erreur de mise à jour du profil: $e', e);
      emit(state.error(message: 'Erreur lors de la mise à jour du profil'));
    }
  }

  /// Mise à jour du mot de passe
  Future<void> _onUpdatePasswordRequested(
    AuthUpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.loading());

    try {
      _logger.info('BLoC: Mise à jour du mot de passe');

      await _authRepository.updatePassword(newPassword: event.newPassword);

      _logger.info('BLoC: Mot de passe mis à jour');
      emit(state.authenticated(state.user!));
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'BLoC: Erreur de mise à jour du mot de passe: ${e.code}',
        e,
      );
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de mise à jour du mot de passe: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Envoi d'email de vérification
  Future<void> _onSendEmailVerificationRequested(
    AuthSendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.info('BLoC: Envoi d\'email de vérification');

      await _authRepository.sendEmailVerification();

      _logger.info('BLoC: Email de vérification envoyé');
    } catch (e) {
      _logger.error('BLoC: Erreur d\'envoi d\'email de vérification: $e', e);
      emit(
        state.error(
          message: 'Erreur lors de l\'envoi de l\'email de vérification',
        ),
      );
    }
  }

  /// Déconnexion
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.info('BLoC: Déconnexion demandée');

      await _authRepository.signOut();

      _logger.info('BLoC: Déconnexion réussie');
      // L'état sera mis à jour via AuthUserChanged
    } catch (e) {
      _logger.error('BLoC: Erreur de déconnexion: $e', e);
      emit(state.error(message: 'Erreur lors de la déconnexion'));
    }
  }

  /// Suppression du compte
  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.info('BLoC: Suppression du compte demandée');

      await _authRepository.deleteAccount();

      _logger.info('BLoC: Compte supprimé');
      // L'état sera mis à jour via AuthUserChanged
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de suppression du compte: ${e.code}', e);
      emit(
        state.error(message: _getLocalizedFirebaseError(e.code), code: e.code),
      );
    } catch (e) {
      _logger.error('BLoC: Erreur de suppression du compte: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Effacer les erreurs
  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state.user != null) {
      if (state.status == AuthStatus.emailNotVerified) {
        emit(state.emailNotVerified(state.user!));
      } else {
        emit(state.authenticated(state.user!));
      }
    } else {
      emit(state.unauthenticated());
    }
  }

  /// Obtenir le message d'erreur localisé pour les erreurs Firebase
  String _getLocalizedFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'invalid-verification-code':
        return 'Code de vérification invalide.';
      case 'invalid-verification-id':
        return 'ID de vérification invalide.';
      case 'requires-recent-login':
        return 'Cette opération nécessite une connexion récente.';
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide.';
      case 'quota-exceeded':
        return 'Quota de SMS dépassé. Réessayez plus tard.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

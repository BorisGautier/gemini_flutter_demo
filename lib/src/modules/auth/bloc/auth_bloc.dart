// lib/src/modules/auth/bloc/auth_bloc.dart (VERSION MISE À JOUR)

import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/location.service.dart';
import 'package:kartia/src/core/services/user_sync.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC pour gérer l'authentification avec synchronisation automatique
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface _authRepository;
  final LocationService _locationService;
  final UserSyncService _userSyncService;
  final LogService _logger;

  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<UserLocation>? _locationSubscription;
  Timer? _periodicSyncTimer;

  AuthBloc({
    required AuthRepositoryInterface authRepository,
    required LocationService locationService,
    required UserSyncService userSyncService,
    required LogService logger,
  }) : _authRepository = authRepository,
       _locationService = locationService,
       _userSyncService = userSyncService,
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
    on<AuthUpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<AuthSendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthErrorCleared>(_onErrorCleared);

    // Événements de synchronisation
    on<AuthLocationUpdated>(_onLocationUpdated);
    on<AuthStartLocationTracking>(_onStartLocationTracking);
    on<AuthStopLocationTracking>(_onStopLocationTracking);
    on<AuthFirestoreUserLoaded>(_onFirestoreUserLoaded);
    on<AuthSyncUserData>(_onSyncUserData);
    on<AuthPeriodicSyncTriggered>(_onPeriodicSyncTriggered);

    on<AuthUpdateUserProfileRequested>(_onUpdateUserProfileRequestedWithImage);
    on<AuthUpgradeAnonymousAccountRequested>(
      _onUpgradeAnonymousAccountRequested,
    );
    on<AuthLinkPhoneNumberRequested>(_onLinkPhoneNumberRequested);
    on<AuthStartPhoneLinkingRequested>(_onStartPhoneLinkingRequested);
    on<AuthUpgradeAnonymousToPhoneRequested>(
      _onUpgradeAnonymousToPhoneRequested,
    );
  }

  /// Initialiser l'authentification avec synchronisation
  void _onAuthInitialized(AuthInitialized event, Emitter<AuthState> emit) {
    _logger.info(
      'BLoC: Initialisation de l\'authentification avec synchronisation',
    );

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

    // Vérifier l'utilisateur actuel au démarrage
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

  /// Gérer les changements d'utilisateur avec synchronisation automatique
  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    _logger.info('BLoC: Changement d\'utilisateur: ${event.user?.uid}');

    if (event.user != null) {
      final user = event.user!;

      try {
        final isProfileUpdate =
            state.user != null &&
            state.user!.uid == user.uid &&
            state.status == AuthStatus.authenticated;

        if (!isProfileUpdate) {
          emit(state.loading());
        }

        // Récupérer les données Firestore existantes
        final existingFirestoreUser = await _authRepository.getFirestoreUser(
          user.uid,
        );

        // Synchroniser les données utilisateur
        _logger.info('BLoC: Synchronisation des données utilisateur...');
        final syncedFirestoreUser = await _userSyncService
            .syncUserDataOnAppStart(
              authUser: user,
              existingFirestoreUser: existingFirestoreUser,
            );

        if (syncedFirestoreUser != null) {
          add(AuthFirestoreUserLoaded(syncedFirestoreUser));
        }

        // Démarrer le suivi de localisation si l'utilisateur l'autorise
        if (!isProfileUpdate &&
            (syncedFirestoreUser?.preferences.locationSharingEnabled ?? true)) {
          add(const AuthStartLocationTracking());
        }

        // Démarrer la synchronisation périodique seulement pour les nouvelles connexions
        if (!isProfileUpdate) {
          _startPeriodicSync();
        }

        // Déterminer l'état basé sur la vérification
        if (user.isAnonymous || user.phoneNumber != null) {
          _logger.info('BLoC: Utilisateur authentifié (anonyme ou téléphone)');
          emit(state.authenticated(user, syncedFirestoreUser));
        } else if (user.email != null && !user.emailVerified) {
          _logger.info(
            'BLoC: Email non vérifié, utilisateur en attente de vérification',
          );
          emit(state.emailNotVerified(user, syncedFirestoreUser));
        } else {
          _logger.info('BLoC: Utilisateur authentifié avec succès');
          emit(state.authenticated(user, syncedFirestoreUser));
        }
      } catch (e) {
        _logger.error(
          'Erreur lors de la synchronisation des données utilisateur',
          e,
        );
        // Continuer avec l'auth de base même si la synchronisation échoue
        if (user.isAnonymous || user.phoneNumber != null) {
          emit(state.authenticated(user, null));
        } else if (user.email != null && !user.emailVerified) {
          emit(state.emailNotVerified(user, null));
        } else {
          emit(state.authenticated(user, null));
        }
      }
    } else {
      _logger.info('BLoC: Aucun utilisateur, état non authentifié');
      add(const AuthStopLocationTracking());
      _stopPeriodicSync();
      emit(state.unauthenticated());
    }
  }

  /// Synchronisation manuelle des données utilisateur
  Future<void> _onSyncUserData(
    AuthSyncUserData event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    try {
      _logger.info('BLoC: Synchronisation manuelle des données utilisateur');

      final syncedFirestoreUser = await _userSyncService.syncUserDataOnAppStart(
        authUser: state.user!,
        existingFirestoreUser: state.firestoreUser,
      );

      if (syncedFirestoreUser != null) {
        emit(state.copyWith(firestoreUser: syncedFirestoreUser));
        _logger.info('BLoC: Synchronisation manuelle terminée avec succès');
      }
    } catch (e) {
      _logger.error('Erreur lors de la synchronisation manuelle', e);
    }
  }

  /// Synchronisation périodique
  Future<void> _onPeriodicSyncTriggered(
    AuthPeriodicSyncTriggered event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null || state.firestoreUser == null) return;

    try {
      // Vérifier si une synchronisation est nécessaire
      final shouldSync = await _userSyncService.shouldSync(
        state.firestoreUser!,
      );

      if (shouldSync) {
        _logger.info('BLoC: Synchronisation périodique nécessaire');
        add(const AuthSyncUserData());
      } else {
        _logger.debug('BLoC: Synchronisation périodique non nécessaire');
      }
    } catch (e) {
      _logger.error(
        'Erreur lors de la vérification de synchronisation périodique',
        e,
      );
    }
  }

  /// Démarrer la synchronisation périodique (toutes les heures)
  void _startPeriodicSync() {
    _stopPeriodicSync(); // Arrêter le timer existant s'il y en a un

    _periodicSyncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (!isClosed) {
        add(const AuthPeriodicSyncTriggered());
      }
    });

    _logger.info('BLoC: Synchronisation périodique démarrée');
  }

  /// Arrêter la synchronisation périodique
  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _logger.info('BLoC: Synchronisation périodique arrêtée');
  }

  // === MÉTHODES D'AUTHENTIFICATION INCHANGÉES ===

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
        // L'état sera mis à jour via AuthUserChanged avec synchronisation automatique
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
        // L'état sera mis à jour via AuthUserChanged avec synchronisation automatique
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
        // L'état sera mis à jour via AuthUserChanged avec synchronisation automatique
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
          _logger.info('BLoC: Vérification automatique du téléphone réussie');
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.error(
            'BLoC: Échec de la vérification du téléphone: ${e.code}',
            e,
          );
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

  /// Erreur de vérification téléphone
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

      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      // ✅ NOUVEAU: Vérifier si c'est un upgrade d'un compte anonyme
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        _logger.info('BLoC: Upgrade de compte anonyme vers téléphone');

        // Lier le credential au compte anonyme existant
        final UserCredential userCredential = await currentUser
            .linkWithCredential(credential);

        if (userCredential.user != null) {
          _logger.info(
            'BLoC: Compte anonyme mis à niveau vers téléphone avec succès',
          );

          // Mettre à jour les données Firestore
          final updates = <String, dynamic>{
            'phoneNumber': userCredential.user!.phoneNumber,
            'phoneVerified': true,
            'isAnonymous': false,
            'authProvider': 'phone',
            'updatedAt': DateTime.now(),
          };

          await _authRepository.updateFirestoreUser(currentUser.uid, updates);

          // Récupérer les données Firestore mises à jour
          final updatedFirestoreUser = await _authRepository.getFirestoreUser(
            currentUser.uid,
          );

          // Émettre l'état authentifié mis à jour
          emit(state.authenticated(state.user!, updatedFirestoreUser));
          return; // ✅ Important: sortir de la méthode ici
        }
      } else {
        // ✅ Connexion normale (pas d'upgrade)
        final userCredential = await _authRepository.signInWithPhoneNumber(
          verificationId: event.verificationId,
          smsCode: event.smsCode,
        );

        if (userCredential != null) {
          _logger.info('BLoC: Connexion par téléphone réussie');
          // L'état sera mis à jour via AuthUserChanged
        }
      }
    } on FirebaseAuthException catch (e) {
      _logger.error('BLoC: Erreur de connexion par téléphone: ${e.code}', e);

      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage =
              'Code de vérification invalide. Vérifiez le code et réessayez.';
          break;
        case 'invalid-verification-id':
          errorMessage =
              'Session expirée. Veuillez recommencer la vérification.';
          break;
        case 'credential-already-in-use':
          errorMessage =
              'Ce numéro de téléphone est déjà utilisé par un autre compte.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Veuillez vous reconnecter pour effectuer cette action.';
          break;
        case 'too-many-requests':
          errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
          break;
        case 'quota-exceeded':
          errorMessage = 'Quota SMS dépassé. Réessayez plus tard.';
          break;
        default:
          errorMessage =
              'Erreur lors de la vérification: ${e.message ?? 'Erreur inconnue'}';
      }

      emit(state.error(message: errorMessage, code: e.code));
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
      emit(state.authenticated(state.user!, state.firestoreUser));
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

      // Arrêter le suivi de localisation et la synchronisation
      add(const AuthStopLocationTracking());
      _stopPeriodicSync();

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

      // Arrêter le suivi de localisation et la synchronisation
      add(const AuthStopLocationTracking());
      _stopPeriodicSync();

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
        emit(state.emailNotVerified(state.user!, state.firestoreUser));
      } else {
        emit(state.authenticated(state.user!, state.firestoreUser));
      }
    } else {
      emit(state.unauthenticated());
    }
  }

  // === GESTIONNAIRES DE LOCALISATION ET FIRESTORE ===

  /// Mise à jour de la localisation
  void _onLocationUpdated(
    AuthLocationUpdated event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user != null) {
      try {
        await _authRepository.updateUserLocation(
          state.user!.uid,
          event.location,
        );
        _logger.debug(
          'Position mise à jour: ${event.location.latitude}, ${event.location.longitude}',
        );

        // Mettre à jour l'état avec la nouvelle position
        if (state.firestoreUser != null) {
          final updatedFirestoreUser = state.firestoreUser!.copyWith(
            currentLocation: event.location,
          );
          emit(state.copyWith(firestoreUser: updatedFirestoreUser));
        }
      } catch (e) {
        _logger.error('Erreur lors de la mise à jour de la position', e);
      }
    }
  }

  /// Démarrer le suivi de localisation
  void _onStartLocationTracking(
    AuthStartLocationTracking event,
    Emitter<AuthState> emit,
  ) {
    _logger.info('BLoC: Démarrage du suivi de localisation');

    _locationSubscription?.cancel();
    _locationSubscription = _locationService.startLocationTracking().listen(
      (location) {
        add(AuthLocationUpdated(location));
      },
      onError: (error) {
        _logger.error('Erreur dans le stream de localisation', error);
      },
    );
  }

  /// Arrêter le suivi de localisation
  void _onStopLocationTracking(
    AuthStopLocationTracking event,
    Emitter<AuthState> emit,
  ) {
    _logger.info('BLoC: Arrêt du suivi de localisation');
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationService.stopLocationTracking();
  }

  /// Utilisateur Firestore chargé
  void _onFirestoreUserLoaded(
    AuthFirestoreUserLoaded event,
    Emitter<AuthState> emit,
  ) {
    _logger.info('BLoC: Données Firestore utilisateur chargées');
    emit(state.copyWith(firestoreUser: event.firestoreUser));
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

  Future<void> _onUpdateUserProfileRequestedWithImage(
    AuthUpdateUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;

    // ✅ Émettre un état de chargement spécifique qui maintient l'utilisateur connecté
    emit(state.copyWith(isLoading: true));

    try {
      _logger.info('BLoC: Mise à jour du profil utilisateur avec image');

      await _authRepository.updateUserProfile(
        displayName: event.displayName,
        photoURL: event.photoURL,
        imageFile: event.imageFile,
      );

      _logger.info('BLoC: Profil utilisateur mis à jour');

      // ✅ Recharger l'utilisateur Firebase pour obtenir les dernières données
      await FirebaseAuth.instance.currentUser?.reload();
      final updatedUser = _authRepository.currentUser;

      if (updatedUser != null) {
        // Mettre à jour Firestore avec les nouvelles données
        final updates = <String, dynamic>{};
        if (event.displayName != null) {
          updates['fullName'] = event.displayName;
        }

        // Si on a uploadé une nouvelle image, mettre à jour l'URL
        if (event.imageFile != null && updatedUser.photoURL != null) {
          updates['photoURL'] = updatedUser.photoURL;
        }

        if (updates.isNotEmpty) {
          await _authRepository.updateFirestoreUser(state.user!.uid, updates);
        }

        // ✅ Récupérer les données Firestore mises à jour
        final updatedFirestoreUser = await _authRepository.getFirestoreUser(
          state.user!.uid,
        );

        // ✅ Émettre l'état mis à jour sans passer par AuthUserChanged
        emit(state.authenticated(updatedUser, updatedFirestoreUser));
      }
    } catch (e) {
      _logger.error('BLoC: Erreur de mise à jour du profil: $e', e);
      emit(
        state.copyWith(
          isLoading: false,
          status: AuthStatus.error,
          errorMessage: 'Erreur lors de la mise à jour du profil',
        ),
      );
    }
  }

  /// Gestionnaire pour la mise à niveau d'un compte anonyme
  Future<void> _onUpgradeAnonymousAccountRequested(
    AuthUpgradeAnonymousAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null || !state.user!.isAnonymous) {
      emit(state.error(message: 'Aucun compte anonyme à mettre à niveau'));
      return;
    }

    // ✅ FIX: Utiliser un état spécifique pour l'upgrade (pas loading générique)
    emit(
      state.copyWith(
        isLoading: true,
        status: AuthStatus.loading, // Garder le statut spécifique
        errorMessage: null,
        errorCode: null,
      ),
    );

    try {
      _logger.info('BLoC: Mise à niveau du compte anonyme vers compte email');

      // Créer les credentials email/mot de passe
      final AuthCredential credential = EmailAuthProvider.credential(
        email: event.email,
        password: event.password,
      );

      // Lier le compte anonyme avec les nouveaux credentials
      final UserCredential userCredential = await FirebaseAuth
          .instance
          .currentUser!
          .linkWithCredential(credential);

      // Mettre à jour le nom d'affichage si fourni
      if (event.displayName != null) {
        await userCredential.user!.updateDisplayName(event.displayName);
        await userCredential.user!.reload();
      }

      // Envoyer l'email de vérification
      await userCredential.user!.sendEmailVerification();

      // Mettre à jour les données Firestore
      final updates = <String, dynamic>{
        'email': event.email,
        'isAnonymous': false,
        'authProvider': 'email',
        'emailVerified': false, // Sera mis à jour après vérification
        'updatedAt': DateTime.now(),
      };

      if (event.displayName != null) {
        updates['fullName'] = event.displayName;
      }

      await _authRepository.updateFirestoreUser(state.user!.uid, updates);

      _logger.info('BLoC: Compte anonyme mis à niveau avec succès');

      // ✅ FIX: Forcer le reload de l'utilisateur et émettre l'état correct
      await FirebaseAuth.instance.currentUser?.reload();
      final updatedUser = _authRepository.currentUser;

      if (updatedUser != null) {
        // Récupérer les données Firestore mises à jour
        final updatedFirestoreUser = await _authRepository.getFirestoreUser(
          updatedUser.uid,
        );

        // ✅ Émettre directement l'état authentifié sans passer par AuthUserChanged
        if (updatedUser.email != null && !updatedUser.emailVerified) {
          emit(state.emailNotVerified(updatedUser, updatedFirestoreUser));
        } else {
          emit(state.authenticated(updatedUser, updatedFirestoreUser));
        }
      }
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'BLoC: Erreur Firebase lors de la mise à niveau: ${e.code}',
        e,
      );

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'Cette adresse email est déjà utilisée par un autre compte';
          break;
        case 'weak-password':
          errorMessage = 'Le mot de passe est trop faible';
          break;
        case 'invalid-email':
          errorMessage = 'Adresse email invalide';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Veuillez vous reconnecter pour effectuer cette action';
          break;
        case 'credential-already-in-use':
          errorMessage =
              'Ces identifiants sont déjà utilisés par un autre compte';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Cette opération n\'est pas autorisée';
          break;
        default:
          errorMessage =
              'Erreur lors de la mise à niveau du compte: ${e.message ?? 'Erreur inconnue'}';
      }

      emit(state.error(message: errorMessage, code: e.code));
    } catch (e) {
      _logger.error('BLoC: Erreur lors de la mise à niveau du compte: $e', e);
      emit(
        state.error(
          message:
              'Une erreur inattendue s\'est produite lors de la mise à niveau',
        ),
      );
    }
  }

  /// Gestionnaire pour démarrer la liaison d'un numéro de téléphone
  Future<void> _onStartPhoneLinkingRequested(
    AuthStartPhoneLinkingRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) {
      emit(state.error(message: 'Aucun utilisateur connecté'));
      return;
    }

    // ✅ FIX: État spécifique pour la vérification téléphone
    emit(state.phoneVerificationInProgress());

    try {
      _logger.info('BLoC: Démarrage de la liaison de numéro de téléphone');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _logger.info(
            'BLoC: Vérification automatique du téléphone réussie pour liaison',
          );
          // ✅ Lier automatiquement si la vérification est complète
          try {
            final UserCredential userCredential = await FirebaseAuth
                .instance
                .currentUser!
                .linkWithCredential(credential);

            // Mettre à jour Firestore
            final updates = <String, dynamic>{
              'phoneNumber': userCredential.user?.phoneNumber,
              'phoneVerified': true,
              'isAnonymous': false, // ✅ Plus anonyme après liaison téléphone
              'authProvider': 'phone',
              'updatedAt': DateTime.now(),
            };

            await _authRepository.updateFirestoreUser(state.user!.uid, updates);

            _logger.info('BLoC: Numéro de téléphone lié automatiquement');

            // ✅ Forcer la mise à jour de l'état
            await FirebaseAuth.instance.currentUser?.reload();
            final updatedUser = _authRepository.currentUser;
            final updatedFirestoreUser = await _authRepository.getFirestoreUser(
              state.user!.uid,
            );

            if (updatedUser != null) {
              emit(state.authenticated(updatedUser, updatedFirestoreUser));
            }
          } catch (e) {
            _logger.error('BLoC: Erreur lors de la liaison automatique: $e', e);
            emit(
              state.error(
                message: 'Erreur lors de la liaison automatique du téléphone',
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _logger.error(
            'BLoC: Échec de la vérification du téléphone pour liaison: ${e.code}',
            e,
          );
          add(
            AuthPhoneVerificationFailed(
              message: _getLocalizedFirebaseError(e.code),
              code: e.code,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.info('BLoC: Code SMS envoyé pour liaison de téléphone');
          add(
            AuthPhoneCodeSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.info(
            'BLoC: Timeout de récupération automatique du code pour liaison',
          );
        },
      );
    } catch (e) {
      _logger.error(
        'BLoC: Erreur lors de la vérification du téléphone pour liaison: $e',
        e,
      );
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  /// Gestionnaire pour lier un numéro de téléphone avec le code SMS
  Future<void> _onLinkPhoneNumberRequested(
    AuthLinkPhoneNumberRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) {
      emit(state.error(message: 'Aucun utilisateur connecté'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info('BLoC: Tentative de liaison avec le code SMS');

      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      // Lier le numéro de téléphone au compte existant
      final UserCredential userCredential = await FirebaseAuth
          .instance
          .currentUser!
          .linkWithCredential(credential);

      if (userCredential.user != null) {
        _logger.info('BLoC: Numéro de téléphone lié avec succès');

        // Mettre à jour les données Firestore
        final updates = <String, dynamic>{
          'phoneNumber': userCredential.user!.phoneNumber,
          'phoneVerified': true,
          'isAnonymous': false, // ✅ Plus anonyme après liaison
          'authProvider': state.user!.isAnonymous ? 'phone' : 'multiple',
          'updatedAt': DateTime.now(),
        };

        await _authRepository.updateFirestoreUser(state.user!.uid, updates);

        // ✅ Recharger et émettre l'état mis à jour
        await FirebaseAuth.instance.currentUser?.reload();
        final updatedUser = _authRepository.currentUser;
        final updatedFirestoreUser = await _authRepository.getFirestoreUser(
          state.user!.uid,
        );

        if (updatedUser != null) {
          emit(state.authenticated(updatedUser, updatedFirestoreUser));
        }
      }
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'BLoC: Erreur Firebase lors de la liaison par téléphone: ${e.code}',
        e,
      );

      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Code de vérification invalide';
          break;
        case 'invalid-verification-id':
          errorMessage = 'ID de vérification invalide';
          break;
        case 'credential-already-in-use':
          errorMessage =
              'Ce numéro de téléphone est déjà utilisé par un autre compte';
          break;
        case 'provider-already-linked':
          errorMessage = 'Un numéro de téléphone est déjà lié à ce compte';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Veuillez vous reconnecter pour effectuer cette action';
          break;
        default:
          errorMessage =
              'Erreur lors de la liaison du numéro de téléphone: ${e.message ?? 'Erreur inconnue'}';
      }

      emit(state.error(message: errorMessage, code: e.code));
    } catch (e) {
      _logger.error('BLoC: Erreur lors de la liaison par téléphone: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  Future<void> _onUpgradeAnonymousToPhoneRequested(
    AuthUpgradeAnonymousToPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null || !state.user!.isAnonymous) {
      emit(state.error(message: 'Aucun compte anonyme à mettre à niveau'));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      _logger.info('BLoC: Mise à niveau du compte anonyme vers téléphone');

      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );

      // Lier le credential au compte anonyme
      final UserCredential userCredential = await FirebaseAuth
          .instance
          .currentUser!
          .linkWithCredential(credential);

      // Mettre à jour le nom d'affichage si fourni
      if (event.displayName != null && event.displayName!.isNotEmpty) {
        await userCredential.user!.updateDisplayName(event.displayName);
        await userCredential.user!.reload();
      }

      // Mettre à jour les données Firestore
      final updates = <String, dynamic>{
        'phoneNumber': userCredential.user!.phoneNumber,
        'phoneVerified': true,
        'isAnonymous': false,
        'authProvider': 'phone',
        'updatedAt': DateTime.now(),
      };

      if (event.displayName != null && event.displayName!.isNotEmpty) {
        updates['fullName'] = event.displayName;
      }

      await _authRepository.updateFirestoreUser(state.user!.uid, updates);

      _logger.info(
        'BLoC: Compte anonyme mis à niveau vers téléphone avec succès',
      );

      // Recharger l'utilisateur et récupérer les données mises à jour
      await FirebaseAuth.instance.currentUser?.reload();
      final updatedUser = _authRepository.currentUser;
      final updatedFirestoreUser = await _authRepository.getFirestoreUser(
        state.user!.uid,
      );

      if (updatedUser != null) {
        emit(state.authenticated(updatedUser, updatedFirestoreUser));
      }
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'BLoC: Erreur Firebase lors de la mise à niveau téléphone: ${e.code}',
        e,
      );

      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Code de vérification invalide';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Session expirée. Recommencez la vérification.';
          break;
        case 'credential-already-in-use':
          errorMessage = 'Ce numéro est déjà utilisé par un autre compte';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Veuillez vous reconnecter pour effectuer cette action';
          break;
        default:
          errorMessage =
              'Erreur lors de la mise à niveau: ${e.message ?? 'Erreur inconnue'}';
      }

      emit(state.error(message: errorMessage, code: e.code));
    } catch (e) {
      _logger.error('BLoC: Erreur lors de la mise à niveau téléphone: $e', e);
      emit(state.error(message: 'Une erreur inattendue s\'est produite'));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _locationSubscription?.cancel();
    _stopPeriodicSync();
    _locationService.dispose();
    return super.close();
  }
}

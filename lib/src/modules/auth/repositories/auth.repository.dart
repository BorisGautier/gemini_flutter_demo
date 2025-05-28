import 'package:firebase_auth/firebase_auth.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Interface pour le repository d'authentification
abstract class AuthRepositoryInterface {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  bool get isSignedIn;

  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserModel?> signInAnonymously();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  });

  Future<UserModel?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  Future<void> sendPasswordResetEmail({required String email});
  Future<void> updateUserProfile({String? displayName, String? photoURL});
  Future<void> updatePassword({required String newPassword});
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> deleteAccount();

  Future<FirestoreUserModel?> getFirestoreUser(String userId);
  Future<void> updateFirestoreUser(String userId, Map<String, dynamic> updates);
  Future<void> updateUserLocation(String userId, UserLocation location);
}

/// Repository concret pour l'authentification avec intégration Firestore
class AuthRepository implements AuthRepositoryInterface {
  final AuthService _authService;
  final FirestoreUserService _firestoreUserService;
  final LogService _logger;

  AuthRepository({
    required AuthService authService,
    required FirestoreUserService firestoreUserService,
    required LogService logger,
  }) : _authService = authService,
       _firestoreUserService = firestoreUserService,
       _logger = logger;

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((user) {
      final userModel = _authService.firebaseUserToUserModel(user);
      if (userModel != null) {
        _logger.info('État d\'authentification changé: ${userModel.uid}');
        // Mettre à jour la dernière connexion dans Firestore
        _firestoreUserService.updateLastSignIn(userModel.uid);
      } else {
        _logger.info('Utilisateur déconnecté');
      }
      return userModel;
    });
  }

  @override
  UserModel? get currentUser {
    return _authService.firebaseUserToUserModel(_authService.currentUser);
  }

  @override
  bool get isSignedIn => _authService.isSignedIn;

  @override
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Repository: Tentative de connexion avec email');

      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = _authService.firebaseUserToUserModel(credential?.user);

      if (userModel != null) {
        _logger.info('Repository: Connexion réussie pour ${userModel.uid}');

        // Vérifier si l'utilisateur existe dans Firestore
        final firestoreUser = await _firestoreUserService.getUser(
          userModel.uid,
        );
        if (firestoreUser == null) {
          _logger.info('Utilisateur non trouvé dans Firestore, création...');
          await _createFirestoreUserFromAuth(userModel);
        } else {
          // Mettre à jour la dernière connexion
          await _firestoreUserService.updateLastSignIn(userModel.uid);
        }
      }

      return userModel;
    } catch (e) {
      _logger.error('Repository: Erreur de connexion', e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _logger.info('Repository: Tentative d\'inscription avec email');

      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      final userModel = _authService.firebaseUserToUserModel(credential?.user);

      if (userModel != null) {
        _logger.info('Repository: Inscription réussie pour ${userModel.uid}');

        // Créer l'utilisateur dans Firestore
        await _createFirestoreUserFromAuth(
          userModel,
          fullName: displayName ?? email.split('@')[0],
        );

        // Envoyer l'email de vérification automatiquement
        await sendEmailVerification();
      }

      return userModel;
    } catch (e) {
      _logger.error('Repository: Erreur d\'inscription', e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> signInAnonymously() async {
    try {
      _logger.info('Repository: Tentative de connexion anonyme');

      final credential = await _authService.signInAnonymously();
      final userModel = _authService.firebaseUserToUserModel(credential?.user);

      if (userModel != null) {
        _logger.info(
          'Repository: Connexion anonyme réussie pour ${userModel.uid}',
        );

        // Créer l'utilisateur anonyme dans Firestore
        await _createFirestoreUserFromAuth(
          userModel,
          fullName: 'Utilisateur Anonyme',
        );
      }

      return userModel;
    } catch (e) {
      _logger.error('Repository: Erreur de connexion anonyme', e);
      rethrow;
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      _logger.info('Repository: Vérification du numéro de téléphone');

      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: timeout,
      );
    } catch (e) {
      _logger.error('Repository: Erreur de vérification du téléphone', e);
      rethrow;
    }
  }

  @override
  Future<UserModel?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      _logger.info('Repository: Tentative de connexion avec le code SMS');

      final credential = await _authService.signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userModel = _authService.firebaseUserToUserModel(credential?.user);

      if (userModel != null) {
        _logger.info(
          'Repository: Connexion par téléphone réussie pour ${userModel.uid}',
        );

        // Vérifier si l'utilisateur existe dans Firestore
        final firestoreUser = await _firestoreUserService.getUser(
          userModel.uid,
        );
        if (firestoreUser == null) {
          _logger.info(
            'Nouvel utilisateur téléphone, création dans Firestore...',
          );
          await _createFirestoreUserFromAuth(
            userModel,
            fullName: userModel.phoneNumber ?? 'Utilisateur Téléphone',
          );
        } else {
          // Mettre à jour la dernière connexion
          await _firestoreUserService.updateLastSignIn(userModel.uid);
        }
      }

      return userModel;
    } catch (e) {
      _logger.error('Repository: Erreur de connexion par téléphone', e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      _logger.info('Repository: Envoi d\'email de réinitialisation');

      await _authService.sendPasswordResetEmail(email: email);

      _logger.info('Repository: Email de réinitialisation envoyé avec succès');
    } catch (e) {
      _logger.error(
        'Repository: Erreur d\'envoi d\'email de réinitialisation',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _logger.info('Repository: Mise à jour du profil utilisateur');

      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Mettre à jour aussi dans Firestore
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final updates = <String, dynamic>{};
        if (displayName != null) {
          updates['fullName'] = displayName;
        }
        if (photoURL != null) {
          updates['photoURL'] = photoURL;
        }

        if (updates.isNotEmpty) {
          await _firestoreUserService.updateUser(currentUser.uid, updates);
        }
      }

      _logger.info('Repository: Profil utilisateur mis à jour avec succès');
    } catch (e) {
      _logger.error('Repository: Erreur de mise à jour du profil', e);
      rethrow;
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      _logger.info('Repository: Mise à jour du mot de passe');

      await _authService.updatePassword(newPassword: newPassword);

      _logger.info('Repository: Mot de passe mis à jour avec succès');
    } catch (e) {
      _logger.error('Repository: Erreur de mise à jour du mot de passe', e);
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      _logger.info('Repository: Envoi d\'email de vérification');

      await _authService.sendEmailVerification();

      _logger.info('Repository: Email de vérification envoyé avec succès');
    } catch (e) {
      _logger.error('Repository: Erreur d\'envoi d\'email de vérification', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.info('Repository: Déconnexion de l\'utilisateur');

      await _authService.signOut();

      _logger.info('Repository: Déconnexion réussie');
    } catch (e) {
      _logger.error('Repository: Erreur de déconnexion', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _logger.info('Repository: Suppression du compte utilisateur');

        // Supprimer d'abord de Firestore
        await _firestoreUserService.deleteUser(currentUser.uid);

        // Puis supprimer de Firebase Auth
        await _authService.deleteAccount();

        _logger.info('Repository: Compte supprimé avec succès');
      }
    } catch (e) {
      _logger.error('Repository: Erreur de suppression du compte', e);
      rethrow;
    }
  }

  // ✅ NOUVELLES MÉTHODES FIRESTORE

  @override
  Future<FirestoreUserModel?> getFirestoreUser(String userId) async {
    try {
      return await _firestoreUserService.getUser(userId);
    } catch (e) {
      _logger.error(
        'Repository: Erreur de récupération utilisateur Firestore',
        e,
      );
      return null;
    }
  }

  @override
  Future<void> updateFirestoreUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestoreUserService.updateUser(userId, updates);
    } catch (e) {
      _logger.error(
        'Repository: Erreur de mise à jour utilisateur Firestore',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateUserLocation(String userId, UserLocation location) async {
    try {
      await _firestoreUserService.updateUserLocation(userId, location);
    } catch (e) {
      _logger.error(
        'Repository: Erreur de mise à jour position utilisateur',
        e,
      );
      rethrow;
    }
  }

  /// Méthode privée pour créer un utilisateur Firestore à partir d'un utilisateur Auth
  Future<void> _createFirestoreUserFromAuth(
    UserModel authUser, {
    String? fullName,
  }) async {
    try {
      final name =
          fullName ??
          authUser.displayName ??
          authUser.email?.split('@')[0] ??
          authUser.phoneNumber ??
          'Utilisateur';

      await _firestoreUserService.createUser(
        authUser: authUser,
        fullName: name,
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de la création de l\'utilisateur Firestore',
        e,
      );
      // Ne pas faire échouer l'authentification pour une erreur Firestore
    }
  }
}

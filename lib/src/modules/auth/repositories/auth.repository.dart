import 'package:firebase_auth/firebase_auth.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
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
}

/// Repository concret pour l'authentification
class AuthRepository implements AuthRepositoryInterface {
  final AuthService _authService;
  final LogService _logger;

  AuthRepository({required AuthService authService, required LogService logger})
    : _authService = authService,
      _logger = logger;

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((user) {
      final userModel = _authService.firebaseUserToUserModel(user);
      if (userModel != null) {
        _logger.info('État d\'authentification changé: ${userModel.uid}');
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
      _logger.info('Repository: Suppression du compte utilisateur');

      await _authService.deleteAccount();

      _logger.info('Repository: Compte supprimé avec succès');
    } catch (e) {
      _logger.error('Repository: Erreur de suppression du compte', e);
      rethrow;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Service pour gérer l'authentification Firebase
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final LogService _logger = LogService();

  /// Stream de l'utilisateur connecté
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Utilisateur actuellement connecté
  User? get currentUser => _firebaseAuth.currentUser;

  /// Vérifier si l'utilisateur est connecté
  bool get isSignedIn => currentUser != null;

  /// Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Tentative de connexion avec email: $email');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.info('Connexion réussie pour: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur de connexion Firebase: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur de connexion: $e', e);
      rethrow;
    }
  }

  /// Inscription avec email et mot de passe
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _logger.info('Tentative d\'inscription avec email: $email');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le nom d'affichage si fourni
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      _logger.info('Inscription réussie pour: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur d\'inscription Firebase: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur d\'inscription: $e', e);
      rethrow;
    }
  }

  /// Connexion anonyme
  Future<UserCredential?> signInAnonymously() async {
    try {
      _logger.info('Tentative de connexion anonyme');

      final credential = await _firebaseAuth.signInAnonymously();

      _logger.info('Connexion anonyme réussie: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur de connexion anonyme: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur de connexion anonyme: $e', e);
      rethrow;
    }
  }

  /// Vérifier le numéro de téléphone
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      _logger.info('Vérification du numéro de téléphone: $phoneNumber');

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: timeout,
      );
    } catch (e) {
      _logger.error('Erreur de vérification du téléphone: $e', e);
      rethrow;
    }
  }

  /// Connexion avec le code SMS
  Future<UserCredential?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      _logger.info('Tentative de connexion avec le code SMS');

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      _logger.info(
        'Connexion par téléphone réussie: ${userCredential.user?.phoneNumber}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur de connexion par téléphone: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur de connexion par téléphone: $e', e);
      rethrow;
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      _logger.info('Envoi d\'email de réinitialisation à: $email');

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      _logger.info('Email de réinitialisation envoyé avec succès');
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'Erreur d\'envoi d\'email de réinitialisation: ${e.code}',
        e,
      );
      rethrow;
    } catch (e) {
      _logger.error('Erreur d\'envoi d\'email de réinitialisation: $e', e);
      rethrow;
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info('Mise à jour du profil utilisateur: ${user.uid}');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      _logger.info('Profil utilisateur mis à jour avec succès');
    } catch (e) {
      _logger.error('Erreur de mise à jour du profil: $e', e);
      rethrow;
    }
  }

  /// Changer le mot de passe
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info('Mise à jour du mot de passe pour: ${user.uid}');

      await user.updatePassword(newPassword);

      _logger.info('Mot de passe mis à jour avec succès');
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur de mise à jour du mot de passe: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur de mise à jour du mot de passe: $e', e);
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      _logger.info('Déconnexion de l\'utilisateur');

      await _firebaseAuth.signOut();

      _logger.info('Déconnexion réussie');
    } catch (e) {
      _logger.error('Erreur de déconnexion: $e', e);
      rethrow;
    }
  }

  /// Supprimer le compte utilisateur
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info('Suppression du compte: ${user.uid}');

      await user.delete();

      _logger.info('Compte supprimé avec succès');
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur de suppression du compte: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur de suppression du compte: $e', e);
      rethrow;
    }
  }

  /// Renvoyer l'email de vérification
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      if (!user.emailVerified) {
        _logger.info('Envoi d\'email de vérification à: ${user.email}');
        await user.sendEmailVerification();
        _logger.info('Email de vérification envoyé avec succès');
      }
    } catch (e) {
      _logger.error('Erreur d\'envoi d\'email de vérification: $e', e);
      rethrow;
    }
  }

  /// Convertir User Firebase en UserModel
  UserModel? firebaseUserToUserModel(User? firebaseUser) {
    if (firebaseUser == null) return null;

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      isAnonymous: firebaseUser.isAnonymous,
      creationTime: firebaseUser.metadata.creationTime,
      lastSignInTime: firebaseUser.metadata.lastSignInTime,
    );
  }
}

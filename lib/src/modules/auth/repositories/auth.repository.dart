// Mise à jour du fichier auth.repository.dart avec support d'upload d'images

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';
import 'package:kartia/src/core/services/image_upload.service.dart';
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
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    File? imageFile,
  });
  Future<void> updatePassword({required String newPassword});
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<void> deleteAccount();

  Future<FirestoreUserModel?> getFirestoreUser(String userId);
  Future<void> updateFirestoreUser(String userId, Map<String, dynamic> updates);
  Future<void> updateUserLocation(String userId, UserLocation location);
}

/// Repository concret pour l'authentification avec upload d'images
class AuthRepository implements AuthRepositoryInterface {
  final AuthService _authService;
  final FirestoreUserService _firestoreUserService;
  final ImageUploadService _imageUploadService;
  final LogService _logger;

  AuthRepository({
    required AuthService authService,
    required FirestoreUserService firestoreUserService,
    required ImageUploadService imageUploadService,
    required LogService logger,
  }) : _authService = authService,
       _firestoreUserService = firestoreUserService,
       _imageUploadService = imageUploadService,
       _logger = logger;

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.map((user) {
      final userModel = _authService.firebaseUserToUserModel(user);
      if (userModel != null) {
        _logger.info('État d\'authentification changé: ${userModel.uid}');
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

        final firestoreUser = await _firestoreUserService.getUser(
          userModel.uid,
        );
        if (firestoreUser == null) {
          _logger.info('Utilisateur non trouvé dans Firestore, création...');
          await _createFirestoreUserFromAuth(userModel);
        } else {
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

        await _createFirestoreUserFromAuth(
          userModel,
          fullName: displayName ?? email.split('@')[0],
        );

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
    File? imageFile,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info(
        'Repository: Mise à jour du profil utilisateur: ${user.uid}',
      );

      String? finalPhotoURL = photoURL;

      // Upload de l'image si fournie
      if (imageFile != null) {
        _logger.info('Upload de nouvelle image de profil...');

        // Valider l'image
        if (!_imageUploadService.isValidImageFile(imageFile)) {
          throw Exception('Format d\'image non supporté');
        }

        if (!_imageUploadService.isValidFileSize(imageFile, maxSizeMB: 5.0)) {
          throw Exception('L\'image est trop volumineuse (max 5MB)');
        }

        // Supprimer l'ancienne image si elle existe
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          try {
            await _imageUploadService.deleteProfileImage(user.photoURL!);
          } catch (e) {
            _logger.warning('Impossible de supprimer l\'ancienne image: $e');
          }
        }

        // Upload de la nouvelle image
        finalPhotoURL = await _imageUploadService.uploadProfileImage(
          userId: user.uid,
          imageFile: imageFile,
        );

        if (finalPhotoURL == null) {
          throw Exception('Échec de l\'upload de l\'image');
        }

        _logger.info('Image de profil uploadée avec succès: $finalPhotoURL');
      }

      // Mettre à jour le profil Firebase Auth
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: finalPhotoURL,
      );

      // Mettre à jour aussi dans Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['fullName'] = displayName;
      }
      if (finalPhotoURL != null) {
        updates['photoURL'] = finalPhotoURL;
      }

      if (updates.isNotEmpty) {
        await _firestoreUserService.updateUser(user.uid, updates);
      }

      // Nettoyer les anciennes images de profil
      if (imageFile != null) {
        try {
          await _imageUploadService.cleanupOldProfileImages(user.uid);
        } catch (e) {
          _logger.warning('Erreur lors du nettoyage des anciennes images: $e');
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

        // Récupérer l'utilisateur Firestore pour obtenir les images
        final firestoreUser = await _firestoreUserService.getUser(
          currentUser.uid,
        );

        // Supprimer les images de profil
        if (firestoreUser?.photoURL != null) {
          try {
            await _imageUploadService.deleteProfileImage(
              firestoreUser!.photoURL!,
            );
          } catch (e) {
            _logger.warning(
              'Erreur lors de la suppression de l\'image de profil: $e',
            );
          }
        }

        // Supprimer toutes les images de l'utilisateur
        try {
          final userImages = await _imageUploadService.listUserImages(
            currentUser.uid,
          );
          for (String imageUrl in userImages) {
            try {
              await _imageUploadService.deleteProfileImage(imageUrl);
            } catch (e) {
              _logger.warning('Erreur lors de la suppression d\'une image: $e');
            }
          }
        } catch (e) {
          _logger.warning(
            'Erreur lors de la suppression des images utilisateur: $e',
          );
        }

        // Supprimer de Firestore
        await _firestoreUserService.deleteUser(currentUser.uid);

        // Supprimer de Firebase Auth
        await _authService.deleteAccount();

        _logger.info('Repository: Compte supprimé avec succès');
      }
    } catch (e) {
      _logger.error('Repository: Erreur de suppression du compte', e);
      rethrow;
    }
  }

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

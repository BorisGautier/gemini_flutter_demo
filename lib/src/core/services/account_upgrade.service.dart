// lib/src/modules/auth/services/account_upgrade.service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';

/// Service pour gérer la mise à niveau des comptes anonymes
class AccountUpgradeService {
  final FirestoreUserService _firestoreUserService;
  final LogService _logger;

  AccountUpgradeService({
    required FirestoreUserService firestoreUserService,
    required LogService logger,
  }) : _firestoreUserService = firestoreUserService,
       _logger = logger;

  /// Convertir un compte anonyme en compte avec email/mot de passe
  Future<UserCredential> upgradeAnonymousToEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      if (!currentUser.isAnonymous) {
        throw Exception('L\'utilisateur n\'est pas anonyme');
      }

      _logger.info(
        'Début de la mise à niveau du compte anonyme: ${currentUser.uid}',
      );

      // Créer les credentials email/mot de passe
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Lier le compte anonyme avec les nouveaux credentials
      final UserCredential userCredential = await currentUser
          .linkWithCredential(credential);

      // Mettre à jour le profil si un nom d'affichage est fourni
      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      // Envoyer l'email de vérification
      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();
      }

      // Mettre à jour les données Firestore
      await _updateFirestoreAfterUpgrade(
        userId: currentUser.uid,
        email: email,
        displayName: displayName,
        authProvider: 'email',
      );

      _logger.info(
        'Mise à niveau du compte anonyme réussie: ${currentUser.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Erreur Firebase lors de la mise à niveau: ${e.code}', e);
      rethrow;
    } catch (e) {
      _logger.error('Erreur lors de la mise à niveau du compte anonyme', e);
      rethrow;
    }
  }

  /// Convertir un compte anonyme en compte avec numéro de téléphone
  Future<UserCredential> upgradeAnonymousToPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      if (!currentUser.isAnonymous) {
        throw Exception('L\'utilisateur n\'est pas anonyme');
      }

      _logger.info(
        'Début de la mise à niveau du compte anonyme avec téléphone: ${currentUser.uid}',
      );

      // Créer les credentials téléphone
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Lier le compte anonyme avec les nouveaux credentials
      final UserCredential userCredential = await currentUser
          .linkWithCredential(credential);

      // Mettre à jour les données Firestore
      await _updateFirestoreAfterUpgrade(
        userId: currentUser.uid,
        phoneNumber: userCredential.user?.phoneNumber,
        authProvider: 'phone',
      );

      _logger.info(
        'Mise à niveau du compte anonyme avec téléphone réussie: ${currentUser.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'Erreur Firebase lors de la mise à niveau avec téléphone: ${e.code}',
        e,
      );
      rethrow;
    } catch (e) {
      _logger.error(
        'Erreur lors de la mise à niveau du compte anonyme avec téléphone',
        e,
      );
      rethrow;
    }
  }

  /// Lier un numéro de téléphone à un compte existant
  Future<UserCredential> linkPhoneNumberToAccount({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info(
        'Liaison d\'un numéro de téléphone au compte: ${currentUser.uid}',
      );

      // Créer les credentials téléphone
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Lier le numéro de téléphone au compte existant
      final UserCredential userCredential = await currentUser
          .linkWithCredential(credential);

      // Mettre à jour les données Firestore
      final updates = <String, dynamic>{
        'phoneNumber': userCredential.user?.phoneNumber,
        'phoneVerified': true,
        'updatedAt': DateTime.now(),
      };

      await _firestoreUserService.updateUser(currentUser.uid, updates);

      _logger.info(
        'Numéro de téléphone lié avec succès au compte: ${currentUser.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'Erreur Firebase lors de la liaison du téléphone: ${e.code}',
        e,
      );
      rethrow;
    } catch (e) {
      _logger.error('Erreur lors de la liaison du numéro de téléphone', e);
      rethrow;
    }
  }

  /// Vérifier si un compte peut être mis à niveau
  bool canUpgradeAccount(User? user) {
    return user != null && user.isAnonymous;
  }

  /// Vérifier si un numéro de téléphone peut être lié
  bool canLinkPhoneNumber(User? user) {
    if (user == null) return false;

    // Vérifier si l'utilisateur n'a pas déjà un numéro de téléphone lié
    return user.phoneNumber == null || user.phoneNumber!.isEmpty;
  }

  /// Obtenir les providers liés à un compte
  List<String> getLinkedProviders(User? user) {
    if (user == null) return [];

    return user.providerData.map((userInfo) => userInfo.providerId).toList();
  }

  /// Vérifier si un provider spécifique est lié
  bool isProviderLinked(User? user, String providerId) {
    return getLinkedProviders(user).contains(providerId);
  }

  /// Délier un provider du compte
  Future<User?> unlinkProvider(String providerId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      _logger.info(
        'Déliaison du provider $providerId du compte: ${currentUser.uid}',
      );

      final User updatedUser = await currentUser.unlink(providerId);

      // Mettre à jour Firestore selon le provider délié
      final updates = <String, dynamic>{'updatedAt': DateTime.now()};

      switch (providerId) {
        case 'phone':
          updates['phoneNumber'] = null;
          updates['phoneVerified'] = false;
          break;
        case 'password':
          updates['email'] = null;
          updates['emailVerified'] = false;
          break;
      }

      if (updates.length > 1) {
        // Plus que juste updatedAt
        await _firestoreUserService.updateUser(currentUser.uid, updates);
      }

      _logger.info(
        'Provider $providerId délié avec succès du compte: ${currentUser.uid}',
      );
      return updatedUser;
    } on FirebaseAuthException catch (e) {
      _logger.error(
        'Erreur Firebase lors de la déliaison du provider: ${e.code}',
        e,
      );
      rethrow;
    } catch (e) {
      _logger.error('Erreur lors de la déliaison du provider', e);
      rethrow;
    }
  }

  /// Mettre à jour Firestore après une mise à niveau de compte
  Future<void> _updateFirestoreAfterUpgrade({
    required String userId,
    String? email,
    String? phoneNumber,
    String? displayName,
    required String authProvider,
  }) async {
    try {
      final updates = <String, dynamic>{
        'isAnonymous': false,
        'authProvider': authProvider,
        'updatedAt': DateTime.now(),
      };

      if (email != null) {
        updates['email'] = email;
        updates['emailVerified'] = false; // Sera mis à jour après vérification
      }

      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
        updates['phoneVerified'] =
            true; // Le téléphone est vérifié lors de la liaison
      }

      if (displayName != null) {
        updates['fullName'] = displayName;
      }

      await _firestoreUserService.updateUser(userId, updates);
      _logger.info(
        'Données Firestore mises à jour après mise à niveau de compte',
      );
    } catch (e) {
      _logger.error(
        'Erreur lors de la mise à jour Firestore après mise à niveau',
        e,
      );
      // Ne pas faire échouer la mise à niveau pour une erreur Firestore
    }
  }

  /// Obtenir des suggestions pour améliorer la sécurité du compte
  List<AccountSecuritySuggestion> getSecuritySuggestions(User? user) {
    final suggestions = <AccountSecuritySuggestion>[];

    if (user == null) return suggestions;

    // Compte anonyme
    if (user.isAnonymous) {
      suggestions.add(
        AccountSecuritySuggestion(
          type: SecuritySuggestionType.upgradeAccount,
          title: 'Créer un compte permanent',
          description:
              'Convertir votre compte invité en compte permanent pour sécuriser vos données',
          priority: SecurityPriority.high,
        ),
      );
    }

    // Email non vérifié
    if (user.email != null && !user.emailVerified) {
      suggestions.add(
        AccountSecuritySuggestion(
          type: SecuritySuggestionType.verifyEmail,
          title: 'Vérifier votre email',
          description:
              'Vérifiez votre adresse email pour sécuriser votre compte',
          priority: SecurityPriority.medium,
        ),
      );
    }

    // Pas de numéro de téléphone lié
    if (user.phoneNumber == null && !user.isAnonymous) {
      suggestions.add(
        AccountSecuritySuggestion(
          type: SecuritySuggestionType.addPhoneNumber,
          title: 'Ajouter un numéro de téléphone',
          description:
              'Liez un numéro de téléphone pour une authentification à deux facteurs',
          priority: SecurityPriority.low,
        ),
      );
    }

    // Un seul provider de connexion
    if (user.providerData.length == 1 && !user.isAnonymous) {
      suggestions.add(
        AccountSecuritySuggestion(
          type: SecuritySuggestionType.addSecondProvider,
          title: 'Ajouter une méthode de connexion',
          description:
              'Ajoutez une seconde méthode de connexion pour plus de sécurité',
          priority: SecurityPriority.low,
        ),
      );
    }

    return suggestions;
  }
}

/// Types de suggestions de sécurité
enum SecuritySuggestionType {
  upgradeAccount,
  verifyEmail,
  addPhoneNumber,
  addSecondProvider,
}

/// Priorité de la suggestion
enum SecurityPriority { low, medium, high }

/// Modèle pour les suggestions de sécurité
class AccountSecuritySuggestion {
  final SecuritySuggestionType type;
  final String title;
  final String description;
  final SecurityPriority priority;

  const AccountSecuritySuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });
}

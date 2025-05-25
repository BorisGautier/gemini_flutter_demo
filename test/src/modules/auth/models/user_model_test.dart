import 'package:flutter_test/flutter_test.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

void main() {
  group('UserModel', () {
    const testUser = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: 'https://example.com/photo.jpg',
      phoneNumber: '+237123456789',
      emailVerified: true,
      isAnonymous: false,
      creationTime: null,
      lastSignInTime: null,
    );

    group('constructeur', () {
      test('crée un UserModel avec les valeurs correctes', () {
        expect(testUser.uid, equals('test-uid'));
        expect(testUser.email, equals('test@example.com'));
        expect(testUser.displayName, equals('Test User'));
        expect(testUser.photoURL, equals('https://example.com/photo.jpg'));
        expect(testUser.phoneNumber, equals('+237123456789'));
        expect(testUser.emailVerified, isTrue);
        expect(testUser.isAnonymous, isFalse);
      });

      test('crée un UserModel avec des valeurs par défaut', () {
        const user = UserModel(uid: 'test-uid');

        expect(user.uid, equals('test-uid'));
        expect(user.email, isNull);
        expect(user.displayName, isNull);
        expect(user.photoURL, isNull);
        expect(user.phoneNumber, isNull);
        expect(user.emailVerified, isFalse);
        expect(user.isAnonymous, isFalse);
        expect(user.creationTime, isNull);
        expect(user.lastSignInTime, isNull);
      });
    });

    group('fromMap', () {
      test('crée un UserModel à partir d\'un Map correct', () {
        final map = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
          'phoneNumber': '+237123456789',
          'emailVerified': true,
          'isAnonymous': false,
          'creationTime': 1640995200000, // 1er janvier 2022
          'lastSignInTime': 1640995200000,
        };

        final user = UserModel.fromMap(map);

        expect(user.uid, equals('test-uid'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.photoURL, equals('https://example.com/photo.jpg'));
        expect(user.phoneNumber, equals('+237123456789'));
        expect(user.emailVerified, isTrue);
        expect(user.isAnonymous, isFalse);
        expect(user.creationTime, isNotNull);
        expect(user.lastSignInTime, isNotNull);
      });

      test('gère les valeurs nulles correctement', () {
        final map = {'uid': 'test-uid'};

        final user = UserModel.fromMap(map);

        expect(user.uid, equals('test-uid'));
        expect(user.email, isNull);
        expect(user.displayName, isNull);
        expect(user.emailVerified, isFalse);
        expect(user.isAnonymous, isFalse);
      });
    });

    group('toMap', () {
      test('convertit un UserModel en Map correct', () {
        final map = testUser.toMap();

        expect(map['uid'], equals('test-uid'));
        expect(map['email'], equals('test@example.com'));
        expect(map['displayName'], equals('Test User'));
        expect(map['photoURL'], equals('https://example.com/photo.jpg'));
        expect(map['phoneNumber'], equals('+237123456789'));
        expect(map['emailVerified'], isTrue);
        expect(map['isAnonymous'], isFalse);
      });

      test('gère les valeurs nulles correctement', () {
        const user = UserModel(uid: 'test-uid');
        final map = user.toMap();

        expect(map['uid'], equals('test-uid'));
        expect(map['email'], isNull);
        expect(map['displayName'], isNull);
        expect(map['photoURL'], isNull);
        expect(map['phoneNumber'], isNull);
        expect(map['emailVerified'], isFalse);
        expect(map['isAnonymous'], isFalse);
        expect(map['creationTime'], isNull);
        expect(map['lastSignInTime'], isNull);
      });
    });

    group('empty', () {
      test('crée un UserModel vide', () {
        final emptyUser = UserModel.empty();

        expect(emptyUser.uid, equals(''));
        expect(emptyUser.email, isNull);
        expect(emptyUser.displayName, isNull);
        expect(emptyUser.isEmpty, isTrue);
        expect(emptyUser.isNotEmpty, isFalse);
      });
    });

    group('propriétés booléennes', () {
      test('isEmpty retourne true pour un utilisateur vide', () {
        final emptyUser = UserModel.empty();
        expect(emptyUser.isEmpty, isTrue);
      });

      test('isEmpty retourne false pour un utilisateur valide', () {
        expect(testUser.isEmpty, isFalse);
      });

      test('isNotEmpty retourne true pour un utilisateur valide', () {
        expect(testUser.isNotEmpty, isTrue);
      });

      test('isNotEmpty retourne false pour un utilisateur vide', () {
        final emptyUser = UserModel.empty();
        expect(emptyUser.isNotEmpty, isFalse);
      });
    });

    group('displayNameOrEmail', () {
      test('retourne displayName quand disponible', () {
        expect(testUser.displayNameOrEmail, equals('Test User'));
      });

      test('retourne email quand displayName n\'est pas disponible', () {
        const user = UserModel(uid: 'test-uid', email: 'test@example.com');
        expect(user.displayNameOrEmail, equals('test@example.com'));
      });

      test(
        'retourne phoneNumber quand ni displayName ni email disponibles',
        () {
          const user = UserModel(uid: 'test-uid', phoneNumber: '+237123456789');
          expect(user.displayNameOrEmail, equals('+237123456789'));
        },
      );

      test('retourne "Utilisateur" par défaut', () {
        const user = UserModel(uid: 'test-uid');
        expect(user.displayNameOrEmail, equals('Utilisateur'));
      });
    });

    group('initials', () {
      test('retourne les initiales du nom complet', () {
        expect(testUser.initials, equals('TU'));
      });

      test('retourne la première lettre si un seul mot', () {
        const user = UserModel(uid: 'test-uid', displayName: 'Test');
        expect(user.initials, equals('T'));
      });

      test('retourne la première lettre de l\'email si pas de displayName', () {
        const user = UserModel(uid: 'test-uid', email: 'test@example.com');
        expect(user.initials, equals('T'));
      });

      test('retourne "U" par défaut', () {
        const user = UserModel(uid: 'test-uid');
        expect(user.initials, equals('U'));
      });
    });

    group('copyWith', () {
      test('crée une copie avec les modifications', () {
        final modifiedUser = testUser.copyWith(
          displayName: 'Nouveau nom',
          emailVerified: false,
        );

        expect(modifiedUser.uid, equals(testUser.uid));
        expect(modifiedUser.email, equals(testUser.email));
        expect(modifiedUser.displayName, equals('Nouveau nom'));
        expect(modifiedUser.emailVerified, isFalse);
        expect(modifiedUser.photoURL, equals(testUser.photoURL));
      });

      test('garde les valeurs originales si pas de modifications', () {
        final copiedUser = testUser.copyWith();

        expect(copiedUser, equals(testUser));
      });
    });

    group('equality', () {
      test('deux UserModel identiques sont égaux', () {
        const user1 = UserModel(uid: 'test-uid', email: 'test@example.com');
        const user2 = UserModel(uid: 'test-uid', email: 'test@example.com');

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('deux UserModel différents ne sont pas égaux', () {
        const user1 = UserModel(uid: 'test-uid-1', email: 'test1@example.com');
        const user2 = UserModel(uid: 'test-uid-2', email: 'test2@example.com');

        expect(user1, isNot(equals(user2)));
      });
    });

    group('toString', () {
      test('retourne une représentation string correcte', () {
        final string = testUser.toString();

        expect(string, contains('UserModel'));
        expect(string, contains('test-uid'));
        expect(string, contains('test@example.com'));
        expect(string, contains('Test User'));
      });
    });
  });

  group('UserModelAuthProvider extension', () {
    group('primaryAuthProvider', () {
      test('retourne anonymous pour un utilisateur anonyme', () {
        const user = UserModel(uid: 'test-uid', isAnonymous: true);
        expect(user.primaryAuthProvider, equals(AuthProvider.anonymous));
      });

      test('retourne email pour un utilisateur avec email', () {
        const user = UserModel(uid: 'test-uid', email: 'test@example.com');
        expect(user.primaryAuthProvider, equals(AuthProvider.email));
      });

      test('retourne phone pour un utilisateur avec téléphone seulement', () {
        const user = UserModel(uid: 'test-uid', phoneNumber: '+237123456789');
        expect(user.primaryAuthProvider, equals(AuthProvider.phone));
      });

      test('retourne email par défaut', () {
        const user = UserModel(uid: 'test-uid');
        expect(user.primaryAuthProvider, equals(AuthProvider.email));
      });
    });

    group('canSignInWithPhone', () {
      test('retourne true si l\'utilisateur a un numéro de téléphone', () {
        const user = UserModel(uid: 'test-uid', phoneNumber: '+237123456789');
        expect(user.canSignInWithPhone, isTrue);
      });

      test('retourne false si l\'utilisateur n\'a pas de numéro', () {
        const user = UserModel(uid: 'test-uid');
        expect(user.canSignInWithPhone, isFalse);
      });
    });
  });
}

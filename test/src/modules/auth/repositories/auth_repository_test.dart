import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/services/firestore_user.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';

import 'auth_repository_test.mocks.dart';

// Générer les mocks avec: flutter packages pub run build_runner build
@GenerateMocks([
  AuthService,
  LogService,
  FirestoreUserService,
  UserCredential,
  User,
])
void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockAuthService mockAuthService;
    late MockLogService mockLogService;
    late MockFirestoreUserService mockFirestoreUserService;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    const testUserModel = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      emailVerified: true,
    );

    final testFirestoreUser = FirestoreUserModel(
      userId: 'test-uid',
      fullName: 'Test User',
      username: 'testuser123',
      email: 'test@example.com',
      authProvider: 'email',
      accountStatus: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      appInfo: AppInfo(
        version: '1.0.0',
        buildNumber: '1',
        platform: 'android',
        environment: 'test',
        installDate: DateTime.now(),
      ),
      deviceInfo: DeviceInfo(
        deviceId: 'test-device',
        deviceName: 'Test Device',
        model: 'Test Model',
        brand: 'Test Brand',
        osVersion: '10.0',
        platformVersion: '30',
        isPhysicalDevice: true,
        language: 'fr',
        country: 'CM',
        timezone: 'Africa/Douala',
      ),
      preferences: UserPreferences.defaultPreferences(),
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockLogService = MockLogService();
      mockFirestoreUserService = MockFirestoreUserService();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();

      authRepository = AuthRepository(
        authService: mockAuthService,
        firestoreUserService: mockFirestoreUserService,
        logger: mockLogService,
      );

      // Configuration des mocks par défaut
      when(mockUserCredential.user).thenReturn(mockUser);
      when(
        mockAuthService.firebaseUserToUserModel(any),
      ).thenReturn(testUserModel);
      when(
        mockFirestoreUserService.updateLastSignIn(any),
      ).thenAnswer((_) async => {});
    });

    group('authStateChanges', () {
      test('retourne un stream de UserModel depuis le service', () {
        // Arrange
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => Stream.value(mockUser));

        // Act
        final stream = authRepository.authStateChanges;

        // Assert
        expect(stream, emits(testUserModel));
        verify(mockAuthService.authStateChanges).called(1);
      });

      test('retourne null quand l\'utilisateur est déconnecté', () {
        // Arrange
        when(
          mockAuthService.authStateChanges,
        ).thenAnswer((_) => Stream.value(null));
        when(mockAuthService.firebaseUserToUserModel(null)).thenReturn(null);

        // Act
        final stream = authRepository.authStateChanges;

        // Assert
        expect(stream, emits(null));
      });
    });

    group('currentUser', () {
      test('retourne l\'utilisateur actuel depuis le service', () {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(mockUser);

        // Act
        final result = authRepository.currentUser;

        // Assert
        expect(result, equals(testUserModel));
        verify(mockAuthService.currentUser).called(1);
        verify(mockAuthService.firebaseUserToUserModel(mockUser)).called(1);
      });

      test('retourne null quand aucun utilisateur connecté', () {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(null);
        when(mockAuthService.firebaseUserToUserModel(null)).thenReturn(null);

        // Act
        final result = authRepository.currentUser;

        // Assert
        expect(result, isNull);
      });
    });

    group('isSignedIn', () {
      test('retourne true quand un utilisateur est connecté', () {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(true);

        // Act
        final result = authRepository.isSignedIn;

        // Assert
        expect(result, isTrue);
        verify(mockAuthService.isSignedIn).called(1);
      });

      test('retourne false quand aucun utilisateur connecté', () {
        // Arrange
        when(mockAuthService.isSignedIn).thenReturn(false);

        // Act
        final result = authRepository.isSignedIn;

        // Assert
        expect(result, isFalse);
      });
    });

    group('signInWithEmailAndPassword', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test(
        'retourne UserModel et met à jour Firestore quand la connexion réussit avec utilisateur existant',
        () async {
          // Arrange
          when(
            mockAuthService.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(
            mockFirestoreUserService.getUser(any),
          ).thenAnswer((_) async => testFirestoreUser);

          // Act
          final result = await authRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result, equals(testUserModel));
          verify(
            mockAuthService.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
          verify(mockFirestoreUserService.getUser('test-uid')).called(1);
          verify(
            mockFirestoreUserService.updateLastSignIn('test-uid'),
          ).called(1);
          verify(
            mockLogService.info(
              'Repository: Tentative de connexion avec email',
            ),
          ).called(1);
        },
      );

      test(
        'crée un utilisateur Firestore quand la connexion réussit avec nouvel utilisateur',
        () async {
          // Arrange
          when(
            mockAuthService.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(
            mockFirestoreUserService.getUser(any),
          ).thenAnswer((_) async => null);
          when(
            mockFirestoreUserService.createUser(
              authUser: anyNamed('authUser'),
              fullName: anyNamed('fullName'),
            ),
          ).thenAnswer((_) async => testFirestoreUser);

          // Act
          final result = await authRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          );

          // Assert
          expect(result, equals(testUserModel));
          verify(mockFirestoreUserService.getUser('test-uid')).called(1);
          verify(
            mockFirestoreUserService.createUser(
              authUser: testUserModel,
              fullName: anyNamed('fullName'),
            ),
          ).called(1);
        },
      );

      test('lance une exception quand la connexion échoue', () async {
        // Arrange
        final exception = FirebaseAuthException(
          code: 'user-not-found',
          message: 'Utilisateur non trouvé',
        );
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => authRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
        verify(
          mockLogService.error('Repository: Erreur de connexion', exception),
        ).called(1);
      });
    });

    group('createUserWithEmailAndPassword', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testDisplayName = 'Test User';

      test(
        'retourne UserModel et crée utilisateur Firestore quand l\'inscription réussit',
        () async {
          // Arrange
          when(
            mockAuthService.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              displayName: anyNamed('displayName'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(
            mockAuthService.sendEmailVerification(),
          ).thenAnswer((_) async => {});
          when(
            mockFirestoreUserService.createUser(
              authUser: anyNamed('authUser'),
              fullName: anyNamed('fullName'),
            ),
          ).thenAnswer((_) async => testFirestoreUser);

          // Act
          final result = await authRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
            displayName: testDisplayName,
          );

          // Assert
          expect(result, equals(testUserModel));
          verify(
            mockAuthService.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
              displayName: testDisplayName,
            ),
          ).called(1);
          verify(
            mockFirestoreUserService.createUser(
              authUser: testUserModel,
              fullName: testDisplayName,
            ),
          ).called(1);
          verify(mockAuthService.sendEmailVerification()).called(1);
        },
      );
    });

    group('signInAnonymously', () {
      test(
        'retourne UserModel et crée utilisateur Firestore anonyme quand la connexion réussit',
        () async {
          // Arrange
          const anonymousUser = UserModel(
            uid: 'anonymous-uid',
            isAnonymous: true,
          );
          when(
            mockAuthService.signInAnonymously(),
          ).thenAnswer((_) async => mockUserCredential);
          when(
            mockAuthService.firebaseUserToUserModel(any),
          ).thenReturn(anonymousUser);
          when(
            mockFirestoreUserService.createUser(
              authUser: anyNamed('authUser'),
              fullName: anyNamed('fullName'),
            ),
          ).thenAnswer((_) async => testFirestoreUser);

          // Act
          final result = await authRepository.signInAnonymously();

          // Assert
          expect(result, equals(anonymousUser));
          verify(mockAuthService.signInAnonymously()).called(1);
          verify(
            mockFirestoreUserService.createUser(
              authUser: anonymousUser,
              fullName: 'Utilisateur Anonyme',
            ),
          ).called(1);
        },
      );
    });

    group('signInWithPhoneNumber', () {
      const testVerificationId = 'verification-id';
      const testSmsCode = '123456';

      test(
        'retourne UserModel et gère Firestore pour connexion téléphone réussie',
        () async {
          // Arrange
          final phoneUser = testUserModel.copyWith(
            phoneNumber: '+237123456789',
          );
          when(
            mockAuthService.signInWithPhoneNumber(
              verificationId: anyNamed('verificationId'),
              smsCode: anyNamed('smsCode'),
            ),
          ).thenAnswer((_) async => mockUserCredential);
          when(
            mockAuthService.firebaseUserToUserModel(any),
          ).thenReturn(phoneUser);
          when(
            mockFirestoreUserService.getUser(any),
          ).thenAnswer((_) async => null);
          when(
            mockFirestoreUserService.createUser(
              authUser: anyNamed('authUser'),
              fullName: anyNamed('fullName'),
            ),
          ).thenAnswer((_) async => testFirestoreUser);

          // Act
          final result = await authRepository.signInWithPhoneNumber(
            verificationId: testVerificationId,
            smsCode: testSmsCode,
          );

          // Assert
          expect(result, equals(phoneUser));
          verify(mockFirestoreUserService.getUser('test-uid')).called(1);
          verify(
            mockFirestoreUserService.createUser(
              authUser: phoneUser,
              fullName: '+237123456789',
            ),
          ).called(1);
        },
      );
    });

    group('updateUserProfile', () {
      const displayName = 'Nouveau nom';
      const photoURL = 'https://example.com/photo.jpg';

      test(
        'appelle le service et met à jour Firestore avec les paramètres corrects',
        () async {
          // Arrange
          when(
            mockAuthService.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL'),
            ),
          ).thenAnswer((_) async => {});
          when(mockAuthService.currentUser).thenReturn(mockUser);
          when(mockUser.uid).thenReturn('test-uid');
          when(
            mockFirestoreUserService.updateUser(any, any),
          ).thenAnswer((_) async => {});

          // Act
          await authRepository.updateUserProfile(
            displayName: displayName,
            photoURL: photoURL,
          );

          // Assert
          verify(
            mockAuthService.updateUserProfile(
              displayName: displayName,
              photoURL: photoURL,
            ),
          ).called(1);
          verify(
            mockFirestoreUserService.updateUser('test-uid', {
              'fullName': displayName,
              'photoURL': photoURL,
            }),
          ).called(1);
        },
      );
    });

    group('deleteAccount', () {
      test('supprime de Firestore puis de Firebase Auth', () async {
        // Arrange
        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');
        when(
          mockFirestoreUserService.deleteUser(any),
        ).thenAnswer((_) async => {});
        when(mockAuthService.deleteAccount()).thenAnswer((_) async => {});

        // Act
        await authRepository.deleteAccount();

        // Assert
        verify(mockFirestoreUserService.deleteUser('test-uid')).called(1);
        verify(mockAuthService.deleteAccount()).called(1);
      });
    });

    // ✅ NOUVEAUX TESTS POUR LES MÉTHODES FIRESTORE

    group('getFirestoreUser', () {
      test('retourne FirestoreUserModel depuis le service', () async {
        // Arrange
        when(
          mockFirestoreUserService.getUser(any),
        ).thenAnswer((_) async => testFirestoreUser);

        // Act
        final result = await authRepository.getFirestoreUser('test-uid');

        // Assert
        expect(result, equals(testFirestoreUser));
        verify(mockFirestoreUserService.getUser('test-uid')).called(1);
      });

      test('retourne null quand utilisateur non trouvé', () async {
        // Arrange
        when(
          mockFirestoreUserService.getUser(any),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authRepository.getFirestoreUser('test-uid');

        // Assert
        expect(result, isNull);
      });
    });

    group('updateFirestoreUser', () {
      test('appelle updateUser sur le service Firestore', () async {
        // Arrange
        final updates = {'fullName': 'Nouveau nom'};
        when(
          mockFirestoreUserService.updateUser(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await authRepository.updateFirestoreUser('test-uid', updates);

        // Assert
        verify(
          mockFirestoreUserService.updateUser('test-uid', updates),
        ).called(1);
      });
    });

    group('updateUserLocation', () {
      test('appelle updateUserLocation sur le service Firestore', () async {
        // Arrange
        final location = UserLocation(
          latitude: 4.0511,
          longitude: 9.7679,
          timestamp: DateTime.now(),
        );
        when(
          mockFirestoreUserService.updateUserLocation(any, any),
        ).thenAnswer((_) async => {});

        // Act
        await authRepository.updateUserLocation('test-uid', location);

        // Assert
        verify(
          mockFirestoreUserService.updateUserLocation('test-uid', location),
        ).called(1);
      });
    });
  });
}

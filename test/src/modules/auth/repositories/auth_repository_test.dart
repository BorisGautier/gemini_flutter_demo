import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kartia/src/core/services/auth.service.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';

import 'auth_repository_test.mocks.dart';

// Générer les mocks avec: flutter packages pub run build_runner build
@GenerateMocks([AuthService, LogService, UserCredential, User])
void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockAuthService mockAuthService;
    late MockLogService mockLogService;
    late MockUserCredential mockUserCredential;
    late MockUser mockUser;

    const testUserModel = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      emailVerified: true,
    );

    setUp(() {
      mockAuthService = MockAuthService();
      mockLogService = MockLogService();
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();

      authRepository = AuthRepository(
        authService: mockAuthService,
        logger: mockLogService,
      );

      // Configuration des mocks par défaut
      when(mockUserCredential.user).thenReturn(mockUser);
      when(
        mockAuthService.firebaseUserToUserModel(any),
      ).thenReturn(testUserModel);
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

      test('retourne UserModel quand la connexion réussit', () async {
        // Arrange
        when(
          mockAuthService.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => mockUserCredential);

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
        verify(
          mockLogService.info('Repository: Tentative de connexion avec email'),
        ).called(1);
      });

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

      test('retourne UserModel quand l\'inscription réussit', () async {
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
        verify(mockAuthService.sendEmailVerification()).called(1);
      });
    });

    group('signInAnonymously', () {
      test('retourne UserModel quand la connexion anonyme réussit', () async {
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

        // Act
        final result = await authRepository.signInAnonymously();

        // Assert
        expect(result, equals(anonymousUser));
        verify(mockAuthService.signInAnonymously()).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      const testEmail = 'test@example.com';

      test('appelle le service avec l\'email correct', () async {
        // Arrange
        when(
          mockAuthService.sendPasswordResetEmail(email: anyNamed('email')),
        ).thenAnswer((_) async => {});

        // Act
        await authRepository.sendPasswordResetEmail(email: testEmail);

        // Assert
        verify(
          mockAuthService.sendPasswordResetEmail(email: testEmail),
        ).called(1);
        verify(
          mockLogService.info('Repository: Envoi d\'email de réinitialisation'),
        ).called(1);
      });
    });

    group('updateUserProfile', () {
      const displayName = 'Nouveau nom';
      const photoURL = 'https://example.com/photo.jpg';

      test('appelle le service avec les paramètres corrects', () async {
        // Arrange
        when(
          mockAuthService.updateUserProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
          ),
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
      });
    });

    group('signOut', () {
      test('appelle signOut sur le service', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async => {});

        // Act
        await authRepository.signOut();

        // Assert
        verify(mockAuthService.signOut()).called(1);
        verify(
          mockLogService.info('Repository: Déconnexion de l\'utilisateur'),
        ).called(1);
      });
    });

    group('deleteAccount', () {
      test('appelle deleteAccount sur le service', () async {
        // Arrange
        when(mockAuthService.deleteAccount()).thenAnswer((_) async => {});

        // Act
        await authRepository.deleteAccount();

        // Assert
        verify(mockAuthService.deleteAccount()).called(1);
      });
    });
  });
}

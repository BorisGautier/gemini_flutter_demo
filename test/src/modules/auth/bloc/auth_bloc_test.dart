import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/modules/auth/repositories/auth.repository.dart';

import 'auth_bloc_test.mocks.dart';

// Générer les mocks avec: flutter packages pub run build_runner build
@GenerateMocks([AuthRepositoryInterface, LogService])
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepositoryInterface mockAuthRepository;
    late MockLogService mockLogService;

    const testUser = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
      emailVerified: true,
    );

    setUp(() {
      mockAuthRepository = MockAuthRepositoryInterface();
      mockLogService = MockLogService();

      authBloc = AuthBloc(
        authRepository: mockAuthRepository,
        logger: mockLogService,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('état initial est correct', () {
      expect(authBloc.state, equals(AuthState.initial()));
    });

    group('AuthInitialized', () {
      blocTest<AuthBloc, AuthState>(
        'démarre l\'écoute des changements d\'authentification',
        build: () {
          when(
            mockAuthRepository.authStateChanges,
          ).thenAnswer((_) => Stream.value(testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthInitialized()),
        expect: () => [AuthState.initial().authenticated(testUser)],
        verify: (_) {
          verify(mockAuthRepository.authStateChanges).called(1);
        },
      );
    });

    group('AuthSignInWithEmailAndPasswordRequested', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      blocTest<AuthBloc, AuthState>(
        'émet [loading, authenticated] quand la connexion réussit',
        build: () {
          when(
            mockAuthRepository.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              const AuthSignInWithEmailAndPasswordRequested(
                email: testEmail,
                password: testPassword,
              ),
            ),
        expect: () => [AuthState.initial().loading()],
        verify: (_) {
          verify(
            mockAuthRepository.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'émet [loading, error] quand la connexion échoue',
        build: () {
          when(
            mockAuthRepository.signInWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'Utilisateur non trouvé',
            ),
          );
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              const AuthSignInWithEmailAndPasswordRequested(
                email: testEmail,
                password: testPassword,
              ),
            ),
        expect:
            () => [
              AuthState.initial().loading(),
              AuthState.initial().error(
                message: 'Aucun utilisateur trouvé avec cette adresse email.',
                code: 'user-not-found',
              ),
            ],
      );
    });

    group('AuthSignUpWithEmailAndPasswordRequested', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testDisplayName = 'Test User';

      blocTest<AuthBloc, AuthState>(
        'émet [loading] quand l\'inscription réussit',
        build: () {
          when(
            mockAuthRepository.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              displayName: anyNamed('displayName'),
            ),
          ).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              const AuthSignUpWithEmailAndPasswordRequested(
                email: testEmail,
                password: testPassword,
                displayName: testDisplayName,
              ),
            ),
        expect: () => [AuthState.initial().loading()],
        verify: (_) {
          verify(
            mockAuthRepository.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
              displayName: testDisplayName,
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'émet [loading, error] quand l\'inscription échoue',
        build: () {
          when(
            mockAuthRepository.createUserWithEmailAndPassword(
              email: anyNamed('email'),
              password: anyNamed('password'),
              displayName: anyNamed('displayName'),
            ),
          ).thenThrow(
            FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'Email déjà utilisé',
            ),
          );
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              const AuthSignUpWithEmailAndPasswordRequested(
                email: testEmail,
                password: testPassword,
                displayName: testDisplayName,
              ),
            ),
        expect:
            () => [
              AuthState.initial().loading(),
              AuthState.initial().error(
                message:
                    'Cette adresse email est déjà utilisée par un autre compte.',
                code: 'email-already-in-use',
              ),
            ],
      );
    });

    group('AuthSignInAnonymouslyRequested', () {
      const anonymousUser = UserModel(uid: 'anonymous-uid', isAnonymous: true);

      blocTest<AuthBloc, AuthState>(
        'émet [loading] quand la connexion anonyme réussit',
        build: () {
          when(
            mockAuthRepository.signInAnonymously(),
          ).thenAnswer((_) async => anonymousUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInAnonymouslyRequested()),
        expect: () => [AuthState.initial().loading()],
        verify: (_) {
          verify(mockAuthRepository.signInAnonymously()).called(1);
        },
      );
    });

    group('AuthPasswordResetRequested', () {
      const testEmail = 'test@example.com';

      blocTest<AuthBloc, AuthState>(
        'émet [loading, unauthenticated] quand la réinitialisation réussit',
        build: () {
          when(
            mockAuthRepository.sendPasswordResetEmail(email: anyNamed('email')),
          ).thenAnswer((_) async => {});
          return authBloc;
        },
        act:
            (bloc) =>
                bloc.add(const AuthPasswordResetRequested(email: testEmail)),
        expect:
            () => [
              AuthState.initial().loading(),
              AuthState.initial().unauthenticated(),
            ],
        verify: (_) {
          verify(
            mockAuthRepository.sendPasswordResetEmail(email: testEmail),
          ).called(1);
        },
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'appelle signOut sur le repository',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        verify: (_) {
          verify(mockAuthRepository.signOut()).called(1);
        },
      );
    });

    group('AuthUpdateUserProfileRequested', () {
      const displayName = 'Nouveau nom';
      const photoURL = 'https://example.com/photo.jpg';

      blocTest<AuthBloc, AuthState>(
        'émet [loading] quand la mise à jour réussit',
        setUp: () {
          authBloc.emit(AuthState.initial().authenticated(testUser));
        },
        build: () {
          when(
            mockAuthRepository.updateUserProfile(
              displayName: anyNamed('displayName'),
              photoURL: anyNamed('photoURL'),
            ),
          ).thenAnswer((_) async => {});
          return authBloc;
        },
        act:
            (bloc) => bloc.add(
              const AuthUpdateUserProfileRequested(
                displayName: displayName,
                photoURL: photoURL,
              ),
            ),
        expect:
            () => [
              isA<AuthState>().having(
                (state) => state.isLoading,
                'isLoading',
                true,
              ),
            ],
        verify: (_) {
          verify(
            mockAuthRepository.updateUserProfile(
              displayName: displayName,
              photoURL: photoURL,
            ),
          ).called(1);
        },
      );
    });

    group('AuthErrorCleared', () {
      blocTest<AuthBloc, AuthState>(
        'efface l\'erreur et retourne à l\'état précédent',
        setUp: () {
          authBloc.emit(AuthState.initial().error(message: 'Erreur test'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthErrorCleared()),
        expect: () => [AuthState.initial().unauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'efface l\'erreur et retourne à l\'état authentifié si utilisateur connecté',
        setUp: () {
          authBloc.emit(
            AuthState.initial()
                .authenticated(testUser)
                .copyWith(
                  status: AuthStatus.error,
                  errorMessage: 'Erreur test',
                ),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthErrorCleared()),
        expect: () => [AuthState.initial().authenticated(testUser)],
      );
    });
  });
}

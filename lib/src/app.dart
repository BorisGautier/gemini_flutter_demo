// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/di/di.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';
import 'package:kartia/src/modules/splash/views/splash.screen.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/home/views/home.screen.dart';

/// Widget racine de l'application Kartia
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoC principal de l'application (thème, langue)
        BlocProvider(create: (context) => getIt<AppBloc>()),

        // BLoC d'authentification global
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(const AuthInitialized()),
        ),

        // BLoC de l'écran de splash
        BlocProvider(create: (context) => getIt<SplashBloc>()),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          return MaterialApp(
            // Configuration de base
            title: "Kartia",
            debugShowCheckedModeBanner: false,

            // Thème et localisation
            theme: appState.themeData,
            locale: appState.locale,

            // Délégués de localisation
            localizationsDelegates: const [
              KartiaLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: KartiaLocalizations.delegate.supportedLocales,

            // Navigation
            onGenerateRoute: AppRoutes.generateRoute,

            // Page d'accueil avec navigation conditionnelle
            home: const AppNavigationManager(),
          );
        },
      ),
    );
  }
}

/// Gestionnaire de navigation principal qui décide quelle page afficher
class AppNavigationManager extends StatefulWidget {
  const AppNavigationManager({super.key});

  @override
  State<AppNavigationManager> createState() => _AppNavigationManagerState();
}

class _AppNavigationManagerState extends State<AppNavigationManager> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Naviguer seulement si le splash est terminé
        if (_splashCompleted) {
          _handleAuthStateChange(context, authState);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Toujours afficher le splash en premier si pas encore terminé
          if (!_splashCompleted) {
            return BlocListener<SplashBloc, SplashState>(
              listener: (context, splashState) {
                if (splashState.isReadyToNavigate) {
                  setState(() {
                    _splashCompleted = true;
                  });
                  // Naviguer immédiatement après le splash
                  _handleAuthStateChange(context, authState);
                }
              },
              child: const SplashScreen(),
            );
          }

          // Après le splash, afficher la page appropriée selon l'état d'auth
          return _getPageForAuthState(authState);
        },
      ),
    );
  }

  /// Gérer les changements d'état d'authentification
  void _handleAuthStateChange(BuildContext context, AuthState authState) {
    if (!mounted) return;

    // Délai pour s'assurer que le context est stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (authState.isAuthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (authState.isUnauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (_) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: const LoginScreen(),
                ),
          ),
          (route) => false,
        );
      }
    });
  }

  /// Obtenir la page appropriée selon l'état d'authentification
  Widget _getPageForAuthState(AuthState authState) {
    if (authState.isAuthenticated) {
      return const HomeScreen();
    } else {
      return BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const LoginScreen(),
      );
    }
  }
}

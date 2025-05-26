// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/views/email_verification_screen.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/home/views/home.screen.dart';
import 'package:kartia/src/modules/splash/views/splash.screen.dart';
import 'package:kartia/src/modules/gps/views/gps_loading.screen.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';

/// Gestionnaire de navigation principal qui décide quelle page afficher
class AppNavigationManager extends StatelessWidget {
  const AppNavigationManager({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GpsBloc, GpsState>(
      builder: (context, gpsState) {
        // Si le GPS n'est pas accordé, afficher l'écran GPS
        if (!gpsState.isAllGranted) {
          return const GpsLoadingScreen();
        }

        // Une fois le GPS accordé, gérer l'authentification
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // ✅ AMÉLIORATION : Debug pour voir l'état actuel
            debugPrint(
              'AppNavigationManager - AuthState: ${authState.status}, User: ${authState.user?.uid}, IsLoading: ${authState.isLoading}',
            );

            // État initial - afficher l'écran de splash
            if (authState.status == AuthStatus.unknown) {
              return const SplashScreen();
            }
            if (authState.isLoading) {
              // Si on a un utilisateur et qu'on est en chargement,
              // afficher l'écran approprié sans indicateur supplémentaire
              if (authState.user != null) {
                final user = authState.user!;
                if (!user.emailVerified &&
                    !user.isAnonymous &&
                    user.phoneNumber == null) {
                  return EmailVerificationScreen(user: user);
                } else {
                  return const HomeScreen();
                }
              } else {
                // Pas d'utilisateur, afficher le login avec indicateur de chargement
                return const LoginScreen();
              }
            }

            // Email non vérifié
            if (authState.isEmailNotVerified && authState.user != null) {
              return EmailVerificationScreen(user: authState.user!);
            }

            // Utilisateur authentifié
            if (authState.isAuthenticated && authState.user != null) {
              return const HomeScreen();
            }

            // Utilisateur non authentifié ou erreur
            if (authState.isUnauthenticated || authState.hasError) {
              return const LoginScreen();
            }

            // État par défaut
            return const LoginScreen();
          },
        );
      },
    );
  }
}

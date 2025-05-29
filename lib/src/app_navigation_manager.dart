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
            debugPrint(
              'AppNavigationManager - AuthState: ${authState.status}, User: ${authState.user?.uid}, IsAnonymous: ${authState.user?.isAnonymous}, IsLoading: ${authState.isLoading}',
            );

            // État initial - afficher l'écran de splash
            if (authState.status == AuthStatus.unknown) {
              return const SplashScreen();
            }

            if (authState.isLoading &&
                authState.status != AuthStatus.updatingProfile &&
                authState.status != AuthStatus.phoneVerificationInProgress &&
                authState.status != AuthStatus.phoneCodeSent) {
              // Si on a un utilisateur et qu'on est en chargement (pas de mise à jour profil),
              // afficher l'écran approprié sans indicateur supplémentaire
              if (authState.user != null) {
                final user = authState.user!;

                if (user.isAnonymous) {
                  return const HomeScreen();
                }

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

            // ✅ NOUVEAU: Gestion spéciale pour les états de vérification téléphone
            if (authState.status == AuthStatus.phoneVerificationInProgress ||
                authState.status == AuthStatus.phoneCodeSent) {
              // Rester sur l'écran actuel pendant la vérification téléphone
              if (authState.user != null) {
                return const HomeScreen(); // ou l'écran où se déroule la vérification
              }
            }

            // ✅ NOUVEAU: Pendant la mise à jour du profil, rester sur l'écran actuel
            if (authState.status == AuthStatus.updatingProfile &&
                authState.user != null) {
              final user = authState.user!;

              if (user.isAnonymous) {
                return const HomeScreen();
              } else if (!user.emailVerified &&
                  !user.isAnonymous &&
                  user.phoneNumber == null) {
                return EmailVerificationScreen(user: user);
              } else {
                return const HomeScreen();
              }
            }

            // Email non vérifié
            if (authState.isEmailNotVerified && authState.user != null) {
              return EmailVerificationScreen(user: authState.user!);
            }

            // ✅ Utilisateur authentifié (incluant les comptes anonymes)
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

// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/home/views/home.screen.dart';
import 'package:kartia/src/modules/splash/views/splash.screen.dart';
import 'package:kartia/src/modules/gps/views/gps_loading.screen.dart';

/// Gestionnaire de navigation principal qui décide quelle page afficher
class AppNavigationManager extends StatelessWidget {
  const AppNavigationManager({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // État initial - afficher l'écran de splash
        if (state.status == AuthStatus.unknown) {
          return const SplashScreen();
        }

        // Utilisateur non authentifié - afficher l'écran de connexion
        if (state.isUnauthenticated) {
          return const LoginScreen(); // Ne plus créer un nouveau BlocProvider ici
        }

        // Utilisateur authentifié - afficher l'écran d'accueil
        if (state.isAuthenticated) {
          return const HomeScreen();
        }

        // État de chargement - afficher l'écran de splash
        if (state.isLoading) {
          return const SplashScreen();
        }

        // Par défaut, afficher l'écran de chargement GPS
        return const GpsLoadingScreen();
      },
    );
  }
}

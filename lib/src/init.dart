// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:kartia/src/core/di/di.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';

/// Widget d'initialisation qui gère le démarrage de l'application
class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Vérifier que le DI est bien initialisé
      if (!DIManager.isInitialized) {
        final success = await DIManager.safeInit();
        if (!success) {
          throw Exception('Échec de l\'initialisation des dépendances');
        }
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erreur d\'initialisation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Initialisation de l\'application...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

/// Extension pour les routes personnalisées
extension AppRoutesExtension on AppRoutes {
  /// Obtenir la route initiale basée sur l'état d'authentification
  static String getInitialRoute(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.authenticated:
        return AppRoutes.home;
      case AuthStatus.unauthenticated:
        return AppRoutes.login;
      default:
        return AppRoutes.splash;
    }
  }
}

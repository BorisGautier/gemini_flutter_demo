// lib/src/core/routes/app.routes.dart (VERSION MISE À JOUR)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/views/edit_profile.screen.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/auth/views/profile.screen.dart';
import 'package:kartia/src/modules/auth/views/register.screen.dart';
import 'package:kartia/src/modules/auth/views/phone_auth.screen.dart';
import 'package:kartia/src/modules/auth/views/forgot_password.screen.dart';
import 'package:kartia/src/modules/auth/views/upgrade_account.screen.dart'; // ✅ NOUVEAU
import 'package:kartia/src/modules/home/views/home.screen.dart';
import 'package:kartia/src/modules/splash/views/splash.screen.dart';

/// Classe pour gérer les routes de l'application
class AppRoutes {
  // Routes existantes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneAuth = '/phone-auth';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  // ✅ NOUVELLES ROUTES
  static const String upgradeAccount = '/upgrade-account';
  static const String phoneVerification = '/phone-verification';
  static const String linkPhoneNumber = '/link-phone';
  static const String accountSecurity = '/account-security';
  static const String resetPassword = '/reset-password';
  static const String parametres = '/settings';
  static const String notifications = '/notifications';
  static const String privacy = '/privacy';
  static const String about = '/about';

  /// Liste de toutes les routes disponibles
  static List<String> get allRoutes => [
    splash,
    login,
    register,
    phoneAuth,
    forgotPassword,
    home,
    profile,
    editProfile,
    upgradeAccount,
    phoneVerification,
    linkPhoneNumber,
    accountSecurity,
    resetPassword,
    parametres,
    notifications,
    privacy,
    about,
  ];

  /// Routes qui ne nécessitent pas d'authentification
  static List<String> get publicRoutes => [
    splash,
    login,
    register,
    phoneAuth,
    forgotPassword,
    resetPassword,
  ];

  /// Routes qui nécessitent une authentification
  static List<String> get protectedRoutes => [
    home,
    profile,
    editProfile,
    upgradeAccount,
    linkPhoneNumber,
    accountSecurity,
    parametres,
    notifications,
    privacy,
    about,
  ];

  /// Routes accessibles uniquement aux comptes anonymes
  static List<String> get anonymousOnlyRoutes => [upgradeAccount];

  /// Générer les routes de l'application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(settings, const SplashScreen());

      case login:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(home);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const LoginScreen();
            },
          ),
        );

      case register:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(home);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const RegisterScreen();
            },
          ),
        );

      case phoneAuth:
      case phoneVerification:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated && !state.user!.isAnonymous) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(home);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const PhoneAuthScreen();
            },
          ),
        );

      case forgotPassword:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(home);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const ForgotPasswordScreen();
            },
          ),
        );

      case home:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (!state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(login);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const HomeScreen();
            },
          ),
        );

      case profile:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (!state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(login);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const ProfileScreen();
            },
          ),
        );

      case editProfile:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (!state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(login);
                });
                return const Center(child: CircularProgressIndicator());
              }
              return const EditProfileScreen();
            },
          ),
        );

      // ✅ NOUVELLE ROUTE : Mise à niveau de compte
      case upgradeAccount:
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Vérifier que l'utilisateur est connecté et anonyme
              if (!state.isAuthenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(login);
                });
                return const Center(child: CircularProgressIndicator());
              }

              // Si l'utilisateur n'est pas anonyme, rediriger vers le profil
              if (!state.user!.isAnonymous) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(profile);
                });
                return const Center(child: CircularProgressIndicator());
              }

              return const UpgradeAccountScreen();
            },
          ),
        );

      // ✅ ROUTES À IMPLÉMENTER PLUS TARD
      case linkPhoneNumber:
        return _buildComingSoonRoute(settings, 'Liaison de téléphone');

      case accountSecurity:
        return _buildComingSoonRoute(settings, 'Sécurité du compte');

      case resetPassword:
        return _buildComingSoonRoute(
          settings,
          'Réinitialisation du mot de passe',
        );

      case parametres:
        return _buildComingSoonRoute(settings, 'Paramètres');

      case notifications:
        return _buildComingSoonRoute(settings, 'Notifications');

      case privacy:
        return _buildComingSoonRoute(settings, 'Confidentialité');

      case about:
        return _buildComingSoonRoute(settings, 'À propos');

      default:
        return _buildErrorRoute(settings);
    }
  }

  /// Construire une route standard
  static PageRoute _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Animation de transition personnalisée
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// ✅ NOUVEAU : Construire une route "à venir"
  static PageRoute _buildComingSoonRoute(
    RouteSettings settings,
    String featureName,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder:
          (context) => Scaffold(
            appBar: AppBar(
              title: Text(featureName),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withAlpha(10),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.construction,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bientôt Disponible',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '$featureName sera bientôt disponible. Nous travaillons dur pour vous offrir cette fonctionnalité !',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// Construire une route d'erreur
  static PageRoute _buildErrorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Page non trouvée',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La route "${settings.name}" n\'existe pas.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).pushReplacementNamed(home),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Vérifier si une route est publique
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }

  /// Vérifier si une route est protégée
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }

  /// ✅ NOUVEAU : Vérifier si une route est réservée aux comptes anonymes
  static bool isAnonymousOnlyRoute(String route) {
    return anonymousOnlyRoutes.contains(route);
  }

  /// ✅ NOUVEAU : Vérifier si un utilisateur peut accéder à une route
  static bool canAccessRoute(String route, AuthState authState) {
    // Routes publiques : toujours accessibles
    if (isPublicRoute(route)) return true;

    // Routes protégées : nécessitent une authentification
    if (isProtectedRoute(route) && !authState.isAuthenticated) return false;

    // Routes pour comptes anonymes uniquement
    if (isAnonymousOnlyRoute(route)) {
      return authState.isAuthenticated &&
          (authState.user?.isAnonymous ?? false);
    }

    return true;
  }

  /// ✅ NOUVEAU : Obtenir la route de redirection appropriée
  static String getRedirectRoute(String intendedRoute, AuthState authState) {
    if (!canAccessRoute(intendedRoute, authState)) {
      if (!authState.isAuthenticated) {
        return login;
      } else if (authState.user?.isAnonymous == true &&
          !isAnonymousOnlyRoute(intendedRoute)) {
        return home;
      } else {
        return home;
      }
    }
    return intendedRoute;
  }

  /// Naviguer vers une route
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Naviguer vers une route en remplaçant la route actuelle
  static Future<T?> navigateToReplacement<
    T extends Object?,
    TO extends Object?
  >(BuildContext context, String routeName, {Object? arguments, TO? result}) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Naviguer vers une route en supprimant toutes les routes précédentes
  static Future<T?> navigateToAndClearStack<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Revenir à la route précédente
  static void goBack<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Vérifier si on peut revenir en arrière
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

/// Widget pour gérer la navigation conditionnelle basée sur l'authentification
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String route;

  const AuthGuard({super.key, required this.child, required this.route});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final redirectRoute = AppRoutes.getRedirectRoute(route, state);

        if (redirectRoute != route) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppRoutes.navigateToAndClearStack(context, redirectRoute);
          });
        }
      },
      child: child,
    );
  }
}

/// Extensions utiles pour la navigation
extension NavigationExtensions on BuildContext {
  /// Naviguer vers une route
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return AppRoutes.navigateTo<T>(this, routeName, arguments: arguments);
  }

  /// Naviguer vers une route en remplaçant la route actuelle
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return AppRoutes.navigateToReplacement<T, TO>(
      this,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Naviguer vers une route en supprimant toutes les routes précédentes
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return AppRoutes.navigateToAndClearStack<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  /// Revenir à la route précédente
  void pop<T extends Object?>([T? result]) {
    AppRoutes.goBack<T>(this, result);
  }

  /// Vérifier si on peut revenir en arrière
  bool canPop() {
    return AppRoutes.canGoBack(this);
  }
}

/// Middleware pour intercepter la navigation
class NavigationMiddleware {
  /// ✅ MISE À JOUR : Intercepter la navigation avec état d'authentification complet
  static bool canNavigateTo(String route, AuthState authState) {
    return AppRoutes.canAccessRoute(route, authState);
  }

  /// ✅ MISE À JOUR : Obtenir la route de redirection appropriée
  static String getRedirectRoute(String intendedRoute, AuthState authState) {
    return AppRoutes.getRedirectRoute(intendedRoute, authState);
  }
}

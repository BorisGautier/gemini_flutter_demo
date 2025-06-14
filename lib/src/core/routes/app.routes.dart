import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/views/edit_profile.screen.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/auth/views/profile.screen.dart';
import 'package:kartia/src/modules/auth/views/register.screen.dart';
import 'package:kartia/src/modules/auth/views/phone_auth.screen.dart';
import 'package:kartia/src/modules/auth/views/forgot_password.screen.dart';
import 'package:kartia/src/modules/home/views/home.screen.dart';
import 'package:kartia/src/modules/splash/views/splash.screen.dart';

/// Classe pour gérer les routes de l'application
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneAuth = '/phone-auth';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

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
  ];

  /// Routes qui ne nécessitent pas d'authentification
  static List<String> get publicRoutes => [
    splash,
    login,
    register,
    phoneAuth,
    forgotPassword,
  ];

  /// Routes qui nécessitent une authentification
  static List<String> get protectedRoutes => [home, profile, editProfile];

  /// Générer les routes de l'application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(settings, const SplashScreen());

      case login:
        // Pour les routes d'authentification, on utilise le BlocBuilder pour s'assurer
        // que si l'utilisateur est déjà connecté, on affiche la bonne page
        return _buildRoute(
          settings,
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.isAuthenticated) {
                // Si déjà connecté, rediriger vers l'accueil
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
        final isProtectedRoute = AppRoutes.isProtectedRoute(route);
        final isAuthenticated = state.isAuthenticated;

        // Si l'utilisateur n'est pas connecté et essaie d'accéder à une route protégée
        if (isProtectedRoute && !isAuthenticated) {
          AppRoutes.navigateToAndClearStack(context, AppRoutes.login);
        }
        // Si l'utilisateur est connecté et se trouve sur une route publique
        else if (!isProtectedRoute &&
            isAuthenticated &&
            route != AppRoutes.splash) {
          AppRoutes.navigateToAndClearStack(context, AppRoutes.home);
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
  /// Intercepter la navigation pour vérifier l'authentification
  static bool canNavigateTo(String route, bool isAuthenticated) {
    // Les routes publiques sont toujours accessibles
    if (AppRoutes.isPublicRoute(route)) {
      return true;
    }

    // Les routes protégées nécessitent une authentification
    if (AppRoutes.isProtectedRoute(route)) {
      return isAuthenticated;
    }

    // Par défaut, permettre la navigation
    return true;
  }

  /// Obtenir la route de redirection appropriée
  static String getRedirectRoute(String intendedRoute, bool isAuthenticated) {
    if (!canNavigateTo(intendedRoute, isAuthenticated)) {
      return isAuthenticated ? AppRoutes.home : AppRoutes.login;
    }
    return intendedRoute;
  }
}

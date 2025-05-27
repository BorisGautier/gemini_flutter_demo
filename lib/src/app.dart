// lib/src/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/di/di.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:kartia/src/modules/home/bloc/home_bloc.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';
import 'package:kartia/src/app_navigation_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Widget racine de l'application Kartia
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoC principal de l'application (thème, langue)
        BlocProvider(create: (context) => getIt<AppBloc>()),

        // BLoC de l'écran de splash
        BlocProvider(create: (context) => getIt<SplashBloc>()),

        // BLoC de l'écran d'accueil
        BlocProvider(create: (context) => HomeBloc()),
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

            // Widget principal
            home: const AppNavigationManager(),
          );
        },
      ),
    );
  }
}

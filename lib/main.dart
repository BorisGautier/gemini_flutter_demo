// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/blocobserver.dart';
import 'package:kartia/firebase_options.dart';
import 'package:kartia/src/app.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/utils/configs.util.dart';
import 'package:kartia/src/init.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kartia/src/core/di/di.dart' as di;

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialiser les configurations de l'application
      await AppConfigs.initialize();

      // Initialiser le service de logs
      await LogService().initialize();

      // Initialiser Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebasePerformance.instance;

      // Initialiser le stockage hydraté pour la persistance des BLoCs
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(
          (await getTemporaryDirectory()).path,
        ),
      );

      Bloc.observer = SimpleBlocObserver();
      LogService().info('Application démarrée');

      runApp(
        AppInitializer(
          child: BlocProvider(
            create: (_) => di.getIt<GpsBloc>(),
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stackTrace) {
      LogService().error("Erreur non interceptée", error, stackTrace);
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

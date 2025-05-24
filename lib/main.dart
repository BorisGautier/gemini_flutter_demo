// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:kartia/blocobserver.dart';
import 'package:kartia/firebase_options.dart';
import 'package:kartia/src/app.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/utils/configs.util.dart';
import 'package:kartia/src/init.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialiser les configurations de l'application
      await AppConfigs.initialize();

      // Initialiser le service de logs
      await LogService().initialize();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebasePerformance.instance;

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: HydratedStorageDirectory(
          (await getTemporaryDirectory()).path,
        ),
      );

      Bloc.observer = SimpleBlocObserver();
      LogService().info('Application démarrée');

      runApp(AppInitializer(child: const MyApp()));
    },
    (error, stackTrace) {
      LogService().error("Erreur non interceptée", error, stackTrace);
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

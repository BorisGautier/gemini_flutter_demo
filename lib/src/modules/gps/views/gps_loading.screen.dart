// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';
import 'package:kartia/src/modules/gps/views/gps.screen.dart';

class GpsLoadingScreen extends StatelessWidget {
  const GpsLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GpsBloc, GpsState>(
      builder: (context, gpsState) {
        if (gpsState.isAllGranted) {
          // Toutes les permissions sont accordées, on peut retourner à AppNavigationManager
          // qui va gérer l'authentification
          return const SizedBox.shrink(); // Widget vide, AppNavigationManager va prendre le relais
        }

        // Sinon, afficher l'écran de demande de permissions GPS
        return const GpsScreen();
      },
    );
  }
}

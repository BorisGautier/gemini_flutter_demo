// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/app_navigation_manager.dart';
import 'package:kartia/src/core/di/di.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';
import 'package:kartia/src/modules/gps/views/gps.screen.dart';

class GpsLoadingScreen extends StatelessWidget {
  const GpsLoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GpsBloc, GpsState>(
        builder: (context, state) {
          return state.isAllGranted
              ? BlocProvider<AuthBloc>(
                create: (context) => getIt<AuthBloc>()..add(AuthInitialized()),
                child: const AppNavigationManager(),
              )
              : const GpsScreen();
        },
      ),
    );
  }
}

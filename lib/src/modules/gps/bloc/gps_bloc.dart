// ignore_for_file: avoid_print

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsServiceSubscription;
  LogService logger;

  GpsBloc({required this.logger})
    : super(
        const GpsState(
          isGpsEnabled: false,
          isGpsPermissionGranted: false,
          isLoading: true,
        ),
      ) {
    on<GpsAndPermissionEvent>((event, emit) {
      print(
        '🗺️ GPS Event: GPS=${event.isGpsEnabled}, Permission=${event.isGpsPermissionGranted}',
      );
      emit(
        state.copyWith(
          isGpsEnabled: event.isGpsEnabled,
          isGpsPermissionGranted: event.isGpsPermissionGranted,
          isLoading:
              false, // ✅ AJOUT: Arrêter le loading quand on reçoit un événement
        ),
      );
    });

    // ✅ CORRECTION: Démarrer l'initialisation automatiquement
    _init();
  }

  Future<void> _init() async {
    print('🗺️ GpsInitialisation démarrage...');
    logger.info('GpsInitialisation ');

    try {
      // ✅ CORRECTION: Vérifier d'abord l'état sans demander la permission
      final gpsInitStatus = await Future.wait([
        _checkGpsStatus(),
        _isPermissionGranted(),
      ]);

      print(
        '🗺️ Status initial: GPS=${gpsInitStatus[0]}, Permission=${gpsInitStatus[1]}',
      );

      add(
        GpsAndPermissionEvent(
          isGpsEnabled: gpsInitStatus[0],
          isGpsPermissionGranted: gpsInitStatus[1],
        ),
      );

      logger.info('GpsInitialisation $gpsInitStatus');

      // ✅ CORRECTION: Si la permission n'est pas accordée, la demander après un délai
      if (!gpsInitStatus[1]) {
        print(
          '🗺️ Permission non accordée, demande automatique dans 1 seconde...',
        );
        // Attendre un peu pour que l'UI se stabilise
        await Future.delayed(const Duration(milliseconds: 1000));
        if (!isClosed) {
          await askGpsAccess();
        }
      }
    } catch (e) {
      print('🗺️ Erreur lors de l\'initialisation GPS: $e');
      logger.error('Erreur initialisation GPS', e);
    }
  }

  Future<bool> _isPermissionGranted() async {
    try {
      final isGranted = await Permission.location.isGranted;
      print('🗺️ IsPermissionGranted: $isGranted');
      logger.info('IsPermissionGranted $isGranted');
      return isGranted;
    } catch (e) {
      print('🗺️ Erreur vérification permission: $e');
      return false;
    }
  }

  Future<bool> _checkGpsStatus() async {
    try {
      final isEnable = await Geolocator.isLocationServiceEnabled();

      gpsServiceSubscription = Geolocator.getServiceStatusStream().listen((
        event,
      ) {
        final isEnable = (event.index == 1) ? true : false;
        print('🗺️ GPS Service Status changé: $isEnable');
        add(
          GpsAndPermissionEvent(
            isGpsEnabled: isEnable,
            isGpsPermissionGranted: state.isGpsPermissionGranted,
          ),
        );
      });

      print('🗺️ GpsStatusEnable: $isEnable');
      logger.info('GpsStatusEnable $isEnable');
      return isEnable;
    } catch (e) {
      print('🗺️ Erreur vérification GPS: $e');
      return false;
    }
  }

  Future<void> askGpsAccess() async {
    if (isClosed) return;

    print('🗺️ Demande de permission GPS...');
    logger.info('Demande de permission GPS...');

    try {
      final status = await Permission.location.request();
      print('🗺️ Résultat permission: $status');

      switch (status) {
        case PermissionStatus.granted:
          print('🗺️ Permission GPS accordée');
          logger.info('Permission GPS accordée');
          if (!isClosed) {
            add(
              GpsAndPermissionEvent(
                isGpsEnabled: state.isGpsEnabled,
                isGpsPermissionGranted: true,
              ),
            );
          }
          break;
        case PermissionStatus.denied:
          print('🗺️ Permission GPS refusée');
          logger.info('Permission GPS refusée');
          if (!isClosed) {
            add(
              GpsAndPermissionEvent(
                isGpsEnabled: state.isGpsEnabled,
                isGpsPermissionGranted: false,
              ),
            );
          }
          break;
        case PermissionStatus.restricted:
        case PermissionStatus.limited:
          print('🗺️ Permission GPS restreinte');
          logger.info('Permission GPS restreinte');
          if (!isClosed) {
            add(
              GpsAndPermissionEvent(
                isGpsEnabled: state.isGpsEnabled,
                isGpsPermissionGranted: false,
              ),
            );
          }
          break;
        case PermissionStatus.permanentlyDenied:
          print(
            '🗺️ Permission GPS définitivement refusée - ouverture des paramètres',
          );
          logger.info(
            'Permission GPS définitivement refusée - ouverture des paramètres',
          );
          if (!isClosed) {
            add(
              GpsAndPermissionEvent(
                isGpsEnabled: state.isGpsEnabled,
                isGpsPermissionGranted: false,
              ),
            );
            await openAppSettings();
          }
          break;
        case PermissionStatus.provisional:
          print('🗺️ Permission GPS provisoire');
          logger.info('Permission GPS provisoire');
          break;
      }
    } catch (e) {
      print('🗺️ Erreur lors de la demande de permission: $e');
      logger.error('Erreur demande permission GPS', e);
    }
  }

  @override
  Future<void> close() {
    print('🗺️ Fermeture GpsBloc');
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}

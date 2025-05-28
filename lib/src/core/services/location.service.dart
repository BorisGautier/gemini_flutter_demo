import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Service pour gérer la géolocalisation en temps réel
class LocationService {
  final LogService _logger = LogService();

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastKnownPosition;

  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Minimum 10 mètres de déplacement
  );

  /// Vérifier et demander les permissions de localisation
  Future<bool> checkAndRequestPermissions() async {
    try {
      _logger.info('Vérification des permissions de localisation');

      // Vérifier si le service de localisation est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.warning('Service de localisation désactivé');
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        _logger.info('Demande de permission de localisation');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _logger.warning('Permission de localisation refusée');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.error('Permission de localisation refusée définitivement');
        return false;
      }

      _logger.info('Permissions de localisation accordées');
      return true;
    } catch (e) {
      _logger.error('Erreur lors de la vérification des permissions', e);
      return false;
    }
  }

  /// Obtenir la position actuelle
  Future<UserLocation?> getCurrentLocation() async {
    try {
      _logger.info('Récupération de la position actuelle');

      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        return null;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      _lastKnownPosition = position;

      // Essayer de récupérer l'adresse (optionnel)
      String? address;
      String? city;
      String? country;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          address = '${placemark.street}, ${placemark.locality}';
          city = placemark.locality;
          country = placemark.country;
        }
      } catch (e) {
        _logger.warning('Impossible de récupérer l\'adresse: $e');
      }

      final userLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        timestamp: DateTime.now(),
        address: address,
        city: city,
        country: country,
      );

      _logger.info(
        'Position récupérée: ${position.latitude}, ${position.longitude}',
      );
      return userLocation;
    } catch (e) {
      _logger.error('Erreur lors de la récupération de la position', e);
      return null;
    }
  }

  /// Démarrer le suivi de position en temps réel
  Stream<UserLocation> startLocationTracking() async* {
    _logger.info('Démarrage du suivi de position en temps réel');

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      _logger.error('Impossible de démarrer le suivi sans permissions');
      return;
    }

    yield* Geolocator.getPositionStream(locationSettings: _locationSettings)
        .asyncMap((position) async {
          _lastKnownPosition = position;

          // Récupérer l'adresse de manière asynchrone
          String? address;
          String? city;
          String? country;

          try {
            final placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );

            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              address = '${placemark.street}, ${placemark.locality}';
              city = placemark.locality;
              country = placemark.country;
            }
          } catch (e) {
            _logger.warning('Impossible de récupérer l\'adresse: $e');
          }

          final userLocation = UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            altitude: position.altitude,
            speed: position.speed,
            timestamp: DateTime.now(),
            address: address,
            city: city,
            country: country,
          );

          _logger.debug(
            'Nouvelle position: ${position.latitude}, ${position.longitude}',
          );
          return userLocation;
        })
        .handleError((error) {
          _logger.error('Erreur dans le stream de position', error);
        });
  }

  /// Arrêter le suivi de position
  void stopLocationTracking() {
    _logger.info('Arrêt du suivi de position');
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Calculer la distance entre deux positions
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Obtenir la dernière position connue
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Vérifier si l'utilisateur se déplace
  bool isUserMoving() {
    if (_lastKnownPosition == null) return false;
    return (_lastKnownPosition!.speed) > 1.0; // Plus de 1 m/s
  }

  /// Nettoyer les ressources
  void dispose() {
    stopLocationTracking();
  }
}

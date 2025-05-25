// lib/services/log_service.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:kartia/src/core/utils/configs.util.dart';
import 'package:kartia/src/core/utils/logging.util.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'package:kartia/src/core/utils/logging.util.dart' as logging;

class LogService {
  static LogService? _instance;
  late Logger _logger;
  late String _deviceName;

  // Singleton pattern
  factory LogService() => _instance ??= LogService._internal();

  LogService._internal();

  Future<void> initialize() async {
    // Récupérer les informations sur l'application
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfoPlugin = DeviceInfoPlugin();

    // Récupérer les informations sur l'appareil
    final Map<String, dynamic> deviceData = {};

    // Récupération du nom de l'appareil pour l'identifier
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceData['device'] = androidInfo.model;
      deviceData['os'] = 'Android ${androidInfo.version.release}';
      _deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceData['device'] = iosInfo.model;
      deviceData['os'] = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      _deviceName = iosInfo.model;
    } else {
      _deviceName = 'Unknown';
    }

    // Configuration du logger avec une sortie personnalisée et sans couleurs
    _logger = Logger(
      printer: CustomLogPrinter(
        deviceName: _deviceName,
        methodCount:
            2, // Réduire le nombre de méthodes dans la trace pour plus de clarté
        errorMethodCount: 5,
        lineLength: 100,
        colors:
            false, // Désactiver les couleurs pour éviter les caractères ANSI
        printEmojis: false, // Désactiver les emojis
        printTime: true,
      ),
      output: MultiOutput([
        ConsoleOutput(), // Pour voir les logs en console pendant le développement
        GraylogOutput(
          graylogUrl: AppConfigs.graylogUrl!,
          source: 'flutter-app-${packageInfo.appName}',
          additionalFields: {
            'appVersion': packageInfo.version,
            'buildNumber': packageInfo.buildNumber,
            'deviceName': _deviceName,
            'deviceInfo': deviceData.toString(),
            'packageInfo': packageInfo.toString(),
          },
        ),
      ]),
      // Filtrer les logs selon l'environnement
      filter:
          logging.DevelopmentFilter(), // Changer à ProductionFilter() en production
    );
  }

  // Méthodes pour les différents niveaux de log
  void trace(String message) => _logger.t('[$_deviceName] $message');
  void debug(String message) => _logger.d('[$_deviceName] $message');
  void info(String message) => _logger.i('[$_deviceName] $message');
  void warning(String message) => _logger.w('[$_deviceName] $message');
  void error(String message, [dynamic error, StackTrace? stackTrace]) => _logger
      .e('[$_deviceName] $message', error: error, stackTrace: stackTrace);
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) => _logger
      .f('[$_deviceName] $message', error: error, stackTrace: stackTrace);
}

// Créer une classe de printer personnalisée
class CustomLogPrinter extends LogPrinter {
  final String deviceName;
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;

  CustomLogPrinter({
    required this.deviceName,
    this.methodCount = 2,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
  });

  @override
  List<String> log(LogEvent event) {
    var messageStr = event.message.toString();

    String? timeStr;
    if (printTime) {
      var time = DateTime.now();
      timeStr = '${time.hour}:${time.minute}:${time.second}';
    }

    var prefix = timeStr != null ? '[$timeStr]' : '';

    // Formatter le message pour qu'il soit plus clair
    var lines = <String>[];
    lines.add('$prefix ${_levelString(event.level)} $messageStr');

    // Ajouter l'erreur et la stack trace si disponible
    if (event.error != null) {
      lines.add('ERROR: ${event.error}');
    }

    if (event.stackTrace != null) {
      var stackLines = event.stackTrace.toString().split('\n');
      var count =
          event.level.index >= Level.error.index
              ? errorMethodCount
              : methodCount;
      var stackLimit = count < stackLines.length ? count : stackLines.length;

      for (var i = 0; i < stackLimit; i++) {
        lines.add('STACK: ${stackLines[i]}');
      }
    }

    return lines;
  }

  String _levelString(Level level) {
    switch (level) {
      case Level.trace:
        return '[TRACE]';
      case Level.debug:
        return '[DEBUG]';
      case Level.info:
        return '[INFO]';
      case Level.warning:
        return '[WARN]';
      case Level.error:
        return '[ERROR]';
      case Level.fatal:
        return '[FATAL]';
      default:
        return '[LOG]';
    }
  }
}

// lib/src/core/utils/logging.util.dart

// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:kartia/src/core/utils/configs.util.dart';

/// Output personnalisé pour Graylog
class GraylogOutput extends LogOutput {
  final String graylogUrl;
  final String source;
  final Map<String, dynamic> additionalFields;
  final HttpClient _httpClient = HttpClient();

  GraylogOutput({
    required this.graylogUrl,
    required this.source,
    this.additionalFields = const {},
  });

  @override
  void output(OutputEvent event) {
    if (AppConfigs.graylogUrl == null) {
      // Si Graylog n'est pas configuré, ne rien faire
      return;
    }

    // Envoyer les logs à Graylog en arrière-plan
    _sendToGraylog(event);
  }

  Future<void> _sendToGraylog(OutputEvent event) async {
    try {
      final gelfMessage = _createGelfMessage(event);
      final jsonString = jsonEncode(gelfMessage);

      final uri = Uri.parse(graylogUrl);
      final request = await _httpClient.postUrl(uri);

      request.headers.set('Content-Type', 'application/json');
      request.write(jsonString);

      final response = await request.close();

      // Consommer la réponse pour éviter les fuites mémoire
      await response.drain();
    } catch (e) {
      // En cas d'erreur, afficher dans la console en mode développement
      if (AppConfigs.isDevelopment) {
        debugPrint('Erreur lors de l\'envoi à Graylog: $e');
      }
    }
  }

  Map<String, dynamic> _createGelfMessage(OutputEvent event) {
    final level = event.level;
    final lines = event.lines;
    final message = lines.join('\n');

    return {
      'version': '1.1',
      'host': source,
      'short_message': _truncateMessage(message, 250),
      'full_message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
      'level': _getGelfLevel(level),
      'facility': 'flutter_app',
      '_logger': 'kartia_app',
      '_level_name': level.name,
      '_source': source,
      ...additionalFields.map(
        (key, value) => MapEntry('_$key', value.toString()),
      ),
    };
  }

  int _getGelfLevel(Level level) {
    switch (level) {
      case Level.fatal:
        return 2; // Critical
      case Level.error:
        return 3; // Error
      case Level.warning:
        return 4; // Warning
      case Level.info:
        return 6; // Informational
      case Level.debug:
        return 7; // Debug
      case Level.trace:
        return 7; // Debug
      default:
        return 6; // Informational
    }
  }

  String _truncateMessage(String message, int maxLength) {
    if (message.length <= maxLength) {
      return message;
    }
    return '${message.substring(0, maxLength - 3)}...';
  }
}

/// Filter personnalisé pour le logging en développement
class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // En développement, afficher tous les logs
    if (AppConfigs.isDevelopment) {
      return true;
    }

    // En staging, afficher warnings et plus
    if (AppConfigs.isStaging) {
      return event.level.index >= Level.warning.index;
    }

    // En production, afficher seulement erreurs et plus
    return event.level.index >= Level.error.index;
  }
}

/// Filter personnalisé pour la production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // En production, seulement les erreurs et fatals
    return event.level.index >= Level.error.index;
  }
}

/// Printer personnalisé avec couleurs conditionnelles
class KartiaPrettyPrinter extends PrettyPrinter {
  KartiaPrettyPrinter({
    super.methodCount,
    super.errorMethodCount,
    super.lineLength,
    super.colors,
    super.printEmojis,
    super.printTime,
    super.excludeBox,
    super.noBoxingByDefault,
  });

  @override
  List<String> log(LogEvent event) {
    // Utiliser les couleurs seulement en développement

    return super.log(event);
  }
}

/// Utility class pour la configuration du logging
class LoggingConfig {
  static Logger createLogger({
    String? deviceName,
    String? source,
    Map<String, dynamic>? additionalFields,
  }) {
    final outputs = <LogOutput>[ConsoleOutput()];

    // Ajouter Graylog output si configuré
    if (AppConfigs.graylogUrl != null) {
      outputs.add(
        GraylogOutput(
          graylogUrl: AppConfigs.graylogUrl!,
          source: source ?? 'kartia_app',
          additionalFields: additionalFields ?? {},
        ),
      );
    }

    return Logger(
      printer: KartiaPrettyPrinter(
        methodCount: AppConfigs.isDevelopment ? 2 : 0,
        errorMethodCount: 5,
        lineLength: 120,
        colors: AppConfigs.isDevelopment,
        printEmojis: AppConfigs.isDevelopment,
        printTime: true,
      ),
      output: MultiOutput(outputs),
      filter:
          AppConfigs.isProduction ? ProductionFilter() : DevelopmentFilter(),
    );
  }
}

/// Extensions pour simplifier le logging
extension LoggerExtensions on Logger {
  /// Log avec contexte
  void logWithContext(
    Level level,
    String message, {
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final contextString =
        context != null ? ' | Context: ${jsonEncode(context)}' : '';

    final fullMessage = '$message$contextString';

    switch (level) {
      case Level.trace:
        t(fullMessage);
        break;
      case Level.debug:
        d(fullMessage);
        break;
      case Level.info:
        i(fullMessage);
        break;
      case Level.warning:
        w(fullMessage);
        break;
      case Level.error:
        e(fullMessage, error: error, stackTrace: stackTrace);
        break;
      case Level.fatal:
        f(fullMessage, error: error, stackTrace: stackTrace);
        break;
      case Level.all:
        throw UnimplementedError();
      case Level.verbose:
        throw UnimplementedError();
      case Level.wtf:
        throw UnimplementedError();
      case Level.nothing:
        throw UnimplementedError();
      case Level.off:
        throw UnimplementedError();
    }
  }

  /// Log de performance
  void performance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final metadataString =
        metadata != null ? ' | Metadata: ${jsonEncode(metadata)}' : '';

    i(
      'PERFORMANCE: $operation took ${duration.inMilliseconds}ms$metadataString',
    );
  }

  /// Log d'événement utilisateur
  void userEvent(String event, {Map<String, dynamic>? properties}) {
    final propertiesString =
        properties != null ? ' | Properties: ${jsonEncode(properties)}' : '';

    i('USER_EVENT: $event$propertiesString');
  }

  /// Log d'erreur réseau
  void networkError(String url, int? statusCode, {dynamic error}) {
    e('NETWORK_ERROR: $url (Status: $statusCode)', error: error);
  }

  /// Log de navigation
  void navigation(String from, String to, {Map<String, dynamic>? params}) {
    final paramsString =
        params != null ? ' | Params: ${jsonEncode(params)}' : '';

    i('NAVIGATION: $from -> $to$paramsString');
  }
}

/// Classe pour mesurer les performances
class PerformanceTimer {
  final String operation;
  final Logger logger;
  final Stopwatch _stopwatch;
  final Map<String, dynamic>? metadata;

  PerformanceTimer(this.operation, this.logger, {this.metadata})
    : _stopwatch = Stopwatch()..start();

  /// Arrêter le timer et logger le résultat
  void stop() {
    _stopwatch.stop();
    logger.performance(operation, _stopwatch.elapsed, metadata: metadata);
  }
}

/// Extension pour créer facilement des timers de performance
extension PerformanceLogging on Logger {
  PerformanceTimer startTimer(
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceTimer(operation, this, metadata: metadata);
  }
}

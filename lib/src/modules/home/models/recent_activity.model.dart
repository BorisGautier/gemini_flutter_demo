import 'package:equatable/equatable.dart';

/// Types d'activités récentes
enum ActivityType {
  general,
  serviceUsage,
  search,
  navigation,
  settings,
  error,
  success,
}

class RecentActivity extends Equatable {
  /// Identifiant unique de l'activité
  final String id;

  /// Titre de l'activité
  final String title;

  /// Description de l'activité
  final String description;

  /// Timestamp de l'activité
  final DateTime timestamp;

  /// Code de l'icône
  final String iconCode;

  /// Type d'activité
  final ActivityType type;

  /// Données supplémentaires (JSON)
  final Map<String, dynamic>? metadata;

  /// Service associé
  final String? serviceId;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconCode,
    this.type = ActivityType.general,
    this.metadata,
    this.serviceId,
  });

  /// Crée une copie avec les paramètres modifiés
  RecentActivity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? iconCode,
    ActivityType? type,
    Map<String, dynamic>? metadata,
    String? serviceId,
  }) {
    return RecentActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      serviceId: serviceId ?? this.serviceId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    timestamp,
    iconCode,
    type,
    metadata,
    serviceId,
  ];

  @override
  String toString() => 'RecentActivity { id: $id, title: $title, type: $type }';
}

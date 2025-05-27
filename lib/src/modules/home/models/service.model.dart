import 'package:equatable/equatable.dart';

/// Modèle pour un service
class Service extends Equatable {
  /// Identifiant unique du service
  final String id;

  /// Nom du service
  final String title;

  /// Description détaillée
  final String description;

  /// Code de l'icône Material
  final String iconCode;

  /// Couleurs du gradient
  final List<int> gradientColors;

  /// Statut de disponibilité
  final bool isAvailable;

  /// Catégorie du service
  final String category;

  /// Version du service
  final String version;

  /// Date de dernière mise à jour
  final DateTime? lastUpdated;

  /// Nombre d'utilisations
  final int usageCount;

  /// Note moyenne (0-5)
  final double rating;

  /// Ordre d'affichage
  final int order;

  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.gradientColors,
    this.isAvailable = false,
    this.category = 'general',
    this.version = '1.0.0',
    this.lastUpdated,
    this.usageCount = 0,
    this.rating = 0.0,
    this.order = 0,
  });

  /// Crée une copie avec les paramètres modifiés
  Service copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    List<int>? gradientColors,
    bool? isAvailable,
    String? category,
    String? version,
    DateTime? lastUpdated,
    int? usageCount,
    double? rating,
    int? order,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      gradientColors: gradientColors ?? this.gradientColors,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconCode,
    gradientColors,
    isAvailable,
    category,
    version,
    lastUpdated,
    usageCount,
    rating,
    order,
  ];

  @override
  String toString() =>
      'Service { id: $id, title: $title, category: $category }';
}

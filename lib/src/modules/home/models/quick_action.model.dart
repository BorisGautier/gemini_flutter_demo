import 'package:equatable/equatable.dart';

/// Modèle pour une action rapide
class QuickAction extends Equatable {
  /// Identifiant unique de l'action
  final String id;

  /// Titre affiché
  final String title;

  /// Description courte
  final String description;

  /// Code de l'icône Material (format string pour sérialisation)
  final String iconCode;

  /// Couleurs du gradient [color1, color2]
  final List<int> gradientColors;

  /// Indique si l'action est disponible
  final bool isAvailable;

  /// Catégorie de l'action (optionnel)
  final String? category;

  /// Ordre d'affichage
  final int order;

  const QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.gradientColors,
    this.isAvailable = false,
    this.category,
    this.order = 0,
  });

  /// Crée une copie avec les paramètres modifiés
  QuickAction copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    List<int>? gradientColors,
    bool? isAvailable,
    String? category,
    int? order,
  }) {
    return QuickAction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      gradientColors: gradientColors ?? this.gradientColors,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
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
    order,
  ];

  @override
  String toString() =>
      'QuickAction { id: $id, title: $title, isAvailable: $isAvailable }';
}

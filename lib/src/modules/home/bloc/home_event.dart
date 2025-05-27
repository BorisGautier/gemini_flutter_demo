// lib/src/modules/home/bloc/home_event.dart

import 'package:equatable/equatable.dart';

/// Classe abstraite pour tous les événements du HomeBloc
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Événement d'initialisation de l'écran d'accueil
/// Déclenche le chargement des données initiales
class HomeInitialized extends HomeEvent {
  const HomeInitialized();

  @override
  String toString() => 'HomeInitialized';
}

/// Événement de sélection d'un item dans la navigation bottom
/// [index] : Index de l'onglet sélectionné (0: Home, 1: Services, 2: Settings)
class BottomNavItemSelected extends HomeEvent {
  final int index;

  const BottomNavItemSelected(this.index);

  @override
  List<Object?> get props => [index];

  @override
  String toString() => 'BottomNavItemSelected { index: $index }';
}

/// Événement de tap sur une action rapide
/// [actionId] : Identifiant unique de l'action (ex: 'city_ai_guide', 'sante_map')
class QuickActionTapped extends HomeEvent {
  final String actionId;

  const QuickActionTapped(this.actionId);

  @override
  List<Object?> get props => [actionId];

  @override
  String toString() => 'QuickActionTapped { actionId: $actionId }';
}

/// Événement de tap sur un service
/// [serviceId] : Identifiant unique du service
class ServiceTapped extends HomeEvent {
  final String serviceId;

  const ServiceTapped(this.serviceId);

  @override
  List<Object?> get props => [serviceId];

  @override
  String toString() => 'ServiceTapped { serviceId: $serviceId }';
}

/// Événement de demande de rafraîchissement (pull-to-refresh)
/// Recharge toutes les données de l'écran d'accueil
class RefreshRequested extends HomeEvent {
  const RefreshRequested();

  @override
  String toString() => 'RefreshRequested';
}

/// Événement de chargement des actions rapides
/// Utilisé pour charger/recharger spécifiquement les actions rapides
class LoadQuickActions extends HomeEvent {
  const LoadQuickActions();

  @override
  String toString() => 'LoadQuickActions';
}

/// Événement de chargement des services
/// Utilisé pour charger/recharger spécifiquement les services
class LoadServices extends HomeEvent {
  const LoadServices();

  @override
  String toString() => 'LoadServices';
}

/// Événement de chargement des activités récentes
/// Utilisé pour charger/recharger les activités récentes de l'utilisateur
class LoadRecentActivities extends HomeEvent {
  const LoadRecentActivities();

  @override
  String toString() => 'LoadRecentActivities';
}

/// Événement de recherche dans les services
/// [query] : Terme de recherche
class SearchServices extends HomeEvent {
  final String query;

  const SearchServices(this.query);

  @override
  List<Object?> get props => [query];

  @override
  String toString() => 'SearchServices { query: $query }';
}

/// Événement de filtrage des services par catégorie
/// [category] : Catégorie de service à filtrer
class FilterServicesByCategory extends HomeEvent {
  final String category;

  const FilterServicesByCategory(this.category);

  @override
  List<Object?> get props => [category];

  @override
  String toString() => 'FilterServicesByCategory { category: $category }';
}

/// Événement de mise à jour du statut d'un service
/// [serviceId] : ID du service
/// [isAvailable] : Nouveau statut de disponibilité
class UpdateServiceStatus extends HomeEvent {
  final String serviceId;
  final bool isAvailable;

  const UpdateServiceStatus({
    required this.serviceId,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [serviceId, isAvailable];

  @override
  String toString() =>
      'UpdateServiceStatus { serviceId: $serviceId, isAvailable: $isAvailable }';
}

/// Événement d'ajout d'une nouvelle activité récente
/// [activity] : L'activité à ajouter
class AddRecentActivity extends HomeEvent {
  final String activityId;
  final String title;
  final String description;
  final String iconCode;

  const AddRecentActivity({
    required this.activityId,
    required this.title,
    required this.description,
    required this.iconCode,
  });

  @override
  List<Object?> get props => [activityId, title, description, iconCode];

  @override
  String toString() =>
      'AddRecentActivity { activityId: $activityId, title: $title }';
}

/// Événement de suppression d'une activité récente
/// [activityId] : ID de l'activité à supprimer
class RemoveRecentActivity extends HomeEvent {
  final String activityId;

  const RemoveRecentActivity(this.activityId);

  @override
  List<Object?> get props => [activityId];

  @override
  String toString() => 'RemoveRecentActivity { activityId: $activityId }';
}

/// Événement de nettoyage de toutes les activités récentes
class ClearRecentActivities extends HomeEvent {
  const ClearRecentActivities();

  @override
  String toString() => 'ClearRecentActivities';
}

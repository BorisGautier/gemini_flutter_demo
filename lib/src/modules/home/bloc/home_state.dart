// lib/src/modules/home/bloc/home_state.dart

import 'package:equatable/equatable.dart';
import 'package:kartia/src/modules/home/models/quick_action.model.dart';
import 'package:kartia/src/modules/home/models/recent_activity.model.dart';
import 'package:kartia/src/modules/home/models/service.model.dart';

/// Classe abstraite pour tous les états du HomeBloc
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// État initial du HomeBloc
/// L'écran d'accueil n'a pas encore été initialisé
class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  String toString() => 'HomeInitial';
}

/// État de chargement
/// Affiché pendant le chargement initial des données
class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  String toString() => 'HomeLoading';
}

/// État principal avec toutes les données chargées
class HomeLoaded extends HomeState {
  /// Index de l'onglet sélectionné dans la navigation bottom
  final int selectedTabIndex;

  /// Liste des actions rapides disponibles
  final List<QuickAction> quickActions;

  /// Liste des services disponibles
  final List<Service> services;

  /// Liste des activités récentes de l'utilisateur
  final List<RecentActivity> recentActivities;

  /// Indique si un rafraîchissement est en cours
  final bool isRefreshing;

  /// Terme de recherche actuel pour les services
  final String searchQuery;

  /// Catégorie de filtre sélectionnée
  final String? selectedCategory;

  /// Services filtrés selon la recherche et la catégorie
  final List<Service> filteredServices;

  const HomeLoaded({
    this.selectedTabIndex = 0,
    this.quickActions = const [],
    this.services = const [],
    this.recentActivities = const [],
    this.isRefreshing = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.filteredServices = const [],
  });

  /// Crée une copie de l'état avec les paramètres modifiés
  HomeLoaded copyWith({
    int? selectedTabIndex,
    List<QuickAction>? quickActions,
    List<Service>? services,
    List<RecentActivity>? recentActivities,
    bool? isRefreshing,
    String? searchQuery,
    String? selectedCategory,
    List<Service>? filteredServices,
  }) {
    return HomeLoaded(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      quickActions: quickActions ?? this.quickActions,
      services: services ?? this.services,
      recentActivities: recentActivities ?? this.recentActivities,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filteredServices: filteredServices ?? this.filteredServices,
    );
  }

  @override
  List<Object?> get props => [
    selectedTabIndex,
    quickActions,
    services,
    recentActivities,
    isRefreshing,
    searchQuery,
    selectedCategory,
    filteredServices,
  ];

  @override
  String toString() => '''HomeLoaded {
    selectedTabIndex: $selectedTabIndex,
    quickActions: ${quickActions.length},
    services: ${services.length},
    recentActivities: ${recentActivities.length},
    isRefreshing: $isRefreshing,
    searchQuery: $searchQuery,
    selectedCategory: $selectedCategory,
    filteredServices: ${filteredServices.length}
  }''';
}

/// État d'erreur
/// Affiché quand une erreur survient pendant le chargement
class HomeError extends HomeState {
  /// Message d'erreur à afficher
  final String message;

  /// Code d'erreur optionnel pour le debugging
  final String? errorCode;

  /// Exception originale (pour le debugging)
  final dynamic exception;

  const HomeError({required this.message, this.errorCode, this.exception});

  @override
  List<Object?> get props => [message, errorCode, exception];

  @override
  String toString() => '''HomeError {
    message: $message,
    errorCode: $errorCode,
    exception: $exception
  }''';
}

/// État de chargement partiel
/// Utilisé quand une section spécifique est en cours de chargement
class HomePartialLoading extends HomeState {
  /// État précédent à maintenir
  final HomeLoaded currentState;

  /// Section en cours de chargement
  final LoadingSection section;

  const HomePartialLoading({required this.currentState, required this.section});

  @override
  List<Object?> get props => [currentState, section];

  @override
  String toString() => 'HomePartialLoading { section: $section }';
}

/// Énumération des sections qui peuvent être en chargement
enum LoadingSection { quickActions, services, recentActivities, search, filter }

// lib/src/modules/home/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/modules/home/bloc/home_event.dart';
import 'package:kartia/src/modules/home/bloc/home_state.dart';
import 'package:kartia/src/modules/home/models/quick_action.model.dart';
import 'package:kartia/src/modules/home/models/recent_activity.model.dart';
import 'package:kartia/src/modules/home/models/service.model.dart';

/// BLoC principal pour la gestion de l'écran d'accueil
///
/// Gère les états et événements liés à :
/// - La navigation entre onglets
/// - Le chargement des actions rapides et services
/// - Les activités récentes de l'utilisateur
/// - La recherche et filtrage des services
/// - Le rafraîchissement des données
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    // Enregistrement des handlers d'événements
    on<HomeInitialized>(_onHomeInitialized);
    on<BottomNavItemSelected>(_onBottomNavItemSelected);
    on<QuickActionTapped>(_onQuickActionTapped);
    on<ServiceTapped>(_onServiceTapped);
    on<RefreshRequested>(_onRefreshRequested);
    on<LoadQuickActions>(_onLoadQuickActions);
    on<LoadServices>(_onLoadServices);
    on<LoadRecentActivities>(_onLoadRecentActivities);
    on<SearchServices>(_onSearchServices);
    on<FilterServicesByCategory>(_onFilterServicesByCategory);
    on<UpdateServiceStatus>(_onUpdateServiceStatus);
    on<AddRecentActivity>(_onAddRecentActivity);
    on<RemoveRecentActivity>(_onRemoveRecentActivity);
    on<ClearRecentActivities>(_onClearRecentActivities);
  }

  /// Handler pour l'initialisation de l'écran d'accueil
  Future<void> _onHomeInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Simuler le chargement des données initiales
      await Future.delayed(const Duration(milliseconds: 800));

      final quickActions = _getQuickActions();
      final services = _getServices();
      final recentActivities = _getRecentActivities();

      emit(
        HomeLoaded(
          quickActions: quickActions,
          services: services,
          recentActivities: recentActivities,
          filteredServices:
              services, // Initialement, tous les services sont affichés
        ),
      );
    } catch (e) {
      emit(
        HomeError(
          message: 'Erreur lors du chargement des données',
          exception: e,
        ),
      );
    }
  }

  /// Handler pour la sélection d'un onglet de navigation
  void _onBottomNavItemSelected(
    BottomNavItemSelected event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(selectedTabIndex: event.index));
    }
  }

  /// Handler pour le tap sur une action rapide
  void _onQuickActionTapped(QuickActionTapped event, Emitter<HomeState> emit) {
    // Ajouter l'action à l'historique des activités récentes
    add(
      AddRecentActivity(
        activityId:
            'quick_action_${event.actionId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Action rapide utilisée',
        description: 'Vous avez utilisé l\'action ${event.actionId}',
        iconCode: '0xe5d2', // Icons.touch_app
      ),
    );

    // Ici, vous pourriez naviguer vers le service correspondant
    // ou déclencher d'autres actions selon votre logique métier
  }

  /// Handler pour le tap sur un service
  void _onServiceTapped(ServiceTapped event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // Mettre à jour le compteur d'utilisation du service
      final updatedServices =
          currentState.services.map((service) {
            if (service.id == event.serviceId) {
              return service.copyWith(usageCount: service.usageCount + 1);
            }
            return service;
          }).toList();

      // Ajouter à l'historique
      final service = updatedServices.firstWhere(
        (s) => s.id == event.serviceId,
      );
      add(
        AddRecentActivity(
          activityId:
              'service_${event.serviceId}_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Service utilisé',
          description: 'Vous avez accédé à ${service.title}',
          iconCode: service.iconCode,
        ),
      );

      emit(currentState.copyWith(services: updatedServices));
    }
  }

  /// Handler pour le rafraîchissement des données
  Future<void> _onRefreshRequested(
    RefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      try {
        // Simuler le rechargement des données
        await Future.delayed(const Duration(seconds: 1));

        final quickActions = _getQuickActions();
        final services = _getServices();
        final recentActivities = _getRecentActivities();

        emit(
          currentState.copyWith(
            quickActions: quickActions,
            services: services,
            recentActivities: recentActivities,
            filteredServices: _filterServices(
              services,
              currentState.searchQuery,
              currentState.selectedCategory,
            ),
            isRefreshing: false,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isRefreshing: false));
        emit(
          HomeError(message: 'Erreur lors du rafraîchissement', exception: e),
        );
      }
    }
  }

  /// Handler pour le chargement des actions rapides
  Future<void> _onLoadQuickActions(
    LoadQuickActions event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomePartialLoading(
          currentState: currentState,
          section: LoadingSection.quickActions,
        ),
      );

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final quickActions = _getQuickActions();

        emit(currentState.copyWith(quickActions: quickActions));
      } catch (e) {
        emit(
          HomeError(
            message: 'Erreur lors du chargement des actions rapides',
            exception: e,
          ),
        );
      }
    }
  }

  /// Handler pour le chargement des services
  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomePartialLoading(
          currentState: currentState,
          section: LoadingSection.services,
        ),
      );

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final services = _getServices();

        emit(
          currentState.copyWith(
            services: services,
            filteredServices: _filterServices(
              services,
              currentState.searchQuery,
              currentState.selectedCategory,
            ),
          ),
        );
      } catch (e) {
        emit(
          HomeError(
            message: 'Erreur lors du chargement des services',
            exception: e,
          ),
        );
      }
    }
  }

  /// Handler pour le chargement des activités récentes
  Future<void> _onLoadRecentActivities(
    LoadRecentActivities event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(
        HomePartialLoading(
          currentState: currentState,
          section: LoadingSection.recentActivities,
        ),
      );

      try {
        await Future.delayed(const Duration(milliseconds: 300));
        final recentActivities = _getRecentActivities();

        emit(currentState.copyWith(recentActivities: recentActivities));
      } catch (e) {
        emit(
          HomeError(
            message: 'Erreur lors du chargement des activités récentes',
            exception: e,
          ),
        );
      }
    }
  }

  /// Handler pour la recherche de services
  void _onSearchServices(SearchServices event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredServices = _filterServices(
        currentState.services,
        event.query,
        currentState.selectedCategory,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredServices: filteredServices,
        ),
      );
    }
  }

  /// Handler pour le filtrage par catégorie
  void _onFilterServicesByCategory(
    FilterServicesByCategory event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final filteredServices = _filterServices(
        currentState.services,
        currentState.searchQuery,
        event.category,
      );

      emit(
        currentState.copyWith(
          selectedCategory: event.category,
          filteredServices: filteredServices,
        ),
      );
    }
  }

  /// Handler pour la mise à jour du statut d'un service
  void _onUpdateServiceStatus(
    UpdateServiceStatus event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedServices =
          currentState.services.map((service) {
            if (service.id == event.serviceId) {
              return service.copyWith(isAvailable: event.isAvailable);
            }
            return service;
          }).toList();

      final filteredServices = _filterServices(
        updatedServices,
        currentState.searchQuery,
        currentState.selectedCategory,
      );

      emit(
        currentState.copyWith(
          services: updatedServices,
          filteredServices: filteredServices,
        ),
      );
    }
  }

  /// Handler pour l'ajout d'une activité récente
  void _onAddRecentActivity(AddRecentActivity event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newActivity = RecentActivity(
        id: event.activityId,
        title: event.title,
        description: event.description,
        timestamp: DateTime.now(),
        iconCode: event.iconCode,
        type: ActivityType.serviceUsage,
      );

      final updatedActivities =
          [newActivity, ...currentState.recentActivities]
              .take(10) // Limiter à 10 activités récentes
              .toList();

      emit(currentState.copyWith(recentActivities: updatedActivities));
    }
  }

  /// Handler pour la suppression d'une activité récente
  void _onRemoveRecentActivity(
    RemoveRecentActivity event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final updatedActivities =
          currentState.recentActivities
              .where((activity) => activity.id != event.activityId)
              .toList();

      emit(currentState.copyWith(recentActivities: updatedActivities));
    }
  }

  /// Handler pour le nettoyage de toutes les activités récentes
  void _onClearRecentActivities(
    ClearRecentActivities event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(recentActivities: []));
    }
  }

  // ============================================================================
  // MÉTHODES PRIVÉES POUR LA GÉNÉRATION DES DONNÉES
  // ============================================================================

  /// Génère la liste des actions rapides avec les couleurs Kartia
  List<QuickAction> _getQuickActions() {
    return [
      QuickAction(
        id: 'city_ai_guide',
        title: 'City AI Guide',
        description: 'Guide intelligent de la ville',
        iconCode: '0xe3d2', // Icons.map_rounded
        gradientColors: [
          AppColors.cityAiGuideModuleColor.toARGB32(),
          AppColors.info.toARGB32(),
        ],
        category: 'navigation',
        order: 1,
      ),
      QuickAction(
        id: 'sante_map',
        title: 'SantéMap',
        description: 'Carte des services de santé',
        iconCode: '0xe59c', // Icons.health_and_safety_rounded
        gradientColors: [
          AppColors.santeMapModuleColor.toARGB32(),
          AppColors.primary.toARGB32(),
        ],
        category: 'health',
        order: 2,
      ),
      QuickAction(
        id: 'civact',
        title: 'CivAct',
        description: 'Engagement citoyen actif',
        iconCode: '0xe02c', // Icons.volunteer_activism_rounded
        gradientColors: [
          AppColors.civactModuleColor.toARGB32(),
          AppColors.warning.toARGB32(),
        ],
        category: 'civic',
        order: 3,
      ),
      QuickAction(
        id: 'carto_prix',
        title: 'CartoPrix',
        description: 'Comparateur de prix local',
        iconCode: '0xe59c', // Icons.shopping_cart_rounded
        gradientColors: [
          AppColors.cartoPrixModuleColor.toARGB32(),
          AppColors.primaryOrange.toARGB32(),
        ],
        category: 'shopping',
        order: 4,
      ),
    ];
  }

  /// Génère la liste des services avec descriptions détaillées
  List<Service> _getServices() {
    return [
      Service(
        id: 'city_ai_guide',
        title: 'City AI Guide',
        description:
            'Votre guide intelligent pour découvrir et naviguer dans la ville avec des recommandations personnalisées basées sur l\'IA.',
        iconCode: '0xe3d2', // Icons.map_rounded
        gradientColors: [
          AppColors.cityAiGuideModuleColor.toARGB32(),
          AppColors.info.toARGB32(),
        ],
        category: 'navigation',
        version: '2.1.0',
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        usageCount: 245,
        rating: 4.5,
        order: 1,
      ),
      Service(
        id: 'sante_map',
        title: 'SantéMap',
        description:
            'Trouvez rapidement les centres de santé, hôpitaux et pharmacies les plus proches avec informations en temps réel.',
        iconCode: '0xe59c', // Icons.health_and_safety_rounded
        gradientColors: [
          AppColors.santeMapModuleColor.toARGB32(),
          AppColors.primary.toARGB32(),
        ],
        category: 'health',
        version: '1.8.3',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        usageCount: 892,
        rating: 4.8,
        order: 2,
      ),
      Service(
        id: 'civact',
        title: 'CivAct',
        description:
            'Participez activement à la vie de votre communauté en signalant les problèmes et en proposant des solutions.',
        iconCode: '0xe02c', // Icons.volunteer_activism_rounded
        gradientColors: [
          AppColors.civactModuleColor.toARGB32(),
          AppColors.warning.toARGB32(),
        ],
        category: 'civic',
        version: '1.5.2',
        lastUpdated: DateTime.now().subtract(const Duration(days: 12)),
        usageCount: 156,
        rating: 4.2,
        order: 3,
      ),
      Service(
        id: 'carto_prix',
        title: 'CartoPrix',
        description:
            'Comparez les prix des produits dans votre région et trouvez les meilleures offres près de chez vous.',
        iconCode: '0xe59c', // Icons.shopping_cart_rounded
        gradientColors: [
          AppColors.cartoPrixModuleColor.toARGB32(),
          AppColors.primaryOrange.toARGB32(),
        ],
        category: 'shopping',
        version: '3.0.1',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        usageCount: 1023,
        rating: 4.6,
        order: 4,
      ),
    ];
  }

  /// Génère la liste des activités récentes (vide par défaut)
  /// Dans une vraie app, cela viendrait d'une base de données ou d'une API
  List<RecentActivity> _getRecentActivities() {
    // Pour l'instant, retourne une liste vide
    // Dans une implémentation réelle, vous récupéreriez les données depuis :
    // - Une base de données locale (SQLite, Hive, etc.)
    // - Une API REST
    // - Un cache local
    return [];

    // Exemple de données factices pour le développement :
    /*
    return [
      RecentActivity(
        id: 'activity_1',
        title: 'Recherche pharmacie',
        description: 'Vous avez recherché une pharmacie dans SantéMap',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        iconCode: '0xe59c', // Icons.health_and_safety_rounded
        type: ActivityType.serviceUsage,
        serviceId: 'sante_map',
      ),
      RecentActivity(
        id: 'activity_2',
        title: 'Navigation vers centre-ville',
        description: 'Itinéraire calculé avec City AI Guide',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        iconCode: '0xe3d2', // Icons.map_rounded
        type: ActivityType.navigation,
        serviceId: 'city_ai_guide',
      ),
    ];
    */
  }

  /// Filtre les services selon la recherche et la catégorie
  List<Service> _filterServices(
    List<Service> services,
    String searchQuery,
    String? selectedCategory,
  ) {
    var filteredServices = services;

    // Filtrage par catégorie
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filteredServices =
          filteredServices
              .where((service) => service.category == selectedCategory)
              .toList();
    }

    // Filtrage par recherche textuelle
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredServices =
          filteredServices.where((service) {
            return service.title.toLowerCase().contains(query) ||
                service.description.toLowerCase().contains(query) ||
                service.category.toLowerCase().contains(query);
          }).toList();
    }

    // Tri par ordre puis par popularité (usage count)
    filteredServices.sort((a, b) {
      final orderComparison = a.order.compareTo(b.order);
      if (orderComparison != 0) return orderComparison;
      return b.usageCount.compareTo(a.usageCount);
    });

    return filteredServices;
  }

  /// Obtient les catégories disponibles des services
  List<String> getAvailableCategories() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      return currentState.services
          .map((service) => service.category)
          .toSet()
          .toList()
        ..sort();
    }
    return [];
  }

  /// Obtient les statistiques d'utilisation des services
  Map<String, int> getUsageStatistics() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final stats = <String, int>{};

      for (final service in currentState.services) {
        stats[service.id] = service.usageCount;
      }

      return stats;
    }
    return {};
  }

  /// Obtient le service le plus populaire
  Service? getMostPopularService() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.services.isEmpty) return null;

      return currentState.services.reduce(
        (a, b) => a.usageCount > b.usageCount ? a : b,
      );
    }
    return null;
  }

  /// Vérifie si un service est disponible
  bool isServiceAvailable(String serviceId) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final service =
          currentState.services.where((s) => s.id == serviceId).firstOrNull;
      return service?.isAvailable ?? false;
    }
    return false;
  }
}

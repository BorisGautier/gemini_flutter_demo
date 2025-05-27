// lib/src/modules/splash/bloc/splash_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/services/log.service.dart';
import 'package:kartia/src/core/di/di.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// BLoC pour gérer l'écran de splash
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final LogService _logger = LogService();
  Timer? _animationTimer;
  Timer? _initializationTimer;

  SplashBloc() : super(SplashState.initial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationPhaseChanged>(_onAnimationPhaseChanged);
    on<SplashInitializationCompleted>(_onInitializationCompleted);
    on<SplashNavigateToNextScreen>(_onNavigateToNextScreen);
  }

  /// Démarrer le splash
  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    _logger.info('SplashBloc: Démarrage du splash');

    emit(
      state.copyWith(
        isLoading: true,
        animationPhase: SplashAnimationPhase.initial,
        isInitialized: false,
        shouldNavigate: false,
      ),
    );

    // Démarrer les animations avec des délais plus longs
    _startAnimationSequence();

    // Démarrer l'initialisation en parallèle
    _startInitialization();
  }

  /// Changer la phase d'animation
  void _onAnimationPhaseChanged(
    SplashAnimationPhaseChanged event,
    Emitter<SplashState> emit,
  ) {
    _logger.info('SplashBloc: Phase d\'animation changée: ${event.phase}');

    emit(
      state.copyWith(
        animationPhase: event.phase,
        backgroundProgress: _getBackgroundProgress(event.phase),
      ),
    );

    // ✅ CORRECTION: Attendre plus longtemps avant d'autoriser la navigation
    if (event.phase == SplashAnimationPhase.completed && state.isInitialized) {
      // Attendre 2 secondes supplémentaires après la fin des animations
      Timer(const Duration(milliseconds: 2000), () {
        if (!isClosed) {
          _logger.info(
            'SplashBloc: Délai supplémentaire écoulé, navigation autorisée',
          );
          emit(state.copyWith(shouldNavigate: true, isLoading: false));
        }
      });
    }
  }

  /// Initialisation terminée
  void _onInitializationCompleted(
    SplashInitializationCompleted event,
    Emitter<SplashState> emit,
  ) {
    _logger.info(
      'SplashBloc: Initialisation terminée avec succès: ${event.success}',
    );

    if (event.success) {
      emit(state.copyWith(isInitialized: true, initializationError: null));

      // ✅ CORRECTION: Si les animations sont terminées aussi, attendre avant navigation
      if (state.animationPhase == SplashAnimationPhase.completed) {
        Timer(const Duration(milliseconds: 2000), () {
          if (!isClosed) {
            _logger.info(
              'SplashBloc: Délai supplémentaire écoulé après initialisation, navigation autorisée',
            );
            emit(state.copyWith(shouldNavigate: true, isLoading: false));
          }
        });
      }
    } else {
      emit(
        state.copyWith(
          isInitialized: false,
          initializationError: 'Erreur d\'initialisation',
          isLoading: false,
        ),
      );
    }
  }

  /// Naviguer vers l'écran suivant
  void _onNavigateToNextScreen(
    SplashNavigateToNextScreen event,
    Emitter<SplashState> emit,
  ) {
    _logger.info('SplashBloc: Navigation vers l\'écran suivant demandée');

    emit(state.copyWith(shouldNavigate: true, isLoading: false));
  }

  /// Démarrer la séquence d'animations avec des délais plus longs
  void _startAnimationSequence() {
    // ✅ CORRECTION: Délais plus longs pour les animations

    // Phase 1: Démarrer l'animation du logo après 800ms
    Timer(const Duration(milliseconds: 800), () {
      if (!isClosed) {
        add(
          const SplashAnimationPhaseChanged(SplashAnimationPhase.logoStarted),
        );
      }
    });

    // Phase 2: Démarrer l'animation du texte après 2000ms
    Timer(const Duration(milliseconds: 2000), () {
      if (!isClosed) {
        add(
          const SplashAnimationPhaseChanged(SplashAnimationPhase.textStarted),
        );
      }
    });

    // Phase 3: Animation terminée après 4500ms (au lieu de 3000ms)
    _animationTimer = Timer(const Duration(milliseconds: 4500), () {
      if (!isClosed) {
        _logger.info('SplashBloc: Animations terminées');
        add(const SplashAnimationPhaseChanged(SplashAnimationPhase.completed));
      }
    });
  }

  /// Démarrer l'initialisation de l'application avec un délai plus long
  void _startInitialization() {
    // ✅ CORRECTION: Délai plus long pour l'initialisation (3 secondes au lieu de 2)
    _initializationTimer = Timer(const Duration(milliseconds: 3000), () async {
      if (isClosed) return;

      try {
        _logger.info('SplashBloc: Début de l\'initialisation');

        // Vérifier que le DI est bien initialisé
        bool success = DIManager.isInitialized;

        if (!success) {
          _logger.info('SplashBloc: Initialisation du DI...');
          success = await DIManager.safeInit();
        }

        // ✅ CORRECTION: Simuler d'autres initialisations plus longues
        if (success) {
          // Simuler d'autres initialisations (base de données, permissions, etc.)
          await Future.delayed(const Duration(milliseconds: 1500)); // Plus long
          _logger.info('SplashBloc: Initialisation de l\'application réussie');
        } else {
          _logger.error('SplashBloc: Échec de l\'initialisation du DI');
        }

        if (!isClosed) {
          add(SplashInitializationCompleted(success));
        }
      } catch (e) {
        _logger.error('SplashBloc: Erreur lors de l\'initialisation', e);
        if (!isClosed) {
          add(const SplashInitializationCompleted(false));
        }
      }
    });
  }

  /// Calculer le progrès du fond d'écran basé sur la phase d'animation
  double _getBackgroundProgress(SplashAnimationPhase phase) {
    switch (phase) {
      case SplashAnimationPhase.initial:
        return 0.0;
      case SplashAnimationPhase.logoStarted:
        return 0.3;
      case SplashAnimationPhase.textStarted:
        return 0.6;
      case SplashAnimationPhase.completed:
        return 1.0;
    }
  }

  @override
  Future<void> close() {
    _animationTimer?.cancel();
    _initializationTimer?.cancel();
    return super.close();
  }
}

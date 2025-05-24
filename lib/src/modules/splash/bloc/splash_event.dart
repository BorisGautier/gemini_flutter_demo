// lib/src/modules/splash/bloc/splash_event.dart

part of 'splash_bloc.dart';

/// Classe abstraite pour tous les événements du splash
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour démarrer le splash
class SplashStarted extends SplashEvent {
  const SplashStarted();

  @override
  String toString() => 'SplashStarted';
}

/// Événement pour changer la phase d'animation
class SplashAnimationPhaseChanged extends SplashEvent {
  final SplashAnimationPhase phase;

  const SplashAnimationPhaseChanged(this.phase);

  @override
  List<Object> get props => [phase];

  @override
  String toString() => 'SplashAnimationPhaseChanged { phase: $phase }';
}

/// Événement pour indiquer que l'initialisation est terminée
class SplashInitializationCompleted extends SplashEvent {
  final bool success;

  const SplashInitializationCompleted(this.success);

  @override
  List<Object> get props => [success];

  @override
  String toString() => 'SplashInitializationCompleted { success: $success }';
}

/// Événement pour naviguer vers l'écran suivant
class SplashNavigateToNextScreen extends SplashEvent {
  const SplashNavigateToNextScreen();

  @override
  String toString() => 'SplashNavigateToNextScreen';
}

// lib/src/modules/splash/bloc/splash_state.dart

part of 'splash_bloc.dart';

/// Énumération pour les phases d'animation du splash
enum SplashAnimationPhase {
  /// Phase initiale
  initial,

  /// Animation du logo démarrée
  logoStarted,

  /// Animation du texte démarrée
  textStarted,

  /// Animations terminées
  completed,
}

/// État du splash
class SplashState extends Equatable {
  /// Indique si le splash est en cours de chargement
  final bool isLoading;

  /// Indique si l'initialisation est terminée
  final bool isInitialized;

  /// Phase actuelle de l'animation
  final SplashAnimationPhase animationPhase;

  /// Progrès du fond d'écran (0.0 à 1.0)
  final double backgroundProgress;

  /// Indique s'il faut naviguer vers l'écran suivant
  final bool shouldNavigate;

  /// Message d'erreur d'initialisation
  final String? initializationError;

  const SplashState({
    required this.isLoading,
    required this.isInitialized,
    required this.animationPhase,
    required this.backgroundProgress,
    required this.shouldNavigate,
    this.initializationError,
  });

  /// État initial du splash
  factory SplashState.initial() {
    return const SplashState(
      isLoading: false,
      isInitialized: false,
      animationPhase: SplashAnimationPhase.initial,
      backgroundProgress: 0.0,
      shouldNavigate: false,
      initializationError: null,
    );
  }

  /// Créer une copie de l'état avec des modifications
  SplashState copyWith({
    bool? isLoading,
    bool? isInitialized,
    SplashAnimationPhase? animationPhase,
    double? backgroundProgress,
    bool? shouldNavigate,
    String? initializationError,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      animationPhase: animationPhase ?? this.animationPhase,
      backgroundProgress: backgroundProgress ?? this.backgroundProgress,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
      initializationError: initializationError ?? this.initializationError,
    );
  }

  /// Vérifier si le splash est prêt à naviguer
  bool get isReadyToNavigate =>
      isInitialized &&
      animationPhase == SplashAnimationPhase.completed &&
      shouldNavigate;

  /// Vérifier s'il y a une erreur d'initialisation
  bool get hasInitializationError =>
      initializationError != null && initializationError!.isNotEmpty;

  @override
  List<Object?> get props => [
    isLoading,
    isInitialized,
    animationPhase,
    backgroundProgress,
    shouldNavigate,
    initializationError,
  ];

  @override
  String toString() {
    return 'SplashState { '
        'isLoading: $isLoading, '
        'isInitialized: $isInitialized, '
        'animationPhase: $animationPhase, '
        'backgroundProgress: $backgroundProgress, '
        'shouldNavigate: $shouldNavigate, '
        'initializationError: $initializationError '
        '}';
  }
}

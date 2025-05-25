part of 'splash_bloc.dart';

/// Énumération pour les phases d'animation
enum SplashAnimationPhase {
  /// Phase initiale
  initial,

  /// Animation du logo démarrée
  logoStarted,

  /// Animation du texte démarrée
  textStarted,

  /// Toutes les animations terminées
  completed,
}

/// État du splash screen
class SplashState extends Equatable {
  /// Phase d'animation actuelle
  final SplashAnimationPhase animationPhase;

  /// Indique si l'initialisation est en cours
  final bool isLoading;

  /// Indique si l'initialisation est terminée avec succès
  final bool isInitialized;

  /// Message d'erreur en cas d'échec d'initialisation
  final String? initializationError;

  /// Progrès du fond d'écran (0.0 à 1.0)
  final double backgroundProgress;

  /// Indique si on doit naviguer vers l'écran suivant
  final bool shouldNavigate;

  const SplashState({
    this.animationPhase = SplashAnimationPhase.initial,
    this.isLoading = false,
    this.isInitialized = false,
    this.initializationError,
    this.backgroundProgress = 0.0,
    this.shouldNavigate = false,
  });

  /// État initial
  factory SplashState.initial() {
    return const SplashState(
      animationPhase: SplashAnimationPhase.initial,
      isLoading: true,
      isInitialized: false,
      initializationError: null,
      backgroundProgress: 0.0,
      shouldNavigate: false,
    );
  }

  /// Créer une copie avec des modifications
  SplashState copyWith({
    SplashAnimationPhase? animationPhase,
    bool? isLoading,
    bool? isInitialized,
    String? initializationError,
    double? backgroundProgress,
    bool? shouldNavigate,
  }) {
    return SplashState(
      animationPhase: animationPhase ?? this.animationPhase,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      initializationError: initializationError ?? this.initializationError,
      backgroundProgress: backgroundProgress ?? this.backgroundProgress,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
    );
  }

  /// Vérifier s'il y a une erreur d'initialisation
  bool get hasInitializationError => initializationError != null;

  /// Vérifier si on est prêt à naviguer
  bool get isReadyToNavigate =>
      isInitialized &&
      animationPhase == SplashAnimationPhase.completed &&
      !isLoading;

  @override
  List<Object?> get props => [
    animationPhase,
    isLoading,
    isInitialized,
    initializationError,
    backgroundProgress,
    shouldNavigate,
  ];

  @override
  String toString() {
    return 'SplashState { '
        'animationPhase: $animationPhase, '
        'isLoading: $isLoading, '
        'isInitialized: $isInitialized, '
        'initializationError: $initializationError, '
        'backgroundProgress: $backgroundProgress, '
        'shouldNavigate: $shouldNavigate '
        '}';
  }
}

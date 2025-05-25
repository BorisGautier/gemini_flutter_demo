// lib/src/modules/splash/views/splash.screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';
import 'package:kartia/src/modules/auth/views/login.screen.dart';
import 'package:kartia/src/modules/home/views/home.screen.dart';

/// Écran de splash moderne et animé avec navigation directe
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(const SplashStarted()),
      child: const SplashView(),
    );
  }
}

/// Vue principale du splash avec navigation directe intégrée
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _masterController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particlesController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  late AnimationController _pulseController;

  // Animations du logo
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoRotation;
  late Animation<Offset> _logoSlide;
  late Animation<double> _logoPulse;

  // Animations du texte
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textScale;

  // Animations de fond
  late Animation<double> _backgroundGradient;
  late Animation<double> _shimmerPosition;

  // Animations des particules
  late Animation<double> _particlesOpacity;

  // Animation de progression
  late Animation<double> _progressValue;

  // Navigation
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startNavigationTimer(); // TIMER DE NAVIGATION DIRECT
  }

  void _startNavigationTimer() {
    // Navigation forcée après 3.5 secondes, peu importe l'état du bloc
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted && !_hasNavigated) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (_hasNavigated) return;

    setState(() {
      _hasNavigated = true;
    });

    // Récupérer l'état d'authentification
    final authState = context.read<AuthBloc>().state;

    if (authState.isAuthenticated) {
      // Naviguer vers Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthBloc>()),
                ],
                child: const HomeScreen(),
              ),
        ),
        (route) => false,
      );
    } else {
      // Naviguer vers Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthBloc>()),
                ],
                child: const LoginScreen(),
              ),
        ),
        (route) => false,
      );
    }
  }

  void _initializeAnimations() {
    // Contrôleur principal (durée totale)
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Contrôleur pour le logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Contrôleur pour le texte
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Contrôleur pour les particules
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Contrôleur pour le shimmer
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Contrôleur pour la progression
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Contrôleur pour l'effet de pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    // === ANIMATIONS DU LOGO ===
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _logoPulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // === ANIMATIONS DU TEXTE ===
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // === ANIMATIONS DE FOND ===
    _backgroundGradient = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _masterController, curve: Curves.easeInOut),
    );

    _shimmerPosition = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // === ANIMATIONS DES PARTICULES ===
    _particlesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particlesController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    // === ANIMATION DE PROGRESSION ===
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    // Démarrer les animations en cascade
    _masterController.forward();
    _particlesController.repeat();
    _shimmerController.repeat();
    _progressController.forward();

    // Logo après 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _logoController.forward();
        _pulseController.repeat(reverse: true);
      }
    });

    // Texte après 900ms
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particlesController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.animationPhase == SplashAnimationPhase.logoStarted) {
            _startAnimations();
          }

          if (state.hasInitializationError) {
            _showErrorDialog(context, l10n, state.initializationError!);
          }

          // Navigation anticipée si le bloc est prêt avant le timer
          if (state.isReadyToNavigate && !_hasNavigated) {
            _navigateToNextScreen();
          }
        },
        child: BlocBuilder<SplashBloc, SplashState>(
          builder: (context, state) {
            return AnimatedBuilder(
              animation: _masterController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: _buildGradientBackground(),
                  child: Stack(
                    children: [
                      // Particules de fond
                      _buildParticles(),

                      // Contenu principal
                      _buildMainContent(l10n, state),

                      // Indicateur de progression
                      _buildProgressIndicator(l10n, state),

                      // Effet shimmer
                      _buildShimmerEffect(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    final progress = _backgroundGradient.value;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            AppColors.primary.withAlpha(15),
            AppColors.primary.withAlpha(40),
            progress,
          )!,
          Color.lerp(
            AppColors.secondary.withAlpha(8),
            AppColors.secondary.withAlpha(25),
            progress,
          )!,
          Color.lerp(
            AppColors.primaryPurple.withAlpha(5),
            AppColors.primaryPurple.withAlpha(15),
            progress,
          )!,
          Colors.white,
        ],
        stops: [0.0, 0.3 + (progress * 0.2), 0.6 + (progress * 0.1), 1.0],
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return Opacity(
          opacity: _particlesOpacity.value,
          child: CustomPaint(
            size: Size.infinite,
            painter: ParticlesPainter(
              animationValue: _particlesController.value,
              particleCount: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(KartiaLocalizations l10n, SplashState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Logo animé avec effets améliorés
          _buildAnimatedLogo(),

          SizedBox(height: heightSpace.height! * 3),

          // Texte animé
          _buildAnimatedText(l10n),

          const Spacer(flex: 1),

          // Informations de version
          _buildVersionInfo(l10n),

          SizedBox(height: heightSpace.height! * 2),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseController]),
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlide,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Transform.scale(
              scale: _logoScale.value * _logoPulse.value,
              child: FadeTransition(
                opacity: _logoFade,
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.white.withAlpha(95)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 50 * _logoFade.value,
                          spreadRadius: 15 * _logoFade.value,
                          offset: Offset(0, 15 * _logoFade.value),
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(30),
                          blurRadius: 80 * _logoFade.value,
                          spreadRadius: 25 * _logoFade.value,
                          offset: Offset(0, 25 * _logoFade.value),
                        ),
                        BoxShadow(
                          color: AppColors.primaryPurple.withAlpha(20),
                          blurRadius: 100 * _logoFade.value,
                          spreadRadius: 30 * _logoFade.value,
                          offset: Offset(0, 30 * _logoFade.value),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(KartiaLocalizations l10n) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: Transform.scale(
            scale: _textScale.value,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  // Nom de l'application avec gradient et shimmer amélioré
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.primaryPurple,
                          AppColors.secondaryYellow,
                          AppColors.primary,
                        ],
                        stops: [
                          (_shimmerPosition.value - 0.4).clamp(0.0, 1.0),
                          (_shimmerPosition.value - 0.2).clamp(0.0, 1.0),
                          _shimmerPosition.value.clamp(0.0, 1.0),
                          (_shimmerPosition.value + 0.2).clamp(0.0, 1.0),
                          (_shimmerPosition.value + 0.4).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Kartia',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withAlpha(40),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                          Shadow(
                            color: AppColors.secondary.withAlpha(30),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: heightSpace.height! * 1.5),

                  // Slogan avec animation et design amélioré
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(15),
                          AppColors.secondary.withAlpha(15),
                          AppColors.primaryPurple.withAlpha(15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(30),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(20),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          l10n.splashSlogan,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(KartiaLocalizations l10n, SplashState state) {
    return Positioned(
      bottom: 120,
      left: 40,
      right: 40,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Column(
            children: [
              // Barre de progression moderne avec design amélioré
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow2,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Fond de la barre
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Progression avec gradient animé
                    FractionallySizedBox(
                      widthFactor: _progressValue.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                              AppColors.primaryPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(50),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Texte de chargement avec animation améliorée
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(90),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow2,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _getLoadingText(l10n, state),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVersionInfo(KartiaLocalizations l10n) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFade,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(80),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightGrey.withAlpha(50)),
            ),
            child: Column(
              children: [
                Text(
                  l10n.splashCopyright,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.splashVersion,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ShimmerPainter(animationValue: _shimmerController.value),
          ),
        );
      },
    );
  }

  String _getLoadingText(KartiaLocalizations l10n, SplashState state) {
    if (state.hasInitializationError) {
      return l10n.errorLoadingFailed;
    }

    switch (state.animationPhase) {
      case SplashAnimationPhase.initial:
        return l10n.splashStarting;
      case SplashAnimationPhase.logoStarted:
        return l10n.splashLoadingResources;
      case SplashAnimationPhase.textStarted:
        return l10n.splashInitializing;
      case SplashAnimationPhase.completed:
        return l10n.splashReady;
    }
  }

  void _showErrorDialog(
    BuildContext context,
    KartiaLocalizations l10n,
    String error,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.error_outline, color: AppColors.error),
                ),
                SizedBox(width: 12),
                const Text('Erreur'),
              ],
            ),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SplashBloc>().add(const SplashStarted());
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
    );
  }
}

/// Painter pour les particules de fond amélioré
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final int particleCount;

  ParticlesPainter({required this.animationValue, required this.particleCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + (i / particleCount)) % 1.0;
      final x = (size.width * 0.1) + (size.width * 0.8 * ((i * 0.7) % 1.0));
      final y = size.height * (1.0 - progress);
      final radius = 1.5 + (math.sin(progress * math.pi * 2) * 4.0);

      // Couleur basée sur l'index pour plus de variété
      Color particleColor;
      switch (i % 4) {
        case 0:
          particleColor = AppColors.primary.withAlpha(15);
          break;
        case 1:
          particleColor = AppColors.secondary.withAlpha(12);
          break;
        case 2:
          particleColor = AppColors.primaryPurple.withAlpha(10);
          break;
        default:
          particleColor = AppColors.secondaryYellow.withAlpha(8);
          break;
      }

      paint.color = particleColor;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour l'effet shimmer amélioré
class ShimmerPainter extends CustomPainter {
  final double animationValue;

  ShimmerPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withAlpha(15),
              Colors.white.withAlpha(25),
              Colors.white.withAlpha(15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
            transform: GradientRotation(math.pi / 6),
          ).createShader(
            Rect.fromLTWH(
              size.width * (animationValue - 0.4),
              0,
              size.width * 0.8,
              size.height,
            ),
          );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * (animationValue - 0.4),
        0,
        size.width * 0.8,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// lib/src/modules/splash/views/splash.screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/splash/bloc/splash_bloc.dart';

/// Écran de splash moderne et animé
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

/// Vue principale du splash avec toutes les animations
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

  // Animations du logo
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoRotation;
  late Animation<Offset> _logoSlide;

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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Contrôleur principal (durée totale)
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Contrôleur pour le logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Contrôleur pour le texte
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Contrôleur pour les particules
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Contrôleur pour le shimmer
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Contrôleur pour la progression
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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

    _logoRotation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // === ANIMATIONS DU TEXTE ===
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
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

    _shimmerPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
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

    // Logo après 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoController.forward();
    });

    // Texte après 800ms
    Future.delayed(const Duration(milliseconds: 800), () {
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
    super.dispose();
  }

  void _navigateBasedOnAuth(AuthState authState) {
    if (authState.isAuthenticated) {
      context.pushNamedAndRemoveUntil(AppRoutes.home);
    } else {
      context.pushNamedAndRemoveUntil(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<SplashBloc, SplashState>(
            listener: (context, state) {
              if (state.animationPhase == SplashAnimationPhase.logoStarted) {
                _startAnimations();
              }

              if (state.hasInitializationError) {
                _showErrorDialog(context, state.initializationError!);
              }

              if (state.isInitialized && state.shouldNavigate) {
                final authState = context.read<AuthBloc>().state;
                _navigateBasedOnAuth(authState);
              }
            },
          ),
        ],
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
                      _buildMainContent(state),

                      // Indicateur de progression
                      _buildProgressIndicator(state),

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
            AppColors.primary.withAlpha(10),
            AppColors.primary.withAlpha(30),
            progress,
          )!,
          Color.lerp(
            AppColors.secondary.withAlpha(5),
            AppColors.secondary.withAlpha(20),
            progress,
          )!,
          Color.lerp(
            AppColors.primaryPurple.withAlpha(2),
            AppColors.primaryPurple.withAlpha(10),
            progress,
          )!,
          Colors.white,
        ],
        stops: [0.0, 0.4 + (progress * 0.2), 0.7 + (progress * 0.1), 1.0],
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
              particleCount: 50,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(SplashState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Logo animé
          _buildAnimatedLogo(),

          SizedBox(height: heightSpace.height! * 3),

          // Texte animé
          _buildAnimatedText(),

          const Spacer(flex: 1),

          // Informations de version
          _buildVersionInfo(),

          SizedBox(height: heightSpace.height! * 2),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlide,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: FadeTransition(
                opacity: _logoFade,
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(40),
                          blurRadius: 40 * _logoFade.value,
                          spreadRadius: 10 * _logoFade.value,
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(20),
                          blurRadius: 60 * _logoFade.value,
                          spreadRadius: 15 * _logoFade.value,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
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

  Widget _buildAnimatedText() {
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
                  // Nom de l'application avec gradient et shimmer
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.primaryPurple,
                          AppColors.primary,
                        ],
                        stops:
                            [
                              _shimmerPosition.value - 0.3,
                              _shimmerPosition.value,
                              _shimmerPosition.value + 0.1,
                              _shimmerPosition.value + 0.3,
                            ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Kartia',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withAlpha(30),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: heightSpace.height!),

                  // Slogan avec animation
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(10),
                          AppColors.secondary.withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(10),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Votre assistant intelligent',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
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

  Widget _buildProgressIndicator(SplashState state) {
    return Positioned(
      bottom: 100,
      left: 40,
      right: 40,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Column(
            children: [
              // Barre de progression moderne
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    // Fond de la barre
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(10),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Progression
                    FractionallySizedBox(
                      widthFactor: _progressValue.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(40),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Texte de chargement avec animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _getLoadingText(state),
                  key: ValueKey(_getLoadingText(state)),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVersionInfo() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFade,
          child: Column(
            children: [
              Text(
                '© 2025 Kartia',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(20)),
                ),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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

  String _getLoadingText(SplashState state) {
    if (state.hasInitializationError) {
      return 'Erreur de chargement...';
    }

    switch (state.animationPhase) {
      case SplashAnimationPhase.initial:
        return 'Démarrage...';
      case SplashAnimationPhase.logoStarted:
        return 'Chargement des ressources...';
      case SplashAnimationPhase.textStarted:
        return 'Initialisation...';
      case SplashAnimationPhase.completed:
        return 'Prêt !';
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
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
                child: const Text('Réessayer'),
              ),
            ],
          ),
    );
  }
}

/// Painter pour les particules de fond
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final int particleCount;

  ParticlesPainter({required this.animationValue, required this.particleCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primary.withAlpha(10)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + (i / particleCount)) % 1.0;
      final x = (size.width * 0.1) + (size.width * 0.8 * ((i * 0.7) % 1.0));
      final y = size.height * (1.0 - progress);
      final radius = 2.0 + (math.sin(progress * math.pi) * 3.0);

      paint.color = AppColors.primary.withAlpha(10);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Painter pour l'effet shimmer
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
              Colors.white.withAlpha(10),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: GradientRotation(math.pi / 4),
          ).createShader(
            Rect.fromLTWH(
              size.width * (animationValue - 0.3),
              0,
              size.width * 0.6,
              size.height,
            ),
          );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * (animationValue - 0.3),
        0,
        size.width * 0.6,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

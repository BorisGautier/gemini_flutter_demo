import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';

/// Énumération pour les types d'indicateurs de chargement
enum KartiaLoadingType { circular, linear, dots, pulse, spinner }

/// Énumération pour les tailles d'indicateurs de chargement
enum KartiaLoadingSize { small, medium, large }

/// Widget d'indicateur de chargement personnalisé pour l'application Kartia
class KartiaLoading extends StatefulWidget {
  /// Type d'indicateur de chargement
  final KartiaLoadingType type;

  /// Taille de l'indicateur
  final KartiaLoadingSize size;

  /// Couleur de l'indicateur
  final Color? color;

  /// Message à afficher sous l'indicateur
  final String? message;

  /// Style du texte du message
  final TextStyle? messageStyle;

  /// Afficher l'indicateur au centre de l'écran
  final bool centered;

  /// Couleur de fond (si centered = true)
  final Color? backgroundColor;

  /// Opacité du fond (si centered = true)
  final int backgroundOpacity;

  const KartiaLoading({
    super.key,
    this.type = KartiaLoadingType.circular,
    this.size = KartiaLoadingSize.medium,
    this.color,
    this.message,
    this.messageStyle,
    this.centered = false,
    this.backgroundColor,
    this.backgroundOpacity = 50,
  });

  /// Factory pour créer un indicateur circulaire
  factory KartiaLoading.circular({
    KartiaLoadingSize size = KartiaLoadingSize.medium,
    Color? color,
    String? message,
    bool centered = false,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.circular,
      size: size,
      color: color,
      message: message,
      centered: centered,
    );
  }

  /// Factory pour créer un indicateur linéaire
  factory KartiaLoading.linear({
    Color? color,
    String? message,
    bool centered = false,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.linear,
      color: color,
      message: message,
      centered: centered,
    );
  }

  /// Factory pour créer un indicateur à points
  factory KartiaLoading.dots({
    KartiaLoadingSize size = KartiaLoadingSize.medium,
    Color? color,
    String? message,
    bool centered = false,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.dots,
      size: size,
      color: color,
      message: message,
      centered: centered,
    );
  }

  /// Factory pour créer un indicateur pulsé
  factory KartiaLoading.pulse({
    KartiaLoadingSize size = KartiaLoadingSize.medium,
    Color? color,
    String? message,
    bool centered = false,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.pulse,
      size: size,
      color: color,
      message: message,
      centered: centered,
    );
  }

  /// Factory pour créer un spinner personnalisé
  factory KartiaLoading.spinner({
    KartiaLoadingSize size = KartiaLoadingSize.medium,
    Color? color,
    String? message,
    bool centered = false,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.spinner,
      size: size,
      color: color,
      message: message,
      centered: centered,
    );
  }

  /// Factory pour un overlay de chargement plein écran
  factory KartiaLoading.overlay({
    String? message,
    Color? backgroundColor,
    int backgroundOpacity = 50,
  }) {
    return KartiaLoading(
      type: KartiaLoadingType.circular,
      size: KartiaLoadingSize.large,
      message: message,
      centered: true,
      backgroundColor: backgroundColor,
      backgroundOpacity: backgroundOpacity,
    );
  }

  @override
  State<KartiaLoading> createState() => _KartiaLoadingState();
}

class _KartiaLoadingState extends State<KartiaLoading>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = _buildLoadingContent();

    if (widget.centered) {
      return Container(
        color: (widget.backgroundColor ?? Colors.black).withAlpha(
          widget.backgroundOpacity,
        ),
        child: Center(child: loadingWidget),
      );
    }

    return loadingWidget;
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(),

        if (widget.message != null) ...[
          SizedBox(height: AppSizes.spacingM),
          Text(
            widget.message!,
            style:
                widget.messageStyle ??
                TextStyle(
                  color: widget.color ?? AppColors.primary,
                  fontSize: _getMessageFontSize(),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    switch (widget.type) {
      case KartiaLoadingType.circular:
        return _buildCircularIndicator();
      case KartiaLoadingType.linear:
        return _buildLinearIndicator();
      case KartiaLoadingType.dots:
        return _buildDotsIndicator();
      case KartiaLoadingType.pulse:
        return _buildPulseIndicator();
      case KartiaLoadingType.spinner:
        return _buildSpinnerIndicator();
    }
  }

  Widget _buildCircularIndicator() {
    final size = _getIndicatorSize();

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLinearIndicator() {
    return SizedBox(
      width: _getLinearWidth(),
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? AppColors.primary,
        ),
        backgroundColor: (widget.color ?? AppColors.primary).withAlpha(20),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animationController.value - delay) % 1.0;
            final scale =
                animationValue < 0.5
                    ? 1.0 + (animationValue * 2 * 0.5)
                    : 1.5 - ((animationValue - 0.5) * 2 * 0.5);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: AppSizes.spacingXS),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: _getDotSize(),
                  height: _getDotSize(),
                  decoration: BoxDecoration(
                    color: widget.color ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: _getIndicatorSize(),
            height: _getIndicatorSize(),
            decoration: BoxDecoration(
              color: (widget.color ?? AppColors.primary).withAlpha(70),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: _getIndicatorSize() * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpinnerIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 2.0 * 3.14159,
          child: Container(
            width: _getIndicatorSize(),
            height: _getIndicatorSize(),
            decoration: BoxDecoration(
              border: Border.all(
                color: (widget.color ?? AppColors.primary).withAlpha(20),
                width: _getStrokeWidth(),
              ),
              borderRadius: BorderRadius.circular(_getIndicatorSize() / 2),
            ),
            child: CustomPaint(
              painter: SpinnerPainter(
                color: widget.color ?? AppColors.primary,
                strokeWidth: _getStrokeWidth(),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getIndicatorSize() {
    switch (widget.size) {
      case KartiaLoadingSize.small:
        return 20.0;
      case KartiaLoadingSize.medium:
        return 40.0;
      case KartiaLoadingSize.large:
        return 60.0;
    }
  }

  double _getStrokeWidth() {
    switch (widget.size) {
      case KartiaLoadingSize.small:
        return 2.0;
      case KartiaLoadingSize.medium:
        return 3.0;
      case KartiaLoadingSize.large:
        return 4.0;
    }
  }

  double _getDotSize() {
    switch (widget.size) {
      case KartiaLoadingSize.small:
        return 6.0;
      case KartiaLoadingSize.medium:
        return 8.0;
      case KartiaLoadingSize.large:
        return 12.0;
    }
  }

  double _getLinearWidth() {
    switch (widget.size) {
      case KartiaLoadingSize.small:
        return 100.0;
      case KartiaLoadingSize.medium:
        return 200.0;
      case KartiaLoadingSize.large:
        return 300.0;
    }
  }

  double _getMessageFontSize() {
    switch (widget.size) {
      case KartiaLoadingSize.small:
        return 12.0;
      case KartiaLoadingSize.medium:
        return 14.0;
      case KartiaLoadingSize.large:
        return 16.0;
    }
  }
}

/// Painter personnalisé pour le spinner
class SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SpinnerPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Dessiner un arc de 90 degrés
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // -90 degrés
      3.14159 / 2, // 90 degrés
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget de loading avec animation personnalisée
class KartiaAnimatedLoading extends StatefulWidget {
  final String? message;
  final Color? color;

  const KartiaAnimatedLoading({super.key, this.message, this.color});

  @override
  State<KartiaAnimatedLoading> createState() => _KartiaAnimatedLoadingState();
}

class _KartiaAnimatedLoadingState extends State<KartiaAnimatedLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    widget.color ?? AppColors.primary,
                    (widget.color ?? AppColors.primary).withAlpha(50),
                    widget.color ?? AppColors.primary,
                  ],
                  stops:
                      [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: Text(
                'Kartia',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            );
          },
        ),

        if (widget.message != null) ...[
          SizedBox(height: AppSizes.spacingM),
          Text(
            widget.message!,
            style: TextStyle(
              color: widget.color ?? AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}

/// Extensions pour faciliter l'utilisation des indicateurs de chargement
extension LoadingExtensions on BuildContext {
  /// Afficher un overlay de chargement
  void showLoadingOverlay({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => KartiaLoading.overlay(message: message),
    );
  }

  /// Fermer l'overlay de chargement
  void hideLoadingOverlay() {
    Navigator.of(this).pop();
  }
}

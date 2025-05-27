import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';

/// Énumération pour les types de boutons
enum KartiaButtonType { primary, secondary, outline, text, icon }

/// Énumération pour les tailles de boutons
enum KartiaButtonSize { small, medium, large }

/// Widget de bouton personnalisé pour l'application Kartia
class KartiaButton extends StatefulWidget {
  /// Texte du bouton
  final String? text;

  /// Icône du bouton
  final IconData? icon;

  /// Widget personnalisé à afficher
  final Widget? child;

  /// Fonction appelée lors du tap
  final VoidCallback? onPressed;

  /// Type de bouton
  final KartiaButtonType type;

  /// Taille du bouton
  final KartiaButtonSize size;

  /// Largeur du bouton
  final double? width;

  /// Hauteur du bouton
  final double? height;

  /// Activer/désactiver le bouton
  final bool enabled;

  /// Afficher un indicateur de chargement
  final bool isLoading;

  /// Couleur de fond personnalisée
  final Color? backgroundColor;

  /// Couleur du texte personnalisée
  final Color? textColor;

  /// Couleur de bordure personnalisée
  final Color? borderColor;

  /// Rayon de bordure
  final double? borderRadius;

  /// Épaisseur de la bordure
  final double borderWidth;

  /// Padding personnalisé
  final EdgeInsetsGeometry? padding;

  /// Marge personnalisée
  final EdgeInsetsGeometry? margin;

  /// Élévation du bouton
  final double? elevation;

  /// Style de texte personnalisé
  final TextStyle? textStyle;

  /// Centrer le contenu
  final bool centerContent;

  const KartiaButton({
    super.key,
    this.text,
    this.icon,
    this.child,
    required this.onPressed,
    this.type = KartiaButtonType.primary,
    this.size = KartiaButtonSize.medium,
    this.width,
    this.height,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.elevation,
    this.textStyle,
    this.centerContent = true,
  }) : assert(
         text != null || icon != null || child != null,
         'Au moins un des paramètres text, icon ou child doit être fourni',
       );

  @override
  State<KartiaButton> createState() => _KartiaButtonState();
}

class _KartiaButtonState extends State<KartiaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.enabled && !widget.isLoading;

    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(context, theme, isEnabled),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme, bool isEnabled) {
    final buttonStyle = _getButtonStyle(theme, isEnabled);

    Widget buttonChild = _buildButtonChild(theme, isEnabled);

    if (widget.type == KartiaButtonType.icon) {
      return _buildIconButton(buttonStyle, buttonChild, isEnabled);
    }

    return _buildRegularButton(buttonStyle, buttonChild, isEnabled);
  }

  Widget _buildRegularButton(ButtonStyle style, Widget child, bool isEnabled) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? _getHeightForSize(),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ElevatedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: style,
          child: child,
        ),
      ),
    );
  }

  Widget _buildIconButton(ButtonStyle style, Widget child, bool isEnabled) {
    return SizedBox(
      width: widget.width ?? _getIconSizeForSize(),
      height: widget.height ?? _getIconSizeForSize(),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ElevatedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: style.copyWith(shape: WidgetStateProperty.all(CircleBorder())),
          child: child,
        ),
      ),
    );
  }

  Widget _buildButtonChild(ThemeData theme, bool isEnabled) {
    if (widget.isLoading) {
      return _buildLoadingIndicator(theme, isEnabled);
    }

    if (widget.child != null) {
      return widget.child!;
    }

    return _buildButtonContent(theme, isEnabled);
  }

  Widget _buildButtonContent(ThemeData theme, bool isEnabled) {
    final textColor = _getTextColor(theme, isEnabled);
    final iconSize = _getIconSizeForSize();

    if (widget.text != null && widget.icon != null) {
      // Bouton avec texte et icône
      return Row(
        mainAxisSize:
            widget.centerContent ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment:
            widget.centerContent
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          Icon(widget.icon, size: iconSize, color: textColor),
          const SizedBox(width: 8),
          Text(widget.text!, style: _getTextStyle(theme, isEnabled)),
        ],
      );
    } else if (widget.text != null) {
      // Bouton avec texte seulement
      return Text(
        widget.text!,
        style: _getTextStyle(theme, isEnabled),
        textAlign: TextAlign.center,
      );
    } else if (widget.icon != null) {
      // Bouton avec icône seulement
      return Icon(widget.icon, size: iconSize, color: textColor);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingIndicator(ThemeData theme, bool isEnabled) {
    final color = _getTextColor(theme, isEnabled);
    final size = _getLoadingSizeForSize();

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme, bool isEnabled) {
    final backgroundColor = _getBackgroundColor(theme, isEnabled);
    final foregroundColor = _getTextColor(theme, isEnabled);
    final borderColor = _getBorderColor(theme, isEnabled);
    final elevation = _getElevation();

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      shadowColor: AppColors.shadow2,
      padding: widget.padding ?? _getPaddingForSize(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? _getBorderRadiusForSize(),
        ),
        side: BorderSide(color: borderColor, width: widget.borderWidth),
      ),
      textStyle: widget.textStyle ?? _getDefaultTextStyle(theme),
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return AppColors.lightGrey.withAlpha(30);
    }

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.type) {
      case KartiaButtonType.primary:
        return AppColors.primary;
      case KartiaButtonType.secondary:
        return AppColors.secondary;
      case KartiaButtonType.outline:
      case KartiaButtonType.text:
        return Colors.transparent;
      case KartiaButtonType.icon:
        return AppColors.primary.withAlpha(10);
    }
  }

  Color _getTextColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return AppColors.mediumGrey;
    }

    if (widget.textColor != null) {
      return widget.textColor!;
    }

    switch (widget.type) {
      case KartiaButtonType.primary:
      case KartiaButtonType.secondary:
        return AppColors.white;
      case KartiaButtonType.outline:
      case KartiaButtonType.text:
      case KartiaButtonType.icon:
        return AppColors.primary;
    }
  }

  Color _getBorderColor(ThemeData theme, bool isEnabled) {
    if (!isEnabled) {
      return AppColors.lightGrey;
    }

    if (widget.borderColor != null) {
      return widget.borderColor!;
    }

    switch (widget.type) {
      case KartiaButtonType.primary:
      case KartiaButtonType.secondary:
        return Colors.transparent;
      case KartiaButtonType.outline:
        return AppColors.primary;
      case KartiaButtonType.text:
      case KartiaButtonType.icon:
        return Colors.transparent;
    }
  }

  double _getElevation() {
    if (widget.elevation != null) {
      return widget.elevation!;
    }

    switch (widget.type) {
      case KartiaButtonType.primary:
      case KartiaButtonType.secondary:
        return 2.0;
      case KartiaButtonType.outline:
      case KartiaButtonType.text:
      case KartiaButtonType.icon:
        return 0.0;
    }
  }

  EdgeInsetsGeometry _getPaddingForSize() {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case KartiaButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case KartiaButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  double _getHeightForSize() {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return 36;
      case KartiaButtonSize.medium:
        return 48;
      case KartiaButtonSize.large:
        return 56;
    }
  }

  double _getIconSizeForSize() {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return 15;
      case KartiaButtonSize.medium:
        return 23;
      case KartiaButtonSize.large:
        return 31;
    }
  }

  double _getLoadingSizeForSize() {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return 16;
      case KartiaButtonSize.medium:
        return 20;
      case KartiaButtonSize.large:
        return 24;
    }
  }

  double _getBorderRadiusForSize() {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return 8;
      case KartiaButtonSize.medium:
        return 12;
      case KartiaButtonSize.large:
        return 16;
    }
  }

  TextStyle _getDefaultTextStyle(ThemeData theme) {
    switch (widget.size) {
      case KartiaButtonSize.small:
        return theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case KartiaButtonSize.medium:
        return theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case KartiaButtonSize.large:
        return theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isEnabled) {
    final defaultStyle = _getDefaultTextStyle(theme);
    final textColor = _getTextColor(theme, isEnabled);

    return widget.textStyle?.copyWith(color: textColor) ??
        defaultStyle.copyWith(color: textColor);
  }
}

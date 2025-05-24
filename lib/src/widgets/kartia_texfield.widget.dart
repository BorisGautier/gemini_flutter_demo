import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kartia/src/core/utils/colors.util.dart';

/// Widget de champ de texte personnalisé pour l'application Kartia
class KartiaTextField extends StatefulWidget {
  /// Contrôleur de texte
  final TextEditingController? controller;

  /// Texte d'étiquette
  final String? labelText;

  /// Texte d'indication
  final String? hintText;

  /// Texte d'aide
  final String? helperText;

  /// Message d'erreur
  final String? errorText;

  /// Icône de préfixe
  final IconData? prefixIcon;

  /// Widget de préfixe personnalisé
  final Widget? prefixWidget;

  /// Icône de suffixe
  final IconData? suffixIcon;

  /// Widget de suffixe personnalisé
  final Widget? suffixWidget;

  /// Fonction appelée lors du changement de texte
  final void Function(String)? onChanged;

  /// Fonction appelée lors de la soumission
  final void Function(String)? onSubmitted;

  /// Fonction appelée lors du tap
  final VoidCallback? onTap;

  /// Type de clavier
  final TextInputType keyboardType;

  /// Action du clavier
  final TextInputAction textInputAction;

  /// Obscurcir le texte (pour les mots de passe)
  final bool obscureText;

  /// Activer/désactiver le champ
  final bool enabled;

  /// Lecture seule
  final bool readOnly;

  /// Nombre maximum de lignes
  final int? maxLines;

  /// Nombre minimum de lignes
  final int? minLines;

  /// Longueur maximale du texte
  final int? maxLength;

  /// Formatters de saisie
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node
  final FocusNode? focusNode;

  /// Validation du champ
  final String? Function(String?)? validator;

  /// Demander le focus automatiquement
  final bool autofocus;

  /// Correction automatique
  final bool autocorrect;

  /// Suggestions de texte
  final bool enableSuggestions;

  /// Remplissage automatique
  final Iterable<String>? autofillHints;

  /// Style de texte
  final TextStyle? textStyle;

  /// Bordure personnalisée
  final InputBorder? border;

  /// Couleur de fond personnalisée
  final Color? fillColor;

  /// Rayon de bordure
  final double borderRadius;

  /// Padding du contenu
  final EdgeInsetsGeometry? contentPadding;

  const KartiaTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.textStyle,
    this.border,
    this.fillColor,
    this.borderRadius = 12.0,
    this.contentPadding,
  });

  @override
  State<KartiaTextField> createState() => _KartiaTextFieldState();
}

class _KartiaTextFieldState extends State<KartiaTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Déterminer la couleur de bordure en fonction de l'état
    Color borderColor = AppColors.lightGrey;
    if (widget.errorText != null) {
      borderColor = AppColors.error;
    } else if (_isFocused) {
      borderColor = AppColors.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Étiquette
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Champ de texte
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          autofillHints: widget.autofillHints,
          style: widget.textStyle ?? theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor:
                widget.fillColor ??
                (widget.enabled
                    ? colorScheme.surface
                    : AppColors.lightGrey.withAlpha(50)),
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            // Icône de préfixe
            prefixIcon:
                widget.prefixWidget ??
                (widget.prefixIcon != null
                    ? Icon(
                      widget.prefixIcon,
                      color:
                          _isFocused ? AppColors.primary : AppColors.mediumGrey,
                    )
                    : null),

            // Icône de suffixe
            suffixIcon: widget.suffixWidget ?? _buildSuffixIcon(),

            // Bordures
            border: widget.border ?? _buildBorder(borderColor),
            enabledBorder: widget.border ?? _buildBorder(AppColors.lightGrey),
            focusedBorder: widget.border ?? _buildBorder(AppColors.primary),
            errorBorder: widget.border ?? _buildBorder(AppColors.error),
            focusedErrorBorder: widget.border ?? _buildBorder(AppColors.error),
            disabledBorder:
                widget.border ??
                _buildBorder(AppColors.lightGrey.withAlpha(50)),

            // Styles de texte
            hintStyle: TextStyle(color: AppColors.mediumGrey, fontSize: 16),
            helperStyle: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
            errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
            labelStyle: TextStyle(
              color: _isFocused ? AppColors.primary : AppColors.mediumGrey,
            ),
          ),
        ),
      ],
    );
  }

  /// Construire l'icône de suffixe
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _isFocused ? AppColors.primary : AppColors.mediumGrey,
        ),
        onPressed: _toggleObscureText,
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: _isFocused ? AppColors.primary : AppColors.mediumGrey,
      );
    }

    return null;
  }

  /// Construire la bordure
  InputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: color,
        width:
            color == AppColors.primary || color == AppColors.error ? 2.0 : 1.0,
      ),
    );
  }
}

/// Widget de champ de texte spécialisé pour les emails
class KartiaEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const KartiaEmailField({
    super.key,
    this.controller,
    this.labelText = 'Email',
    this.hintText = 'exemple@email.com',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return KartiaTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator,
      enabled: enabled,
      autofocus: autofocus,
      autofillHints: const [AutofillHints.email],
    );
  }
}

/// Widget de champ de texte spécialisé pour les mots de passe
class KartiaPasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const KartiaPasswordField({
    super.key,
    this.controller,
    this.labelText = 'Mot de passe',
    this.hintText = 'Entrez votre mot de passe',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return KartiaTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: Icons.lock_outline,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: true,
      validator: validator,
      enabled: enabled,
      autofocus: autofocus,
      autofillHints: const [AutofillHints.password],
    );
  }
}

/// Widget de champ de texte spécialisé pour les numéros de téléphone
class KartiaPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const KartiaPhoneField({
    super.key,
    this.controller,
    this.labelText = 'Téléphone',
    this.hintText = '+237 6XX XXX XXX',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return KartiaTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      validator: validator,
      enabled: enabled,
      autofocus: autofocus,
      autofillHints: const [AutofillHints.telephoneNumber],
    );
  }
}

// upgrade_account.screen.dart - VERSION CORRIGÉE

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/validators.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:kartia/src/widgets/kartia_texfield.widget.dart';

/// Écran pour mettre à niveau un compte anonyme vers un compte permanent
class UpgradeAccountScreen extends StatefulWidget {
  const UpgradeAccountScreen({super.key});

  @override
  State<UpgradeAccountScreen> createState() => _UpgradeAccountScreenState();
}

class _UpgradeAccountScreenState extends State<UpgradeAccountScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController(); // ✅ NOUVEAU

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _upgradeMethod = 'email';
  String? _verificationId;
  bool _codeSent = false; // ✅ NOUVEAU: Track si le code est envoyé

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['method'] != null) {
        setState(() {
          _upgradeMethod = args['method'];
        });
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleUpgrade() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_upgradeMethod == 'email') {
        _handleEmailUpgrade();
      } else {
        if (!_codeSent) {
          _handlePhoneVerification();
        } else {
          _handlePhoneUpgrade();
        }
      }
    }
  }

  void _handleEmailUpgrade() {
    context.read<AuthBloc>().add(
      AuthUpgradeAnonymousAccountRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName:
            _displayNameController.text.trim().isNotEmpty
                ? _displayNameController.text.trim()
                : null,
      ),
    );
  }

  // ✅ NOUVEAU: Séparer la vérification et l'upgrade pour le téléphone
  void _handlePhoneVerification() {
    String phoneNumber = _phoneController.text.trim();

    // Ajouter +237 si ce n'est pas déjà présent
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('6')) {
        phoneNumber = '+237$phoneNumber';
      } else {
        phoneNumber = '+237$phoneNumber';
      }
    }

    context.read<AuthBloc>().add(
      AuthVerifyPhoneNumberRequested(phoneNumber: phoneNumber),
    );
  }

  void _handlePhoneUpgrade() {
    if (_verificationId != null) {
      // ✅ CORRECTION: Utiliser l'événement d'upgrade spécifique pour téléphone
      context.read<AuthBloc>().add(
        AuthUpgradeAnonymousToPhoneRequested(
          verificationId: _verificationId!,
          smsCode: _smsCodeController.text.trim(),
          displayName:
              _displayNameController.text.trim().isNotEmpty
                  ? _displayNameController.text.trim()
                  : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withAlpha(15),
              AppColors.backgroundColor(context),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              // ✅ Debug logging
              debugPrint('UpgradeAccountScreen - AuthState: ${state.status}');
              debugPrint(
                'User: ${state.user?.uid}, IsAnonymous: ${state.user?.isAnonymous}',
              );

              if (state.hasError) {
                KartiaSnackbar.show(
                  context,
                  message: state.errorMessage!,
                  type: SnackbarType.error,
                );
              } else if (state.isPhoneCodeSent && _upgradeMethod == 'phone') {
                // ✅ Code SMS envoyé
                setState(() {
                  _verificationId = state.verificationId;
                  _codeSent = true;
                });
                KartiaSnackbar.show(
                  context,
                  message: 'Code SMS envoyé ! Vérifiez vos messages.',
                  type: SnackbarType.success,
                );
              } else if (state.isAuthenticated && state.user != null) {
                // ✅ CORRECTION: Vérifier si l'upgrade a réussi
                if (_upgradeMethod == 'email' && !state.user!.isAnonymous) {
                  // Upgrade email réussi
                  KartiaSnackbar.show(
                    context,
                    message: 'Compte email créé avec succès !',
                    type: SnackbarType.success,
                  );
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                } else if (_upgradeMethod == 'phone' &&
                    state.user!.phoneNumber != null) {
                  // Upgrade téléphone réussi
                  KartiaSnackbar.show(
                    context,
                    message: 'Compte téléphone créé avec succès !',
                    type: SnackbarType.success,
                  );
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              }
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ResponsiveLayout(
                  mobile: _buildMobileLayout(),
                  tablet: _buildTabletLayout(),
                  desktop: _buildDesktopLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: ResponsivePadding(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                if (!_codeSent || _upgradeMethod == 'email')
                  _buildMethodSelector(),
                if (!_codeSent || _upgradeMethod == 'email')
                  const SizedBox(height: 24),
                _buildForm(),
                const SizedBox(height: 24),
                _buildActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return ResponsiveContainer(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: ResponsivePadding(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [const SizedBox(height: 40), _buildHeader()],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        if (!_codeSent || _upgradeMethod == 'email')
                          _buildMethodSelector(),
                        if (!_codeSent || _upgradeMethod == 'email')
                          const SizedBox(height: 24),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ResponsiveContainer(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: ResponsivePadding(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [const SizedBox(height: 60), _buildHeader()],
                    ),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        if (!_codeSent || _upgradeMethod == 'email')
                          _buildMethodSelector(),
                        if (!_codeSent || _upgradeMethod == 'email')
                          const SizedBox(height: 32),
                        _buildForm(),
                        const SizedBox(height: 32),
                        _buildActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.isMobile(context) ? 120 : 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            _codeSent && _upgradeMethod == 'phone'
                ? 'Vérification SMS'
                : 'Créer un Compte',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getAdaptiveFontSize(
                context,
                baseFontSize: 18,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.white),
        onPressed: () {
          if (_codeSent && _upgradeMethod == 'phone') {
            // Retour à la sélection du numéro
            setState(() {
              _codeSent = false;
              _verificationId = null;
              _smsCodeController.clear();
            });
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisir la méthode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceColor(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMethodOption(
                  'email',
                  'Email',
                  Icons.email_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMethodOption(
                  'phone',
                  'Téléphone',
                  Icons.phone_outlined,
                  AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(
    String method,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _upgradeMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _upgradeMethod = method;
          // Réinitialiser les champs
          _emailController.clear();
          _phoneController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _smsCodeController.clear();
          _codeSent = false;
          _verificationId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color:
                isSelected
                    ? color
                    : AppColors.onSurfaceSecondaryColor(context).withAlpha(50),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? color
                      : AppColors.onSurfaceSecondaryColor(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? color
                        : AppColors.onSurfaceSecondaryColor(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              _codeSent && _upgradeMethod == 'phone'
                  ? Icons.sms
                  : Icons.upgrade_rounded,
              color: AppColors.white,
              size: ResponsiveUtils.getAdaptiveValue(context, 40),
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getAdaptiveSpacing(
              context,
              AppSizes.spacingL,
            ),
          ),
          Text(
            _codeSent && _upgradeMethod == 'phone'
                ? 'Vérification SMS'
                : 'Passez à un Compte Complet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceColor(context),
              fontSize: ResponsiveUtils.getAdaptiveFontSize(
                context,
                baseFontSize: 24,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: ResponsiveUtils.getAdaptiveSpacing(
              context,
              AppSizes.spacingM,
            ),
          ),
          Text(
            _codeSent && _upgradeMethod == 'phone'
                ? 'Entrez le code de vérification envoyé au ${_phoneController.text}'
                : 'Transformez votre compte invité en compte permanent pour bénéficier de toutes les fonctionnalités.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceSecondaryColor(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_codeSent) ...[
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingL,
              ),
            ),
            _buildFeaturesList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.save_rounded, 'text': 'Sauvegarde de vos données'},
      {'icon': Icons.sync_rounded, 'text': 'Synchronisation multi-appareils'},
      {'icon': Icons.security_rounded, 'text': 'Sécurité renforcée'},
      {'icon': Icons.backup_rounded, 'text': 'Sauvegarde automatique'},
    ];

    return Column(
      children:
          features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(15),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: AppColors.success,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature['text'] as String,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _codeSent && _upgradeMethod == 'phone'
                  ? 'Code de Vérification'
                  : (_upgradeMethod == 'email'
                      ? 'Informations du Compte Email'
                      : 'Informations du Compte Téléphone'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceColor(context),
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingL,
              ),
            ),

            // ✅ Affichage conditionnel selon l'état
            if (_codeSent && _upgradeMethod == 'phone') ...[
              // Champ pour le code SMS
              KartiaTextField(
                controller: _smsCodeController,
                labelText: 'Code SMS',
                hintText: 'Entrez le code à 6 chiffres',
                prefixIcon: Icons.sms_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Le code SMS est requis';
                  }
                  if (value!.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
              ),
            ] else ...[
              // Nom d'affichage (commun)
              KartiaTextField(
                controller: _displayNameController,
                labelText: 'Nom d\'affichage (optionnel)',
                hintText: 'Votre nom complet',
                prefixIcon: Icons.person_outline,
                validator: (value) => null,
              ),
              SizedBox(
                height: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),

              // Champs spécifiques
              if (_upgradeMethod == 'email') ...[
                KartiaTextField(
                  controller: _emailController,
                  labelText: 'Adresse email',
                  hintText: 'votre@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'L\'adresse email est requise';
                    }
                    if (!Validators.isValidEmail(value!)) {
                      return 'Adresse email invalide';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.getAdaptiveSpacing(
                    context,
                    AppSizes.spacingM,
                  ),
                ),
                KartiaPasswordField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  hintText: 'Choisissez un mot de passe sécurisé',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Le mot de passe est requis';
                    }
                    if (!Validators.isValidPassword(value!)) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: ResponsiveUtils.getAdaptiveSpacing(
                    context,
                    AppSizes.spacingM,
                  ),
                ),
                KartiaPasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmer le mot de passe',
                  hintText: 'Ressaisissez votre mot de passe',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'La confirmation est requise';
                    }
                    if (!Validators.isValidCPassword(
                      _passwordController.text,
                      value!,
                    )) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ] else ...[
                KartiaTextField(
                  controller: _phoneController,
                  labelText: 'Numéro de téléphone',
                  hintText: '6XX XXX XXX (sans +237)',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Le numéro de téléphone est requis';
                    }
                    // Validation basique pour le Cameroun
                    final cleanPhone = value!.replaceAll(' ', '');
                    if (!cleanPhone.startsWith('6') || cleanPhone.length != 9) {
                      return 'Numéro invalide (format: 6XX XXX XXX)';
                    }
                    return null;
                  },
                ),
              ],
            ],

            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String buttonText;
        IconData? buttonIcon;

        if (_upgradeMethod == 'email') {
          buttonText = 'Créer mon Compte Email';
          buttonIcon = Icons.email;
        } else {
          if (!_codeSent) {
            buttonText = 'Envoyer le Code SMS';
            buttonIcon = Icons.sms;
          } else {
            buttonText = 'Vérifier le Code';
            buttonIcon = Icons.check;
          }
        }

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: KartiaButton(
                text: buttonText,
                onPressed: state.isLoading ? null : _handleUpgrade,
                type: KartiaButtonType.primary,
                size: KartiaButtonSize.large,
                icon: state.isLoading ? null : buttonIcon,
                isLoading: state.isLoading,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getAdaptiveSpacing(
                context,
                AppSizes.spacingM,
              ),
            ),
            TextButton(
              onPressed:
                  state.isLoading
                      ? null
                      : () {
                        if (_codeSent && _upgradeMethod == 'phone') {
                          // Retour à la sélection du numéro
                          setState(() {
                            _codeSent = false;
                            _verificationId = null;
                            _smsCodeController.clear();
                          });
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
              child: Text(
                _codeSent && _upgradeMethod == 'phone'
                    ? 'Changer de numéro'
                    : 'Retour',
                style: TextStyle(
                  color: AppColors.onSurfaceSecondaryColor(context),
                  fontSize: ResponsiveUtils.getAdaptiveFontSize(
                    context,
                    baseFontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

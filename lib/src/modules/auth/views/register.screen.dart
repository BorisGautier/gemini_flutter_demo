import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/validators.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:kartia/src/widgets/kartia_texfield.widget.dart';

/// Page d'inscription de l'application
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _staggerAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Animations échelonnées pour les champs
  late Animation<Offset> _field1Animation;
  late Animation<Offset> _field2Animation;
  late Animation<Offset> _field3Animation;
  late Animation<Offset> _field4Animation;

  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Animations échelonnées pour les champs
    _field1Animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _field2Animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _field3Animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _field4Animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _scaleAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _staggerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _staggerAnimationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        KartiaSnackbar.show(
          context,
          message: KartiaLocalizations.of(context).pleaseAcceptTerms,
          type: SnackbarType.error,
        );
        return;
      }

      context.read<AuthBloc>().add(
        AuthSignUpWithEmailAndPasswordRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName:
              _displayNameController.text.trim().isNotEmpty
                  ? _displayNameController.text.trim()
                  : null,
        ),
      );
    }
  }

  void _navigateToLogin() {
    context.pop();
  }

  void _navigateToPhoneAuth() {
    context.pushNamed(AppRoutes.phoneAuth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.secondary),
          onPressed: _navigateToLogin,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            KartiaSnackbar.show(
              context,
              message: state.errorMessage!,
              type: SnackbarType.error,
            );
          } else if (state.isEmailNotVerified && state.user != null) {
            // Email non vérifié après inscription - ne rien faire ici
            // AppNavigationManager va gérer la navigation automatiquement
            KartiaSnackbar.show(
              context,
              message: 'Compte créé ! Vérifiez votre email.',
              type: SnackbarType.success,
            );
            context.pop();
          } else if (state.isAuthenticated) {
            // Utilisateur complètement authentifié (téléphone ou email vérifié)
            KartiaSnackbar.show(
              context,
              message: 'Bienvenue ${state.user?.displayName ?? ''} !',
              type: SnackbarType.success,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary.withAlpha(15),
                AppColors.primaryPurple.withAlpha(8),
                AppColors.primary.withAlpha(5),
                Colors.white,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(fixPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: heightSpace.height!),
                      _buildHeader(l10n),
                      SizedBox(height: heightSpace.height! * 2),
                      _buildRegisterForm(l10n),
                      SizedBox(height: heightSpace.height! * 2),
                      _buildAlternativeSignInMethods(l10n),
                      SizedBox(height: heightSpace.height!),
                      _buildFooter(l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KartiaLocalizations l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          // Logo plus petit avec animation
          Hero(
            tag: 'app_logo',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withAlpha(30),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withAlpha(90)],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: heightSpace.height!),

          // Titre avec gradient
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [AppColors.secondary, AppColors.primaryPurple],
              ).createShader(bounds);
            },
            child: Text(
              l10n.createAccount,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: heightSpace.height! / 2),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(10),
                  AppColors.primaryPurple.withAlpha(10),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.secondary.withAlpha(30)),
            ),
            child: Text(
              l10n.joinUsNow,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Champ nom d'affichage avec animation
                SlideTransition(
                  position: _field1Animation,
                  child: KartiaTextField(
                    controller: _displayNameController,
                    labelText: l10n.displayName,
                    hintText: l10n.displayNameHint,
                    prefixIcon: Icons.person_outline,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: heightSpace.height!),

                // Champ email avec animation
                SlideTransition(
                  position: _field2Animation,
                  child: KartiaEmailField(
                    controller: _emailController,
                    labelText: l10n.email,
                    hintText: l10n.emailHint,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.validationEmailRequired;
                      }
                      if (!Validators.isValidEmail(value!)) {
                        return l10n.validationEmailInvalid;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: heightSpace.height!),

                // Champ mot de passe avec animation
                SlideTransition(
                  position: _field3Animation,
                  child: KartiaPasswordField(
                    controller: _passwordController,
                    labelText: l10n.password,
                    hintText: l10n.newPasswordHint,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.validationPasswordRequired;
                      }
                      if (!Validators.isValidPassword(value!)) {
                        return l10n.validationPasswordMinLength;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: heightSpace.height!),

                // Champ confirmation mot de passe avec animation
                SlideTransition(
                  position: _field4Animation,
                  child: KartiaPasswordField(
                    controller: _confirmPasswordController,
                    labelText: l10n.confirmPassword,
                    hintText: l10n.confirmPasswordHint,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.validationConfirmPasswordRequired;
                      }
                      if (!Validators.isValidCPassword(
                        _passwordController.text,
                        value!,
                      )) {
                        return l10n.validationPasswordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: heightSpace.height!),

                // Case à cocher conditions d'utilisation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _acceptTerms
                            ? AppColors.secondary.withAlpha(5)
                            : AppColors.lightGrey.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _acceptTerms
                              ? AppColors.secondary.withAlpha(30)
                              : AppColors.lightGrey.withAlpha(30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged:
                            isLoading
                                ? null
                                : (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                        activeColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              isLoading
                                  ? null
                                  : () {
                                    setState(() {
                                      _acceptTerms = !_acceptTerms;
                                    });
                                  },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(text: l10n.acceptTerms),
                                  TextSpan(
                                    text: l10n.termsOfService,
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: l10n.and),
                                  TextSpan(
                                    text: l10n.privacyPolicy,
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: heightSpace.height! * 1.5),

                // Bouton d'inscription
                KartiaButton(
                  text: l10n.signUp,
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                  width: double.infinity,
                  size: KartiaButtonSize.large,
                  backgroundColor: AppColors.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlternativeSignInMethods(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Column(
          children: [
            // Divider avec texte amélioré
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.lightGrey,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.lightGrey.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      l10n.orSignUpWith,
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.lightGrey,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: heightSpace.height!),

            // Boutons d'authentification alternative
            Row(
              children: [
                // Phone Auth
                Expanded(
                  child: KartiaButton(
                    text: l10n.phone,
                    icon: Icons.phone,
                    onPressed: isLoading ? null : _navigateToPhoneAuth,
                    type: KartiaButtonType.outline,
                    size: KartiaButtonSize.large,
                    borderColor: AppColors.secondary,
                    textColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(KartiaLocalizations l10n) {
    return Column(
      children: [
        // Lien vers la connexion
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.lightGrey.withAlpha(50)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.alreadyHaveAccount,
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
              ),
              TextButton(
                onPressed: _navigateToLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.signIn,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

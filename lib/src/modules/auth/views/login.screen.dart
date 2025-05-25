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

/// Page de connexion de l'application
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _logoAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Contrôleurs d'animation
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

    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animations
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

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _scaleAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInWithEmailAndPasswordRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleAnonymousSignIn() {
    context.read<AuthBloc>().add(const AuthSignInAnonymouslyRequested());
  }

  void _navigateToRegister() {
    context.pushNamed(AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    context.pushNamed(AppRoutes.forgotPassword);
  }

  void _navigateToPhoneAuth() {
    context.pushNamed(AppRoutes.phoneAuth);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            KartiaSnackbar.show(
              context,
              message: state.errorMessage!,
              type: SnackbarType.error,
            );
          } else if (state.isAuthenticated) {
            context.pushNamedAndRemoveUntil(AppRoutes.home);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(15),
                AppColors.secondary.withAlpha(8),
                AppColors.primaryPurple.withAlpha(5),
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
                      SizedBox(height: heightSpace.height! * 2),
                      _buildHeader(l10n),
                      SizedBox(height: heightSpace.height! * 3),
                      _buildLoginForm(l10n),
                      SizedBox(height: heightSpace.height! * 2),
                      _buildAlternativeSignInMethods(l10n),
                      SizedBox(height: heightSpace.height! * 2),
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
    return Column(
      children: [
        // Logo animé avec effet 3D
        AnimatedBuilder(
          animation: _logoAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Transform.rotate(
                angle: _logoRotationAnimation.value,
                child: Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(40),
                          blurRadius: 30 * _logoScaleAnimation.value,
                          spreadRadius: 8 * _logoScaleAnimation.value,
                          offset: Offset(0, 10 * _logoScaleAnimation.value),
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(20),
                          blurRadius: 50 * _logoScaleAnimation.value,
                          spreadRadius: 15 * _logoScaleAnimation.value,
                          offset: Offset(0, 20 * _logoScaleAnimation.value),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.white.withAlpha(95)],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: heightSpace.height! * 1.5),

        // Titre avec gradient et animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return AppColors.primaryGradient.createShader(bounds);
            },
            child: Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 32,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: heightSpace.height! / 2),

        // Sous-titre avec animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(10),
                  AppColors.secondary.withAlpha(10),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withAlpha(20),
                width: 1,
              ),
            ),
            child: Text(
              l10n.signInToContinue,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
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
                  // Champ email
                  KartiaEmailField(
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
                  SizedBox(height: heightSpace.height!),

                  // Champ mot de passe
                  KartiaPasswordField(
                    controller: _passwordController,
                    labelText: l10n.password,
                    hintText: l10n.passwordHint,
                    enabled: !isLoading,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return l10n.validationPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: heightSpace.height! / 2),

                  // Lien mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _navigateToForgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        l10n.forgotPassword,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: heightSpace.height!),

                  // Bouton de connexion avec animation
                  KartiaButton(
                    text: l10n.signIn,
                    onPressed: isLoading ? null : _handleLogin,
                    isLoading: isLoading,
                    width: double.infinity,
                    size: KartiaButtonSize.large,
                    backgroundColor: AppColors.primary,
                  ),
                ],
              ),
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

        return ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              // Divider avec texte
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
                        l10n.orContinueWith,
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
              SizedBox(height: heightSpace.height! * 1.5),

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
                      borderColor: AppColors.primaryPurple,
                      textColor: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: heightSpace.height!),

              // Connexion anonyme avec style amélioré
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withAlpha(10),
                      AppColors.primaryPurple.withAlpha(10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withAlpha(30)),
                ),
                child: KartiaButton(
                  text: l10n.continueAsGuest,
                  icon: Icons.person_outline,
                  onPressed: isLoading ? null : _handleAnonymousSignIn,
                  type: KartiaButtonType.text,
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.secondary,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(KartiaLocalizations l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          // Lien vers l'inscription
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
                  l10n.noAccount,
                  style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                ),
                TextButton(
                  onPressed: _navigateToRegister,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.signUp,
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

          // Copyright
          SizedBox(height: heightSpace.height!),
          Text(
            l10n.copyright,
            style: TextStyle(
              color: AppColors.mediumGrey.withAlpha(80),
              fontSize: 11,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

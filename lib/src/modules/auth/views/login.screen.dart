import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
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
                AppColors.primary.withAlpha(10),
                AppColors.secondary.withAlpha(5),
                Colors.white,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(fixPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: heightSpace.height! * 2),
                        _buildHeader(),
                        SizedBox(height: heightSpace.height! * 3),
                        _buildLoginForm(),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildAlternativeSignInMethods(),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo avec animation
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: heightSpace.height!),

        // Titre et sous-titre
        Text(
          'Bienvenue !',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: heightSpace.height! / 2),
        Text(
          'Connectez-vous pour continuer',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.mediumGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ email
              KartiaEmailField(
                controller: _emailController,
                labelText: 'Adresse email',
                hintText: 'exemple@email.com',
                enabled: !isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!Validators.isValidEmail(value!)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSpace.height!),

              // Champ mot de passe
              KartiaPasswordField(
                controller: _passwordController,
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                enabled: !isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer votre mot de passe';
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
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: heightSpace.height!),

              // Bouton de connexion
              KartiaButton(
                text: 'Se connecter',
                onPressed: isLoading ? null : _handleLogin,
                isLoading: isLoading,
                width: double.infinity,
                size: KartiaButtonSize.large,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativeSignInMethods() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Column(
          children: [
            // Divider avec texte
            Row(
              children: [
                Expanded(
                  child: Divider(color: AppColors.lightGrey, thickness: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ou continuer avec',
                    style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Divider(color: AppColors.lightGrey, thickness: 1),
                ),
              ],
            ),
            SizedBox(height: heightSpace.height!),

            // Boutons d'authentification alternative
            Row(
              children: [
                // Google Sign In
                /* Expanded(
                  child: KartiaButton(
                    text: 'Google',
                    icon: Icons.g_mobiledata,
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    type: KartiaButtonType.outline,
                    size: KartiaButtonSize.large,
                  ),
                ),*/
                SizedBox(width: widthSpace.width!),

                // Phone Auth
                Expanded(
                  child: KartiaButton(
                    text: 'Téléphone',
                    icon: Icons.phone,
                    onPressed: isLoading ? null : _navigateToPhoneAuth,
                    type: KartiaButtonType.outline,
                    size: KartiaButtonSize.large,
                  ),
                ),
              ],
            ),
            SizedBox(height: heightSpace.height!),

            // Connexion anonyme
            KartiaButton(
              text: 'Continuer en tant qu\'invité',
              onPressed: isLoading ? null : _handleAnonymousSignIn,
              type: KartiaButtonType.text,
              width: double.infinity,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Lien vers l'inscription
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pas encore de compte ? ',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            TextButton(
              onPressed: _navigateToRegister,
              child: Text(
                'S\'inscrire',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Version de l'app ou autres infos
        SizedBox(height: heightSpace.height!),
        Text(
          '© 2025 Kartia. Tous droits réservés.',
          style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        KartiaSnackbar.show(
          context,
          message: 'Veuillez accepter les conditions d\'utilisation',
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

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(const AuthSignInWithGoogleRequested());
  }

  void _navigateToLogin() {
    context.pop();
  }

  void _navigateToPhoneAuth() {
    context.pushNamed(AppRoutes.phoneAuth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
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
          } else if (state.isAuthenticated) {
            // Afficher un message de succès

            KartiaSnackbar.show(
              context,
              message: 'Bienvenue ${state.user?.displayName ?? ''} !',
              type: SnackbarType.success,
            );
            context.pushNamedAndRemoveUntil(AppRoutes.home);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary.withAlpha(10),
                AppColors.primary.withAlpha(5),
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
                        SizedBox(height: heightSpace.height!),
                        _buildHeader(),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildRegisterForm(),
                        SizedBox(height: heightSpace.height! * 2),
                        _buildAlternativeSignInMethods(),
                        SizedBox(height: heightSpace.height!),
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
        // Logo plus petit que sur la page de connexion
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withAlpha(30),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: heightSpace.height!),

        // Titre et sous-titre
        Text(
          'Créer un compte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: heightSpace.height! / 2),
        Text(
          'Rejoignez-nous dès maintenant',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.mediumGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ nom d'affichage
              KartiaTextField(
                controller: _displayNameController,
                labelText: 'Nom complet (optionnel)',
                hintText: 'Jean Dupont',
                prefixIcon: Icons.person_outline,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: heightSpace.height!),

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
                hintText: 'Minimum 6 caractères',
                enabled: !isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (!Validators.isValidPassword(value!)) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSpace.height!),

              // Champ confirmation mot de passe
              KartiaPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Confirmer le mot de passe',
                hintText: 'Retapez votre mot de passe',
                enabled: !isLoading,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez confirmer votre mot de passe';
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
              SizedBox(height: heightSpace.height!),

              // Case à cocher conditions d'utilisation
              Row(
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
                              color: AppColors.mediumGrey,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'J\'accepte les '),
                              TextSpan(
                                text: 'conditions d\'utilisation',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' et la '),
                              TextSpan(
                                text: 'politique de confidentialité',
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
              SizedBox(height: heightSpace.height!),

              // Bouton d'inscription
              KartiaButton(
                text: 'S\'inscrire',
                onPressed: isLoading ? null : _handleRegister,
                isLoading: isLoading,
                width: double.infinity,
                size: KartiaButtonSize.large,
                backgroundColor: AppColors.secondary,
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
                    'ou s\'inscrire avec',
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
                Expanded(
                  child: KartiaButton(
                    text: 'Google',
                    icon: Icons.g_mobiledata,
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    type: KartiaButtonType.outline,
                    size: KartiaButtonSize.large,
                    borderColor: AppColors.secondary,
                    textColor: AppColors.secondary,
                  ),
                ),
                SizedBox(width: widthSpace.width!),

                // Phone Auth
                Expanded(
                  child: KartiaButton(
                    text: 'Téléphone',
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

  Widget _buildFooter() {
    return Column(
      children: [
        // Lien vers la connexion
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Déjà un compte ? ',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                'Se connecter',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

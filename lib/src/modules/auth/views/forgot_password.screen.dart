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

/// Page de récupération de mot de passe
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _emailSent = false;

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
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _handleSendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthPasswordResetRequested(email: _emailController.text.trim()),
      );
    }
  }

  void _navigateToLogin() {
    context.pop();
  }

  void _resetForm() {
    setState(() {
      _emailSent = false;
    });
    _emailController.clear();
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
        title: Text(
          'Récupération',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
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
          } else if (state.status == AuthStatus.unauthenticated &&
              !state.isLoading) {
            // Email envoyé avec succès
            setState(() {
              _emailSent = true;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.error.withAlpha(10),
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
                        SizedBox(height: heightSpace.height! * 3),
                        _buildHeader(),
                        SizedBox(height: heightSpace.height! * 3),
                        if (_emailSent)
                          _buildSuccessContent()
                        else
                          _buildForm(),
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
        // Icône de récupération
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.warning, AppColors.error],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withAlpha(30),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 50,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: heightSpace.height!),

        Text(
          _emailSent ? 'Email envoyé !' : 'Mot de passe oublié ?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _emailSent ? AppColors.success : AppColors.warning,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: heightSpace.height! / 2),

        if (_emailSent) ...[
          Text(
            'Nous avons envoyé un lien de récupération à',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mediumGrey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            _emailController.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Text(
            'Entrez votre email pour recevoir un lien de récupération',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mediumGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildForm() {
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
                autofocus: true,
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
              SizedBox(height: heightSpace.height! * 2),

              // Bouton envoyer
              KartiaButton(
                text: 'Envoyer le lien',
                onPressed: isLoading ? null : _handleSendResetEmail,
                isLoading: isLoading,
                width: double.infinity,
                size: KartiaButtonSize.large,
                backgroundColor: AppColors.warning,
              ),
              SizedBox(height: heightSpace.height!),

              // Note informative
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un email avec un lien de récupération sera envoyé à cette adresse.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Message de succès détaillé
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withAlpha(30)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'Vérifiez votre boîte mail',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe.',
                style: TextStyle(color: AppColors.success, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: heightSpace.height! * 2),

        // Boutons d'action
        Column(
          children: [
            // Bouton renvoyer
            KartiaButton(
              text: 'Renvoyer l\'email',
              onPressed: _handleSendResetEmail,
              type: KartiaButtonType.outline,
              width: double.infinity,
              size: KartiaButtonSize.large,
              borderColor: AppColors.success,
              textColor: AppColors.success,
            ),
            SizedBox(height: heightSpace.height!),

            // Bouton essayer avec un autre email
            KartiaButton(
              text: 'Essayer avec un autre email',
              onPressed: _resetForm,
              type: KartiaButtonType.text,
              textColor: AppColors.mediumGrey,
            ),
          ],
        ),
        SizedBox(height: heightSpace.height!),

        // Instructions supplémentaires
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Vous ne trouvez pas l\'email ?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Vérifiez votre dossier spam\n'
                '• Assurez-vous que l\'adresse email est correcte\n'
                '• L\'email peut prendre quelques minutes à arriver',
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Retour à la connexion
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vous vous souvenez ? ',
              style: TextStyle(color: AppColors.mediumGrey),
            ),
            TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                'Se connecter',
                style: TextStyle(
                  color: AppColors.primary,
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

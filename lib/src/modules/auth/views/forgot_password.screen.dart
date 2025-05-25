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
  late AnimationController _iconAnimationController;
  late AnimationController _successAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successFadeAnimation;

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

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _iconRotationAnimation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _successFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeIn,
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
      if (mounted) _iconAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _iconAnimationController.dispose();
    _successAnimationController.dispose();
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
    _successAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.warning),
          onPressed: _navigateToLogin,
        ),
        title: Text(
          l10n.forgotPasswordTitle,
          style: TextStyle(
            color: AppColors.warning,
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
            _successAnimationController.forward();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warning.withAlpha(15),
                AppColors.error.withAlpha(8),
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
                child: Padding(
                  padding: EdgeInsets.all(fixPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: heightSpace.height! * 3),
                        _buildHeader(l10n),
                        SizedBox(height: heightSpace.height! * 3),
                        if (_emailSent)
                          _buildSuccessContent(l10n)
                        else
                          _buildForm(l10n),
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
      ),
    );
  }

  Widget _buildHeader(KartiaLocalizations l10n) {
    return Column(
      children: [
        // Icône animée
        AnimatedBuilder(
          animation: _iconAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _iconScaleAnimation.value,
              child: Transform.rotate(
                angle: _iconRotationAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          _emailSent
                              ? [AppColors.success, AppColors.info]
                              : [AppColors.warning, AppColors.error],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: (_emailSent
                                ? AppColors.success
                                : AppColors.warning)
                            .withAlpha(40),
                        blurRadius: 30 * _iconScaleAnimation.value,
                        spreadRadius: 8 * _iconScaleAnimation.value,
                        offset: Offset(0, 10 * _iconScaleAnimation.value),
                      ),
                    ],
                  ),
                  child: Icon(
                    _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: heightSpace.height! * 1.5),

        // Titre avec animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: ShaderMask(
            key: ValueKey(_emailSent),
            shaderCallback: (bounds) {
              return LinearGradient(
                colors:
                    _emailSent
                        ? [AppColors.success, AppColors.info]
                        : [AppColors.warning, AppColors.error],
              ).createShader(bounds);
            },
            child: Text(
              _emailSent ? l10n.emailSent : l10n.resetPassword,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: heightSpace.height!),

        // Sous-titre avec animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Container(
            key: ValueKey('subtitle_$_emailSent'),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _emailSent
                        ? [
                          AppColors.success.withAlpha(10),
                          AppColors.info.withAlpha(10),
                        ]
                        : [
                          AppColors.warning.withAlpha(10),
                          AppColors.error.withAlpha(10),
                        ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (_emailSent ? AppColors.success : AppColors.warning)
                    .withAlpha(30),
              ),
            ),
            child: Column(
              children: [
                if (_emailSent) ...[
                  Text(
                    l10n.emailSentSuccess,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    _emailController.text,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    l10n.enterEmailForReset,
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(KartiaLocalizations l10n) {
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
                // Champ email
                KartiaEmailField(
                  controller: _emailController,
                  labelText: l10n.email,
                  hintText: l10n.emailHint,
                  enabled: !isLoading,
                  autofocus: true,
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
                SizedBox(height: heightSpace.height! * 2),

                // Bouton envoyer
                KartiaButton(
                  text: l10n.sendLink,
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
                          l10n.resetLinkWillBeSent,
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
          ),
        );
      },
    );
  }

  Widget _buildSuccessContent(KartiaLocalizations l10n) {
    return FadeTransition(
      opacity: _successFadeAnimation,
      child: ScaleTransition(
        scale: _successScaleAnimation,
        child: Column(
          children: [
            // Message de succès détaillé
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withAlpha(30)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withAlpha(10),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    l10n.checkEmail,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    l10n.clickLinkInEmail,
                    style: TextStyle(color: AppColors.success, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: heightSpace.height! * 2),

            // Boutons d'action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow2,
                    blurRadius: 15,
                    spreadRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bouton renvoyer
                  KartiaButton(
                    text: l10n.resendEmail,
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
                    text: l10n.tryAnotherEmail,
                    onPressed: _resetForm,
                    type: KartiaButtonType.text,
                    textColor: AppColors.mediumGrey,
                  ),
                ],
              ),
            ),
            SizedBox(height: heightSpace.height!),

            // Instructions supplémentaires
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGrey.withAlpha(50)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: AppColors.darkGrey,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        l10n.cantFindEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    l10n.emailInstructions,
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(KartiaLocalizations l10n) {
    return Column(
      children: [
        // Retour à la connexion
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
                l10n.rememberPassword,
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
                    color: AppColors.primary,
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

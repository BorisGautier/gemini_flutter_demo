import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Écran de vérification d'email
class EmailVerificationScreen extends StatefulWidget {
  final UserModel user;

  const EmailVerificationScreen({super.key, required this.user});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  Timer? _checkTimer;
  bool _isCheckingVerification = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startPeriodicCheck();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
  }

  void _startPeriodicCheck() {
    // Vérifier la vérification de l'email toutes les 3 secondes
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      // Recharger l'utilisateur Firebase pour obtenir le statut le plus récent
      await FirebaseAuth.instance.currentUser?.reload();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        // Email vérifié ! Déclencher un changement d'état
        // ignore: use_build_context_synchronously
        context.read<AuthBloc>().add(
          AuthUserChanged(
            UserModel(
              uid: widget.user.uid,
              email: widget.user.email,
              displayName: widget.user.displayName,
              photoURL: widget.user.photoURL,
              phoneNumber: widget.user.phoneNumber,
              emailVerified: true, // ✅ Maintenant vérifié
              isAnonymous: widget.user.isAnonymous,
              creationTime: widget.user.creationTime,
              lastSignInTime: widget.user.lastSignInTime,
            ),
          ),
        );

        _checkTimer?.cancel();
      }
    } catch (e) {
      // Ignorer les erreurs de vérification
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  void _resendVerificationEmail() {
    final l10n = KartiaLocalizations.of(context);

    context.read<AuthBloc>().add(const AuthSendEmailVerificationRequested());
    KartiaSnackbar.show(
      context,
      message: l10n.emailVerificationSent, // ✅ UTILISER LA TRADUCTION
      type: SnackbarType.success,
    );
  }

  void _signOut() {
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.info.withAlpha(10),
              AppColors.primary.withAlpha(5),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(fixPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Icône animée
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.info, AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.info.withAlpha(30),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mark_email_unread,
                            size: 60,
                            color: AppColors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: heightSpace.height! * 2),

                  // Titre
                  Text(
                    l10n.checkEmail, // ✅ UTILISER LA TRADUCTION
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: heightSpace.height!),

                  // Message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(10),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.info.withAlpha(30)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.emailSentSuccess, // ✅ UTILISER LA TRADUCTION
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.user.email ?? '',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          l10n.clickLinkInEmail, // ✅ UTILISER LA TRADUCTION
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: heightSpace.height! * 2),

                  // Indicateur de vérification
                  if (_isCheckingVerification)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.success,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            l10n.verification, // ✅ UTILISER LA TRADUCTION
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: heightSpace.height! * 2),

                  // Bouton renvoyer
                  KartiaButton(
                    text: l10n.resendEmail, // ✅ UTILISER LA TRADUCTION
                    onPressed: _resendVerificationEmail,
                    type: KartiaButtonType.outline,
                    borderColor: AppColors.info,
                    textColor: AppColors.info,
                    width: double.infinity,
                  ),

                  SizedBox(height: heightSpace.height!),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.darkGrey,
                          size: 20,
                        ),
                        SizedBox(height: 8),
                        Text(
                          l10n.emailVerificationInstructions, // ✅ NOUVEAU
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bouton déconnexion
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      l10n.signOut, // ✅ UTILISER LA TRADUCTION
                      style: TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),

                  SizedBox(height: heightSpace.height!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

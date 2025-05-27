import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';
import 'package:kartia/src/widgets/kartia_texfield.widget.dart';

/// Page d'authentification par numéro de téléphone
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with TickerProviderStateMixin {
  final _phoneFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  // Variable pour stocker le numéro complet avec indicatif
  String _completePhoneNumber = '';

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _iconAnimationController;
  late AnimationController _transitionAnimationController;
  late AnimationController _timerAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<Offset> _transitionSlideAnimation;
  late Animation<double> _transitionFadeAnimation;
  late Animation<double> _timerAnimation;

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

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

    _transitionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 60),
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

    _iconRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _transitionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _transitionAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _transitionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerAnimationController, curve: Curves.linear),
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
    _phoneController.dispose();
    _codeController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _iconAnimationController.dispose();
    _transitionAnimationController.dispose();
    _timerAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timerAnimationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
        _timerAnimationController.reset();
      }
    });
  }

  void _handleSendCode() {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthVerifyPhoneNumberRequested(phoneNumber: _completePhoneNumber),
      );
      _startTimer();
    }
  }

  void _handleVerifyCode(String verificationId) {
    if (_codeFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInWithPhoneNumberRequested(
          verificationId: verificationId,
          smsCode: _codeController.text.trim(),
        ),
      );
    }
  }

  void _handleResendCode() {
    if (_canResend) {
      _handleSendCode();
    }
  }

  void _navigateBack() {
    context.pop();
  }

  // ✅ CORRECTION: Méthode pour revenir à l'étape du numéro de téléphone
  void _backToPhoneNumber() {
    // Effacer l'erreur et revenir à l'état initial
    context.read<AuthBloc>().add(const AuthErrorCleared());
    _codeController.clear();
    _timer?.cancel();
    _timerAnimationController.reset();
    _transitionAnimationController.reverse();
    setState(() {
      _canResend = false;
      _remainingSeconds = 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryPurple),
          onPressed: _navigateBack,
        ),
        title: Text(
          l10n.phoneAuth,
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // ✅ CORRECTION: Gestion améliorée des erreurs
          if (state.hasError) {
            // Afficher l'erreur dans un dialog plutôt qu'un snackbar
            _showErrorDialog(context, l10n, state.errorMessage!);
          } else if (state.isAuthenticated) {
            KartiaSnackbar.show(
              context,
              message: 'Bienvenue ${state.user?.displayName ?? 'utilisateur'}',
              type: SnackbarType.success,
            );
            context.pushNamedAndRemoveUntil(AppRoutes.home);
          } else if (state.isPhoneCodeSent) {
            _transitionAnimationController.forward();
            KartiaSnackbar.show(
              context,
              message: l10n.codeWillBeSent,
              type: SnackbarType.info,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withAlpha(15),
                AppColors.primary.withAlpha(8),
                AppColors.secondary.withAlpha(5),
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
                        SizedBox(height: heightSpace.height! * 2),
                        _buildHeader(l10n),
                        SizedBox(height: heightSpace.height! * 3),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state.isPhoneCodeSent &&
                                state.verificationId != null) {
                              return _buildCodeVerificationForm(
                                l10n,
                                state.verificationId!,
                              );
                            }
                            return _buildPhoneNumberForm(l10n);
                          },
                        ),
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

  // ✅ CORRECTION: Nouvelle méthode pour afficher les erreurs dans un dialog
  void _showErrorDialog(
    BuildContext context,
    KartiaLocalizations l10n,
    String errorMessage,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.error_outline, color: AppColors.error),
                ),
                SizedBox(width: 12),
                const Text('Erreur'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Effacer l'erreur
                  context.read<AuthBloc>().add(const AuthErrorCleared());
                },
                child: Text('OK'),
              ),
            ],
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
                      colors: [AppColors.primaryPurple, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withAlpha(40),
                        blurRadius: 30 * _iconScaleAnimation.value,
                        spreadRadius: 8 * _iconScaleAnimation.value,
                        offset: Offset(0, 10 * _iconScaleAnimation.value),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: heightSpace.height! * 1.5),

        // Titre avec animation conditionnelle
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Column(
                key: ValueKey(state.isPhoneCodeSent),
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primary],
                      ).createShader(bounds);
                    },
                    child: Text(
                      state.isPhoneCodeSent
                          ? l10n.verification
                          : l10n.yourNumber,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 28,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: heightSpace.height!),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPurple.withAlpha(10),
                          AppColors.primary.withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPurple.withAlpha(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (state.isPhoneCodeSent) ...[
                          Text(
                            l10n.enterCodeReceived,
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            _completePhoneNumber,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Text(
                            l10n.phoneWillReceiveCode,
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhoneNumberForm(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state.isLoading || state.isPhoneVerificationInProgress;

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
            key: _phoneFormKey,
            child: Column(
              children: [
                // Champ numéro de téléphone avec intl_phone_field
                IntlPhoneField(
                  controller: _phoneController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    labelStyle: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: '6XX XXX XXX',
                    hintStyle: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple.withAlpha(30),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple.withAlpha(30),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryPurple.withAlpha(5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                  initialCountryCode: 'CM', // Cameroun par défaut
                  dropdownTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                  flagsButtonPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  showDropdownIcon: true,
                  dropdownIcon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryPurple,
                  ),
                  invalidNumberMessage: l10n.validationPhoneInvalid,
                  // Désactiver la validation automatique pendant la saisie
                  autovalidateMode: AutovalidateMode.disabled,
                  showCountryFlag: true,
                  onChanged: (phone) {
                    // Capturer le numéro complet sans déclencher d'exception
                    setState(() {
                      _completePhoneNumber = phone.completeNumber;
                    });
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return l10n.validationPhoneRequired;
                    }
                    // Validation plus permissive - vérifier seulement la longueur minimale
                    if (phone.number.length < 8) {
                      return l10n.validationPhoneInvalid;
                    }
                    // Optionnel : validation plus stricte seulement à la soumission
                    try {
                      if (!phone.isValidNumber()) {
                        return l10n.validationPhoneInvalid;
                      }
                    } catch (e) {
                      // Ignorer les exceptions de validation pendant la saisie
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSpace.height! * 2),

                // Bouton envoyer le code
                KartiaButton(
                  text: l10n.sendCode,
                  onPressed: isLoading ? null : _handleSendCode,
                  isLoading: isLoading,
                  width: double.infinity,
                  size: KartiaButtonSize.large,
                  backgroundColor: AppColors.primaryPurple,
                ),
                SizedBox(height: heightSpace.height!),

                // Note informative
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryPurple.withAlpha(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.codeWillBeSent,
                          style: TextStyle(
                            color: AppColors.primaryPurple,
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

  Widget _buildCodeVerificationForm(
    KartiaLocalizations l10n,
    String verificationId,
  ) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return SlideTransition(
          position: _transitionSlideAnimation,
          child: FadeTransition(
            opacity: _transitionFadeAnimation,
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
                key: _codeFormKey,
                child: Column(
                  children: [
                    // Champ code de vérification avec design amélioré
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryPurple.withAlpha(5),
                            AppColors.primary.withAlpha(5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryPurple.withAlpha(30),
                        ),
                      ),
                      child: KartiaTextField(
                        controller: _codeController,
                        labelText: l10n.verificationCode,
                        hintText: l10n.verificationCodeHint,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        maxLength: 6,
                        textInputAction: TextInputAction.done,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                          color: AppColors.primaryPurple,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return l10n.validationCodeRequired;
                          }
                          if (value!.length != 6) {
                            return l10n.validationCodeLength;
                          }
                          return null;
                        },
                        onSubmitted: (_) => _handleVerifyCode(verificationId),
                      ),
                    ),
                    SizedBox(height: heightSpace.height! * 1.5),

                    // Timer et bouton renvoyer avec animation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _canResend
                                ? AppColors.success.withAlpha(10)
                                : AppColors.warning.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_canResend
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withAlpha(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_canResend) ...[
                            // Indicateur de progression circulaire
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: AnimatedBuilder(
                                animation: _timerAnimation,
                                builder: (context, child) {
                                  return CircularProgressIndicator(
                                    value: _timerAnimation.value,
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.warning,
                                    ),
                                    backgroundColor: AppColors.warning
                                        .withAlpha(30),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              l10n.resendCodeIn(_remainingSeconds),
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.refresh,
                              color: AppColors.success,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            TextButton(
                              onPressed: _handleResendCode,
                              child: Text(
                                l10n.resendCode,
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: heightSpace.height! * 1.5),

                    // Bouton vérifier
                    KartiaButton(
                      text: l10n.verify,
                      onPressed:
                          isLoading
                              ? null
                              : () => _handleVerifyCode(verificationId),
                      isLoading: isLoading,
                      width: double.infinity,
                      size: KartiaButtonSize.large,
                      backgroundColor: AppColors.primaryPurple,
                    ),
                    SizedBox(height: heightSpace.height!),

                    // ✅ CORRECTION: Bouton modifier le numéro amélioré
                    KartiaButton(
                      text: l10n.changeNumber,
                      onPressed:
                          isLoading
                              ? null
                              : _backToPhoneNumber, // Utiliser la nouvelle méthode
                      type: KartiaButtonType.text,
                      textColor: AppColors.mediumGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

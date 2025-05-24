import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/validators.util.dart';
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

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _phoneController.dispose();
    _codeController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();

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
      }
    });
  }

  void _handleSendCode() {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      final phoneNumber = '+237${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(
        AuthVerifyPhoneNumberRequested(phoneNumber: phoneNumber),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: _navigateBack,
        ),
        title: Text(
          'Authentification par téléphone',
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
          } else if (state.isAuthenticated) {
            KartiaSnackbar.show(
              context,
              message: 'Bienvenue ${state.user?.displayName ?? 'utilisateur'}',
              type: SnackbarType.success,
            );
            context.pushNamedAndRemoveUntil(AppRoutes.home);
          } else if (state.isPhoneCodeSent) {
            KartiaSnackbar.show(
              context,
              message:
                  'Un code de vérification a été envoyé à +237 ${_phoneController.text}',
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
                AppColors.primaryPurple.withAlpha(10),
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
                        SizedBox(height: heightSpace.height! * 2),
                        _buildHeader(),
                        SizedBox(height: heightSpace.height! * 3),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state.isPhoneCodeSent &&
                                state.verificationId != null) {
                              return _buildCodeVerificationForm(
                                state.verificationId!,
                              );
                            }
                            return _buildPhoneNumberForm();
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Icône de téléphone
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryPurple, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withAlpha(30),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(Icons.phone_android, size: 50, color: AppColors.white),
        ),
        SizedBox(height: heightSpace.height!),

        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.isPhoneCodeSent) {
              return Column(
                children: [
                  Text(
                    'Vérification',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: heightSpace.height! / 2),
                  Text(
                    'Entrez le code reçu par SMS',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: heightSpace.height! / 2),
                  Text(
                    '+237 ${_phoneController.text}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return Column(
              children: [
                Text(
                  'Votre numéro',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: heightSpace.height! / 2),
                Text(
                  'Nous vous enverrons un code de vérification',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.mediumGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhoneNumberForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading =
            state.isLoading || state.isPhoneVerificationInProgress;

        return Form(
          key: _phoneFormKey,
          child: Column(
            children: [
              // Champ numéro de téléphone
              Row(
                children: [
                  // Indicatif pays
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇨🇲', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          '+237',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: widthSpace.width!),

                  // Champ de saisie
                  Expanded(
                    child: KartiaTextField(
                      controller: _phoneController,
                      hintText: '6XX XXX XXX',
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      maxLength: 9,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (!Validators.isValidTelephone(value!)) {
                          return 'Numéro invalide (9 chiffres requis)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: heightSpace.height! * 2),

              // Bouton envoyer le code
              KartiaButton(
                text: 'Envoyer le code',
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
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un code de vérification sera envoyé par SMS à ce numéro.',
                        style: TextStyle(
                          color: AppColors.primary,
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

  Widget _buildCodeVerificationForm(String verificationId) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Form(
          key: _codeFormKey,
          child: Column(
            children: [
              // Champ code de vérification
              KartiaTextField(
                controller: _codeController,
                labelText: 'Code de vérification',
                hintText: 'XXXXXX',
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer le code';
                  }
                  if (value!.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
                onSubmitted: (_) => _handleVerifyCode(verificationId),
              ),
              SizedBox(height: heightSpace.height!),

              // Timer et bouton renvoyer
              if (!_canResend) ...[
                Text(
                  'Renvoyer le code dans ${_remainingSeconds}s',
                  style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                ),
              ] else ...[
                TextButton(
                  onPressed: _handleResendCode,
                  child: Text(
                    'Renvoyer le code',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              SizedBox(height: heightSpace.height!),

              // Bouton vérifier
              KartiaButton(
                text: 'Vérifier',
                onPressed:
                    isLoading ? null : () => _handleVerifyCode(verificationId),
                isLoading: isLoading,
                width: double.infinity,
                size: KartiaButtonSize.large,
                backgroundColor: AppColors.primaryPurple,
              ),
              SizedBox(height: heightSpace.height!),

              // Bouton modifier le numéro
              KartiaButton(
                text: 'Modifier le numéro',
                onPressed:
                    isLoading
                        ? null
                        : () {
                          context.read<AuthBloc>().add(
                            const AuthErrorCleared(),
                          );
                          _codeController.clear();
                          _timer?.cancel();
                          setState(() {
                            _canResend = false;
                            _remainingSeconds = 60;
                          });
                        },
                type: KartiaButtonType.text,
                textColor: AppColors.mediumGrey,
              ),
            ],
          ),
        );
      },
    );
  }
}

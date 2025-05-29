import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

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

  @override
  void dispose() {
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
            child: BlocBuilder<GpsBloc, GpsState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.all(fixPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Icône GPS animée
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
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(30),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                state.isGpsEnabled
                                    ? Icons.location_on
                                    : Icons.location_off,
                                size: 60,
                                color: AppColors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: heightSpace.height! * 2),

                      // Titre et message
                      Text(
                        state.isGpsEnabled ? l10n.gpsAccess : l10n.enableGps,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: heightSpace.height!),

                      // Message d'état
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              state.isGpsEnabled
                                  ? AppColors.success.withAlpha(10)
                                  : AppColors.warning.withAlpha(10),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color:
                                state.isGpsEnabled
                                    ? AppColors.success.withAlpha(30)
                                    : AppColors.warning.withAlpha(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              state.isGpsEnabled
                                  ? l10n
                                      .gpsEnabledMessage // ✅ NOUVEAU
                                  : l10n.gpsDisabledMessage, // ✅ NOUVEAU
                              style: TextStyle(
                                color:
                                    state.isGpsEnabled
                                        ? AppColors.success
                                        : AppColors.warning,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: heightSpace.height! * 2),

                      // Bouton d'action
                      if (state.isGpsEnabled && !state.isGpsPermissionGranted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final gpsBloc = BlocProvider.of<GpsBloc>(context);
                              gpsBloc.askGpsAccess();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  l10n.askAccess,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // État de chargement si en cours de traitement
                      if (state.isLoading)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withAlpha(10),
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
                                    AppColors.info,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                l10n.permissionRequestInProgress, // ✅ NOUVEAU
                                style: TextStyle(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(),

                      // Instructions en bas
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
                              l10n.locationPermissionRequired, // ✅ NOUVEAU
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: heightSpace.height!),

                      // Debug info (à supprimer en production)
                      if (const bool.fromEnvironment('dart.vm.product') ==
                          false)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withAlpha(10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Debug: GPS=${state.isGpsEnabled}, Permission=${state.isGpsPermissionGranted}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

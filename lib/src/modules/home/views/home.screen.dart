// lib/src/modules/home/views/home.screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/themes.util.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/home/bloc/home_bloc.dart';
import 'package:kartia/src/modules/home/bloc/home_event.dart';
import 'package:kartia/src/modules/home/bloc/home_state.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_loading.widget.dart';

/// Écran d'accueil principal de l'application avec design responsif et synchronisation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _staggerAnimationController;
  late AnimationController _fabAnimationController;

  // Animations principales
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  // Animations échelonnées pour les sections
  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _welcomeSlideAnimation;
  late Animation<Offset> _actionsSlideAnimation;
  late Animation<Offset> _activitySlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Initialiser le HomeBloc
    context.read<HomeBloc>().add(const HomeInitialized());

    // Déclencher la synchronisation des données utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = context.read<AuthBloc>();
      if (authBloc.state.isAuthenticated) {
        authBloc.add(const AuthPeriodicSyncTriggered());
      }
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Animations échelonnées
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
      ),
    );

    _welcomeSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _actionsSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _activitySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimations() {
    _fadeAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _staggerAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _staggerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // Méthodes d'interaction
  void _onItemTapped(int index) {
    context.read<HomeBloc>().add(BottomNavItemSelected(index));
  }

  void _navigateToProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _toggleTheme() {
    final currentTheme = context.read<AppBloc>().state.themeData;
    final isDark = currentTheme!.brightness == Brightness.dark;

    context.read<AppBloc>().add(
      ChangeTheme(isDark ? AppTheme.lightTheme : AppTheme.darkTheme),
    );
  }

  void _toggleLanguage() {
    final currentLocale = context.read<AppBloc>().state.locale;

    if (currentLocale?.languageCode == 'fr') {
      context.read<AppBloc>().add(const ChangeLanguage(Locale('en', 'US')));
    } else {
      context.read<AppBloc>().add(const ChangeLanguage(Locale('fr', 'FR')));
    }
  }

  void _showComingSoon(KartiaLocalizations l10n, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoonMessage(feature)),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _syncUserData() {
    context.read<AuthBloc>().add(const AuthSyncUserData());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronisation des données en cours...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Afficher des notifications lors des synchronisations
        if (state.firestoreUser != null) {
          final lastUpdate = state.firestoreUser!.updatedAt;
          if (DateTime.now().difference(lastUpdate).inSeconds < 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Données mises à jour'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                backgroundColor: Colors.green.shade600,
              ),
            );
          }
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Scaffold(
              backgroundColor: AppColors.backgroundColor(context),
              body: Center(
                child: KartiaLoading.circular(
                  size: KartiaLoadingSize.large,
                  message: 'Chargement...',
                  color: AppColors.primary,
                ),
              ),
            );
          }

          if (state is HomeError) {
            return Scaffold(
              backgroundColor: AppColors.backgroundColor(context),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurfaceColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceSecondaryColor(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const HomeInitialized());
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is HomeLoaded) {
            return Scaffold(
              backgroundColor: AppColors.backgroundColor(context),
              body: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(context, state, l10n),
                ),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(
                context,
                state,
                l10n,
              ),
              floatingActionButton: ScaleTransition(
                scale: _fabScaleAnimation,
                child: FloatingActionButton(
                  onPressed: () => _onItemTapped(1),
                  backgroundColor: AppColors.primaryOrange,
                  child: Icon(Icons.explore_rounded, color: AppColors.white),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HomeLoaded state,
    KartiaLocalizations l10n,
  ) {
    switch (state.selectedTabIndex) {
      case 0:
        return _buildHomeTab(context, state, l10n);
      case 1:
        return _buildServicesTab(context, state, l10n);
      case 2:
        return _buildSettingsTab(context, l10n);
      default:
        return _buildHomeTab(context, state, l10n);
    }
  }

  Widget _buildHomeTab(
    BuildContext context,
    HomeLoaded state,
    KartiaLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? AppColors.darkBackground : AppColors.primary.withAlpha(20),
            isDark
                ? AppColors.darkSurface.withAlpha(50)
                : AppColors.primaryOrange.withAlpha(10),
            AppColors.backgroundColor(context),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const RefreshRequested());
            context.read<AuthBloc>().add(const AuthSyncUserData());
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(fixPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideTransition(
                  position: _headerSlideAnimation,
                  child: _buildHeader(l10n),
                ),
                SizedBox(height: heightSpace.height! * 2),
                SlideTransition(
                  position: _welcomeSlideAnimation,
                  child: _buildWelcomeCard(l10n),
                ),
                SizedBox(height: heightSpace.height! * 2),
                SlideTransition(
                  position: _actionsSlideAnimation,
                  child: _buildQuickActions(l10n, state),
                ),
                SizedBox(height: heightSpace.height! * 2),
                SlideTransition(
                  position: _activitySlideAnimation,
                  child: _buildRecentActivity(l10n, state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final isLoading = state.isLoading;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar de l'utilisateur avec animation
              GestureDetector(
                onTap: _navigateToProfile,
                child: Hero(
                  tag: 'user_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient:
                          Theme.of(context).brightness == Brightness.dark
                              ? LinearGradient(
                                colors: [
                                  AppColors.primary.withAlpha(120),
                                  AppColors.primaryOrange.withAlpha(100),
                                ],
                              )
                              : AppColors.primaryGradient,
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.surfaceColor(context),
                      backgroundImage:
                          user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                      child:
                          user?.photoURL == null
                              ? Text(
                                user?.initials ?? 'U',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontFamily: "OpenSans-Bold",
                                ),
                              )
                              : null,
                    ),
                  ),
                ),
              ),
              SizedBox(width: widthSpace.width!),

              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.isAnonymous == true ? l10n.guest : l10n.hello,
                      style: TextStyle(
                        color: AppColors.onSurfaceSecondaryColor(context),
                        fontSize: 14,
                        fontFamily: "OpenSans",
                      ),
                    ),
                    Text(
                      user?.displayNameOrEmail ?? l10n.user,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceColor(context),
                        fontFamily: "OpenSans-Bold",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Boutons d'action avec design amélioré
              Wrap(
                spacing: 8,
                children: [
                  _buildHeaderButton(
                    icon: isLoading ? Icons.sync : Icons.sync,
                    onPressed: isLoading ? null : _syncUserData,
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                    ),
                    tooltip: 'Synchroniser',
                    isLoading: isLoading,
                  ),
                  _buildHeaderButton(
                    icon: Icons.brightness_6_rounded,
                    onPressed: _toggleTheme,
                    gradient: LinearGradient(
                      colors: [AppColors.warning, AppColors.secondaryYellow],
                    ),
                    tooltip: 'Changer le thème',
                  ),
                  _buildHeaderButton(
                    icon: Icons.language_rounded,
                    onPressed: _toggleLanguage,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primary],
                    ),
                    tooltip: 'Changer la langue',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    VoidCallback? onPressed,
    required LinearGradient gradient,
    String? tooltip,
    bool isLoading = false,
  }) {
    final button = Container(
      decoration: BoxDecoration(
        gradient:
            onPressed != null
                ? gradient
                : LinearGradient(colors: [Colors.grey, Colors.grey.shade400]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (onPressed != null ? gradient.colors.first : Colors.grey)
                .withAlpha(30),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child:
                isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                    : Icon(icon, color: AppColors.white, size: 20),
          ),
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip, child: button) : button;
  }

  Widget _buildWelcomeCard(KartiaLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            isDark
                ? LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(120),
                    AppColors.primaryOrange.withAlpha(100),
                  ],
                )
                : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(40),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.welcomeToKartia,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "OpenSans-Bold",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.discoverServices,
            style: TextStyle(
              color: AppColors.white.withAlpha(220),
              fontSize: 16,
              height: 1.4,
              fontFamily: "OpenSans",
            ),
          ),
          const SizedBox(height: 24),
          KartiaButton(
            text: l10n.explore,
            onPressed: () => _onItemTapped(1),
            type: KartiaButtonType.secondary,
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            size: KartiaButtonSize.medium,
            icon: Icons.explore_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(KartiaLocalizations l10n, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.quickActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceColor(context),
                  fontFamily: "OpenSans-Bold",
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: heightSpace.height!),

        // Layout responsif avec LayoutBuilder
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer le nombre de colonnes en fonction de la largeur
            int crossAxisCount = 2;
            if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }
            if (constraints.maxWidth > 900) {
              crossAxisCount = 4;
            }

            // Calculer la largeur disponible pour chaque carte
            final spacing = 16.0;
            final availableWidth =
                constraints.maxWidth - (spacing * (crossAxisCount - 1));
            final cardWidth = availableWidth / crossAxisCount;

            // Calculer un aspect ratio dynamique basé sur la largeur de la carte
            double childAspectRatio = 1.2;
            if (cardWidth < 160) {
              childAspectRatio = 1.0; // Plus carré pour les petites cartes
            } else if (cardWidth > 200) {
              childAspectRatio =
                  1.4; // Plus rectangulaire pour les grandes cartes
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: state.quickActions.length,
              itemBuilder: (context, index) {
                final action = state.quickActions[index];
                return _buildActionCard(
                  l10n,
                  icon: IconData(
                    int.parse(action.iconCode),
                    fontFamily: 'MaterialIcons',
                  ),
                  title: action.title,
                  subtitle: action.description,
                  gradient: LinearGradient(
                    colors:
                        action.gradientColors
                            .map((color) => Color(color))
                            .toList(),
                  ),
                  onTap: () => _showComingSoon(l10n, action.title),
                  isAvailable: action.isAvailable,
                  cardWidth: cardWidth,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesTab(
    BuildContext context,
    HomeLoaded state,
    KartiaLocalizations l10n,
  ) {
    return Container(
      color: AppColors.backgroundColor(context),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryYellow.withAlpha(30),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.apps_rounded, color: AppColors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.ourServices,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontFamily: "OpenSans-Bold",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: heightSpace.height! * 2),

              Expanded(
                child: ListView.separated(
                  itemCount: state.services.length,
                  separatorBuilder:
                      (context, index) => SizedBox(height: heightSpace.height!),
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return _buildServiceCard(
                      l10n,
                      icon: IconData(
                        int.parse(service.iconCode),
                        fontFamily: 'MaterialIcons',
                      ),
                      title: service.title,
                      description: service.description,
                      gradient: LinearGradient(
                        colors:
                            service.gradientColors
                                .map((color) => Color(color))
                                .toList(),
                      ),
                      isAvailable: service.isAvailable,
                      onTap: () => _showComingSoon(l10n, service.title),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    KartiaLocalizations l10n, {
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
    required bool isAvailable,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.white, size: 32),
            ),
            SizedBox(width: widthSpace.width!),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.onSurfaceColor(context),
                            fontFamily: "OpenSans-Bold",
                          ),
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.warning,
                                AppColors.secondaryYellow,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.comingSoon,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: "OpenSans-SemiBold",
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.onSurfaceSecondaryColor(context),
                      fontSize: 14,
                      height: 1.4,
                      fontFamily: "OpenSans",
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

  Widget _buildActionCard(
    KartiaLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
    bool isAvailable = false,
    required double cardWidth,
  }) {
    // Adapter les tailles en fonction de la largeur de la carte
    final double iconSize = cardWidth < 160 ? 16 : (cardWidth < 200 ? 18 : 20);
    final double titleFontSize =
        cardWidth < 160 ? 12 : (cardWidth < 200 ? 13 : 14);
    final double subtitleFontSize =
        cardWidth < 160 ? 9 : (cardWidth < 200 ? 10 : 11);
    final double badgeFontSize = cardWidth < 160 ? 7 : 8;
    final double padding = cardWidth < 160 ? 12 : 16;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              padding: EdgeInsets.all(cardWidth < 160 ? 8 : 12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: iconSize),
            ),

            // Espacement flexible
            const Expanded(child: SizedBox(height: 8)),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: titleFontSize,
                color: AppColors.onSurfaceColor(context),
                fontFamily: "OpenSans-SemiBold",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Sous-titre
            Expanded(
              flex: 2,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.onSurfaceSecondaryColor(context),
                  fontSize: subtitleFontSize,
                  height: 1.3,
                  fontFamily: "OpenSans",
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Badge "À venir" si nécessaire
            if (!isAvailable) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.secondaryYellow],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.comingSoon,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: badgeFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: "OpenSans-SemiBold",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(KartiaLocalizations l10n, HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.recentActivity,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceColor(context),
                  fontFamily: "OpenSans-Bold",
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: heightSpace.height!),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceSecondaryColor(
                    context,
                  ).withAlpha(30),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: AppColors.onSurfaceSecondaryColor(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.noRecentActivity,
                style: TextStyle(
                  color: AppColors.onSurfaceSecondaryColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: "OpenSans-SemiBold",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.startUsingServices,
                style: TextStyle(
                  color: AppColors.onSurfaceSecondaryColor(context),
                  fontSize: 14,
                  height: 1.4,
                  fontFamily: "OpenSans",
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab(BuildContext context, KartiaLocalizations l10n) {
    return Container(
      color: AppColors.backgroundColor(context),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withAlpha(30),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.settings,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontFamily: "OpenSans-Bold",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: heightSpace.height! * 2),

              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsSection(l10n, l10n.account, [
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.person_rounded,
                        title: l10n.profile,
                        subtitle: l10n.manageProfile,
                        onTap: _navigateToProfile,
                        gradient: AppColors.primaryGradient,
                      ),
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.sync,
                        title: 'Synchronisation',
                        subtitle: 'Synchroniser les données utilisateur',
                        onTap: _syncUserData,
                        gradient: LinearGradient(
                          colors: [AppColors.info, AppColors.primary],
                        ),
                      ),
                    ]),

                    SizedBox(height: heightSpace.height!),

                    _buildSettingsSection(l10n, l10n.appearance, [
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.brightness_6_rounded,
                        title: l10n.theme,
                        subtitle: l10n.themeDesc,
                        onTap: _toggleTheme,
                        trailing: Switch(
                          value:
                              Theme.of(context).brightness == Brightness.dark,
                          onChanged: (_) => _toggleTheme(),
                          activeColor: AppColors.warning,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning,
                            AppColors.secondaryYellow,
                          ],
                        ),
                      ),
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.language_rounded,
                        title: l10n.language,
                        subtitle: l10n.languageDesc,
                        onTap: _toggleLanguage,
                        gradient: LinearGradient(
                          colors: [AppColors.primaryPurple, AppColors.primary],
                        ),
                      ),
                    ]),

                    SizedBox(height: heightSpace.height!),

                    _buildSettingsSection(l10n, l10n.about, [
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.info_rounded,
                        title: l10n.version,
                        subtitle: '1.0.0',
                        onTap: () {},
                        gradient: LinearGradient(
                          colors: [AppColors.info, AppColors.primary],
                        ),
                      ),
                      _buildSettingsTile(
                        l10n,
                        icon: Icons.help_rounded,
                        title: l10n.help,
                        subtitle: l10n.helpDesc,
                        onTap: () => _showComingSoon(l10n, l10n.help),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryOrange,
                            AppColors.primaryPurple,
                          ],
                        ),
                      ),
                    ]),

                    // Section de débogage pour les développeurs
                    if (kDebugMode) ...[
                      SizedBox(height: heightSpace.height!),
                      _buildSettingsSection(l10n, 'Développeur', [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return _buildSettingsTile(
                              l10n,
                              icon: Icons.developer_mode,
                              title: 'Infos de synchronisation',
                              subtitle:
                                  state.firestoreUser != null
                                      ? 'Dernière sync: ${state.firestoreUser!.updatedAt.toString().substring(0, 16)}'
                                      : 'Aucune donnée Firestore',
                              onTap: () {
                                // Afficher les détails de synchronisation
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Infos de synchronisation',
                                        ),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'État Auth: ${state.status}',
                                              ),
                                              Text(
                                                'Utilisateur: ${state.user?.uid ?? 'null'}',
                                              ),
                                              Text(
                                                'Firestore: ${state.firestoreUser?.userId ?? 'null'}',
                                              ),
                                              Text(
                                                'Dernière sync: ${state.firestoreUser?.updatedAt ?? 'jamais'}',
                                              ),
                                              Text(
                                                'Localisation active: ${state.isLocationTrackingActive}',
                                              ),
                                              if (state.firestoreUser !=
                                                  null) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Version app: ${state.firestoreUser!.appInfo.version}',
                                                ),
                                                Text(
                                                  'Plateforme: ${state.firestoreUser!.appInfo.platform}',
                                                ),
                                                Text(
                                                  'OS: ${state.firestoreUser!.deviceInfo.osVersion}',
                                                ),
                                                Text(
                                                  'Langue: ${state.firestoreUser!.deviceInfo.language}',
                                                ),
                                                Text(
                                                  'Pays: ${state.firestoreUser!.currentLocation!.country}',
                                                ),
                                                if (state
                                                        .firestoreUser!
                                                        .currentLocation !=
                                                    null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Position: ${state.firestoreUser!.currentLocation!.coordinatesString}',
                                                  ),
                                                ],
                                              ],
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Fermer'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              context.read<AuthBloc>().add(
                                                const AuthSyncUserData(),
                                              );
                                            },
                                            child: const Text('Synchroniser'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              gradient: LinearGradient(
                                colors: [Colors.purple, Colors.deepPurple],
                              ),
                            );
                          },
                        ),
                        _buildSettingsTile(
                          l10n,
                          icon: Icons.logout,
                          title: 'Déconnexion',
                          subtitle: 'Se déconnecter de l\'application',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Déconnexion'),
                                    content: const Text(
                                      'Êtes-vous sûr de vouloir vous déconnecter ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.read<AuthBloc>().add(
                                            const AuthSignOutRequested(),
                                          );
                                        },
                                        child: const Text('Déconnexion'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    KartiaLocalizations l10n,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontFamily: "OpenSans-Bold",
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor(context),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    KartiaLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    required LinearGradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.onSurfaceColor(context),
                        fontFamily: "OpenSans-SemiBold",
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.onSurfaceSecondaryColor(context),
                        fontSize: 12,
                        height: 1.3,
                        fontFamily: "OpenSans",
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.onSurfaceSecondaryColor(context),
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    HomeLoaded state,
    KartiaLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: state.selectedTabIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceSecondaryColor(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: "OpenSans-SemiBold",
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: "OpenSans"),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home_rounded),
            ),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.apps_rounded),
            ),
            label: l10n.services,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.settings_rounded),
            ),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}

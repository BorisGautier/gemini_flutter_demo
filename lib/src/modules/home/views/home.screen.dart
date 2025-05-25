// lib/src/modules/home/views/home.screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/utils/themes.util.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';

/// Écran d'accueil principal de l'application
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _staggerAnimationController;
  late AnimationController _fabAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  // Animations échelonnées pour les sections
  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _welcomeSlideAnimation;
  late Animation<Offset> _actionsSlideAnimation;
  late Animation<Offset> _activitySlideAnimation;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    context.pushNamed(AppRoutes.profile);
  }

  void _toggleTheme() {
    final currentTheme = context.read<AppBloc>().state.themeData;
    final appThemes = AppThemes.appThemeData;

    if (currentTheme == appThemes[AppTheme.lightTheme]) {
      context.read<AppBloc>().add(ChangeTheme(AppTheme.darkTheme));
    } else {
      context.read<AppBloc>().add(ChangeTheme(AppTheme.lightTheme));
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigation supprimée - AppNavigationManager s'en occupe
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(l10n),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(l10n),
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(1),
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.explore_rounded, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(KartiaLocalizations l10n) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(l10n);
      case 1:
        return _buildServicesTab(l10n);
      case 2:
        return _buildSettingsTab(l10n);
      default:
        return _buildHomeTab(l10n);
    }
  }

  Widget _buildHomeTab(KartiaLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withAlpha(15),
            AppColors.secondary.withAlpha(8),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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
                child: _buildQuickActions(l10n),
              ),
              SizedBox(height: heightSpace.height! * 2),
              SlideTransition(
                position: _activitySlideAnimation,
                child: _buildRecentActivity(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KartiaLocalizations l10n) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
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
                      gradient: AppColors.primaryGradient,
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.white,
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
                        color: AppColors.mediumGrey,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      user?.displayNameOrEmail ?? l10n.user,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Boutons d'action avec design amélioré
              Row(
                children: [
                  _buildHeaderButton(
                    icon: Icons.brightness_6_rounded,
                    onPressed: _toggleTheme,
                    gradient: LinearGradient(
                      colors: [AppColors.warning, AppColors.secondaryYellow],
                    ),
                  ),
                  SizedBox(width: 8),
                  _buildHeaderButton(
                    icon: Icons.language_rounded,
                    onPressed: _toggleLanguage,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primary],
                    ),
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
    required VoidCallback onPressed,
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withAlpha(30),
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
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(KartiaLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
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
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.welcomeToKartia,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            l10n.discoverServices,
            style: TextStyle(
              color: AppColors.white.withAlpha(90),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
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

  Widget _buildQuickActions(KartiaLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
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
                    colors: [AppColors.secondary, AppColors.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                l10n.quickActions,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: heightSpace.height!),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              l10n,
              icon: Icons.map_rounded,
              title: l10n.cityAiGuide,
              subtitle: l10n.cityAiGuideDesc,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.info],
              ),
              onTap: () => _showComingSoon(l10n, l10n.cityAiGuide),
            ),
            _buildActionCard(
              l10n,
              icon: Icons.health_and_safety_rounded,
              title: l10n.santeMap,
              subtitle: l10n.santeMapDesc,
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.info],
              ),
              onTap: () => _showComingSoon(l10n, l10n.santeMap),
            ),
            _buildActionCard(
              l10n,
              icon: Icons.volunteer_activism_rounded,
              title: l10n.civact,
              subtitle: l10n.civactDesc,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.warning],
              ),
              onTap: () => _showComingSoon(l10n, l10n.civact),
            ),
            _buildActionCard(
              l10n,
              icon: Icons.shopping_cart_rounded,
              title: l10n.cartoPrix,
              subtitle: l10n.cartoPrixDesc,
              gradient: LinearGradient(
                colors: [AppColors.secondaryYellow, AppColors.warning],
              ),
              onTap: () => _showComingSoon(l10n, l10n.cartoPrix),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    KartiaLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(15),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.mediumGrey,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(KartiaLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
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
                    colors: [AppColors.primaryPurple, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                l10n.recentActivity,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: heightSpace.height!),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withAlpha(30),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: AppColors.mediumGrey,
                ),
              ),
              SizedBox(height: 20),
              Text(
                l10n.noRecentActivity,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                l10n.startUsingServices,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab(KartiaLocalizations l10n) {
    return Container(
      color: AppColors.lightBackground,
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
                      color: AppColors.secondary.withAlpha(30),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.apps_rounded, color: AppColors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      l10n.ourServices,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: heightSpace.height! * 2),

              Expanded(
                child: ListView(
                  children: [
                    _buildServiceCard(
                      l10n,
                      icon: Icons.map_rounded,
                      title: l10n.cityAiGuide,
                      description: l10n.cityAiGuideDesc,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.info],
                      ),
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      l10n,
                      icon: Icons.health_and_safety_rounded,
                      title: l10n.santeMap,
                      description: l10n.santeMapDesc,
                      gradient: LinearGradient(
                        colors: [AppColors.success, AppColors.info],
                      ),
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      l10n,
                      icon: Icons.volunteer_activism_rounded,
                      title: l10n.civact,
                      description: l10n.civactDesc,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.warning],
                      ),
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      l10n,
                      icon: Icons.shopping_cart_rounded,
                      title: l10n.cartoPrix,
                      description: l10n.cartoPrixDesc,
                      gradient: LinearGradient(
                        colors: [AppColors.secondaryYellow, AppColors.warning],
                      ),
                      isAvailable: false,
                    ),
                  ],
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow2,
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                    if (!isAvailable) ...[
                      SizedBox(width: 8),
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
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(KartiaLocalizations l10n) {
    return Container(
      color: AppColors.lightBackground,
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
                    SizedBox(width: 12),
                    Text(
                      l10n.settings,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
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
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
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
                            AppColors.secondary,
                            AppColors.primaryPurple,
                          ],
                        ),
                      ),
                    ]),
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
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
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
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
    LinearGradient? gradient,
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
                  gradient:
                      gradient ??
                      LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.white, size: 20),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.mediumGrey,
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(KartiaLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow2,
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mediumGrey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
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
                color: AppColors.primary.withAlpha(15),
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
                color: AppColors.primary.withAlpha(15),
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

// lib/src/modules/home/views/home.screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isUnauthenticated) {
          context.pushNamedAndRemoveUntil(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildServicesTab();
      case 2:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withAlpha(10), Colors.white],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(fixPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: heightSpace.height! * 2),
              _buildWelcomeCard(),
              SizedBox(height: heightSpace.height! * 2),
              _buildQuickActions(),
              SizedBox(height: heightSpace.height! * 2),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Row(
          children: [
            // Avatar de l'utilisateur
            GestureDetector(
              onTap: _navigateToProfile,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary.withAlpha(10),
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
            SizedBox(width: widthSpace.width!),

            // Informations utilisateur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.isAnonymous == true ? 'Invité' : 'Bonjour,',
                    style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                  ),
                  Text(
                    user?.displayNameOrEmail ?? 'Utilisateur',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Boutons d'action
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.brightness_6, color: AppColors.primary),
                  onPressed: _toggleTheme,
                ),
                IconButton(
                  icon: Icon(Icons.language, color: AppColors.primary),
                  onPressed: _toggleLanguage,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waving_hand, color: AppColors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Bienvenue sur Kartia !',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Découvrez nos services intelligents pour vous faciliter la vie au quotidien.',
            style: TextStyle(
              color: AppColors.white.withAlpha(90),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 20),
          KartiaButton(
            text: 'Explorer',
            onPressed: () => _onItemTapped(1),
            type: KartiaButtonType.secondary,
            backgroundColor: AppColors.white,
            textColor: AppColors.primary,
            size: KartiaButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              icon: Icons.map,
              title: 'CityAI Guide',
              subtitle: 'Navigation intelligente',
              color: AppColors.primary,
              onTap: () => _showComingSoon('CityAI Guide'),
            ),
            _buildActionCard(
              icon: Icons.health_and_safety,
              title: 'Santé Map',
              subtitle: 'Centres de santé',
              color: AppColors.success,
              onTap: () => _showComingSoon('Santé Map'),
            ),
            _buildActionCard(
              icon: Icons.volunteer_activism,
              title: 'CivAct',
              subtitle: 'Action citoyenne',
              color: AppColors.secondary,
              onTap: () => _showComingSoon('CivAct'),
            ),
            _buildActionCard(
              icon: Icons.shopping_cart,
              title: 'Carto Prix',
              subtitle: 'Comparateur de prix',
              color: AppColors.secondaryYellow,
              onTap: () => _showComingSoon('Carto Prix'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(20)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(10),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: heightSpace.height!),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: AppColors.mediumGrey),
              SizedBox(height: 16),
              Text(
                'Aucune activité récente',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Commencez à utiliser nos services pour voir votre activité ici.',
                style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return Container(
      color: AppColors.lightBackground,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nos Services',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: heightSpace.height! * 2),

              Expanded(
                child: ListView(
                  children: [
                    _buildServiceCard(
                      icon: Icons.map,
                      title: 'CityAI Guide',
                      description:
                          'Navigation intelligente avec IA pour vous guider dans la ville',
                      color: AppColors.primary,
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      icon: Icons.health_and_safety,
                      title: 'Santé Map',
                      description:
                          'Trouvez les centres de santé les plus proches de vous',
                      color: AppColors.success,
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      icon: Icons.volunteer_activism,
                      title: 'CivAct',
                      description:
                          'Plateforme d\'action citoyenne et de signalement',
                      color: AppColors.secondary,
                      isAvailable: false,
                    ),
                    SizedBox(height: heightSpace.height!),
                    _buildServiceCard(
                      icon: Icons.shopping_cart,
                      title: 'Carto Prix',
                      description:
                          'Comparateur de prix pour vos achats quotidiens',
                      color: AppColors.secondaryYellow,
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

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
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
                          color: AppColors.warning.withAlpha(10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bientôt',
                          style: TextStyle(
                            color: AppColors.warning,
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
                  style: TextStyle(color: AppColors.mediumGrey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      color: AppColors.lightBackground,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paramètres',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: heightSpace.height! * 2),

              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsSection('Compte', [
                      _buildSettingsTile(
                        icon: Icons.person,
                        title: 'Profil',
                        subtitle: 'Gérer vos informations personnelles',
                        onTap: _navigateToProfile,
                      ),
                    ]),

                    SizedBox(height: heightSpace.height!),

                    _buildSettingsSection('Apparence', [
                      _buildSettingsTile(
                        icon: Icons.brightness_6,
                        title: 'Thème',
                        subtitle: 'Basculer entre clair et sombre',
                        onTap: _toggleTheme,
                        trailing: Switch(
                          value:
                              Theme.of(context).brightness == Brightness.dark,
                          onChanged: (_) => _toggleTheme(),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.language,
                        title: 'Langue',
                        subtitle: 'Français / English',
                        onTap: _toggleLanguage,
                      ),
                    ]),

                    SizedBox(height: heightSpace.height!),

                    _buildSettingsSection('À propos', [
                      _buildSettingsTile(
                        icon: Icons.info,
                        title: 'Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.help,
                        title: 'Aide',
                        subtitle: 'Support et FAQ',
                        onTap: () => _showComingSoon('Aide'),
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

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow2,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, color: AppColors.mediumGrey, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.mediumGrey,
      backgroundColor: AppColors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Services'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible !'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// lib/src/modules/auth/views/profile.screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/modules/auth/widgets/account_status_card.widget.dart';
import 'package:kartia/src/modules/auth/widgets/profile_avatar.widget.dart';
import 'package:kartia/src/modules/auth/widgets/profile_option_tile.widget.dart';
import 'package:kartia/src/modules/auth/widgets/profile_section.widget.dart';
import 'package:kartia/src/modules/auth/widgets/upgrade_account_dialog.dart';
import 'package:kartia/src/modules/auth/widgets/user_info_display.widget.dart';
import 'package:kartia/src/widgets/kartia_dialogs.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';

/// Page de profil utilisateur responsive et moderne
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleSignOut() {
    final l10n = KartiaLocalizations.of(context);

    KartiaDialogs.showCustomDialog(
      context,
      title: l10n.signOut,
      content: Text(l10n.signOutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const AuthSignOutRequested());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(l10n.signOut),
        ),
      ],
    );
  }

  void _handleDeleteAccount() {
    final l10n = KartiaLocalizations.of(context);

    KartiaDialogs.showCustomDialog(
      context,
      title: l10n.deleteAccount,
      content: Text(l10n.deleteAccountWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(l10n.deleteAccountConfirm),
        ),
      ],
    );
  }

  void _handleSendEmailVerification() {
    final l10n = KartiaLocalizations.of(context);

    context.read<AuthBloc>().add(const AuthSendEmailVerificationRequested());

    KartiaSnackbar.show(
      context,
      message: l10n.emailVerificationSent,
      type: SnackbarType.success,
    );
  }

  void _handleUpgradeAccount() {
    showDialog(
      context: context,
      builder: (context) => const UpgradeAccountDialog(),
    );
  }

  void _navigateToEditProfile() {
    Navigator.of(context).pushNamed(AppRoutes.editProfile);
  }

  void _showComingSoon(String feature) {
    final l10n = KartiaLocalizations.of(context);

    KartiaSnackbar.show(
      context,
      message: l10n.featureComingSoon,
      type: SnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            KartiaSnackbar.show(
              context,
              message: state.errorMessage!,
              type: SnackbarType.error,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withAlpha(10),
                AppColors.backgroundColor(context),
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state.user;
                    final firestoreUser = state.firestoreUser;

                    if (user == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ResponsiveLayout(
                      mobile: _buildMobileLayout(
                        context,
                        user,
                        firestoreUser,
                        l10n,
                      ),
                      tablet: _buildTabletLayout(
                        context,
                        user,
                        firestoreUser,
                        l10n,
                      ),
                      desktop: _buildDesktopLayout(
                        context,
                        user,
                        firestoreUser,
                        l10n,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, l10n),
        SliverToBoxAdapter(
          child: ResponsivePadding(
            child: Column(
              children: [
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildProfileHeader(
                    context,
                    user,
                    firestoreUser,
                    l10n,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAccountStatus(context, user, firestoreUser, l10n),
                const SizedBox(height: 24),
                _buildProfileOptions(context, user, firestoreUser, l10n),
                const SizedBox(height: 24),
                _buildDangerZone(context, l10n),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, l10n),
        SliverToBoxAdapter(
          child: ResponsiveContainer(
            child: ResponsivePadding(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildProfileHeader(
                            context,
                            user,
                            firestoreUser,
                            l10n,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildAccountStatus(
                              context,
                              user,
                              firestoreUser,
                              l10n,
                            ),
                            const SizedBox(height: 24),
                            _buildProfileOptions(
                              context,
                              user,
                              firestoreUser,
                              l10n,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildDangerZone(context, l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, l10n),
        SliverToBoxAdapter(
          child: ResponsiveContainer(
            child: ResponsivePadding(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildProfileHeader(
                            context,
                            user,
                            firestoreUser,
                            l10n,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildAccountStatus(context, user, firestoreUser, l10n),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _buildProfileOptions(
                          context,
                          user,
                          firestoreUser,
                          l10n,
                        ),
                        const SizedBox(height: 32),
                        _buildDangerZone(context, l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, KartiaLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.isMobile(context) ? 120 : 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            l10n.profile,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getAdaptiveFontSize(
                context,
                baseFontSize: 18,
              ),
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.white),
            onPressed: _navigateToEditProfile,
            tooltip: 'Modifier le profil',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            user: user,
            firestoreUser: firestoreUser,
            radius: ResponsiveUtils.isMobile(context) ? 50 : 65,
            heroTag: 'profile_avatar',
            onTap: _navigateToEditProfile,
          ),
          SizedBox(
            height: ResponsiveUtils.getAdaptiveSpacing(
              context,
              AppSizes.spacingL,
            ),
          ),
          UserInfoDisplay(user: user, firestoreUser: firestoreUser),
        ],
      ),
    );
  }

  Widget _buildAccountStatus(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return AccountStatusCard(
      user: user,
      firestoreUser: firestoreUser,
      onVerifyEmail: _handleSendEmailVerification,
      onUpgradeAccount: _handleUpgradeAccount,
    );
  }

  Widget _buildProfileOptions(
    BuildContext context,
    user,
    firestoreUser,
    KartiaLocalizations l10n,
  ) {
    return ProfileSection(
      title: 'Options du Profil',
      icon: Icons.settings,
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ),
      children: [
        ProfileOptionTile(
          icon: Icons.edit_rounded,
          title: l10n.editProfile,
          subtitle: l10n.manageProfile,
          onTap: _navigateToEditProfile,
          iconGradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        const Divider(height: 1),
        if (!user.isAnonymous) ...[],
        ProfileOptionTile(
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: l10n.notificationsDesc,
          onTap: () => _showComingSoon(l10n.notifications),
          iconGradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryYellow],
          ),
        ),
        const Divider(height: 1),
        ProfileOptionTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacy,
          subtitle: l10n.privacyDesc,
          onTap: () => _showComingSoon(l10n.privacy),
          iconGradient: LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.secondary],
          ),
        ),
        if (kDebugMode) ...[
          const Divider(height: 1),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ProfileOptionTile(
                icon: Icons.developer_mode,
                title: 'Infos de Debug',
                subtitle:
                    state.firestoreUser != null
                        ? 'Dernière sync: ${state.firestoreUser!.updatedAt.toString().substring(0, 16)}'
                        : 'Aucune donnée Firestore',
                onTap: () => _showDebugInfo(context, state),
                iconColor: Colors.purple,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, KartiaLocalizations l10n) {
    return ProfileSection(
      title: l10n.dangerZone,
      icon: Icons.warning_rounded,
      gradient: LinearGradient(
        colors: [AppColors.error, AppColors.error.withAlpha(180)],
      ),
      children: [
        ProfileOptionTile(
          icon: Icons.logout_rounded,
          title: l10n.signOut,
          subtitle: l10n.signOutDesc,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          onTap: _handleSignOut,
          showArrow: false,
        ),
        const Divider(height: 1),
        ProfileOptionTile(
          icon: Icons.delete_forever_rounded,
          title: l10n.deleteAccount,
          subtitle: l10n.deleteAccountDesc,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          onTap: _handleDeleteAccount,
          showArrow: false,
        ),
      ],
    );
  }

  void _showDebugInfo(BuildContext context, AuthState state) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Infos de Debug'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('État Auth: ${state.status}'),
                  Text('Utilisateur: ${state.user?.uid ?? 'null'}'),
                  Text('Firestore: ${state.firestoreUser?.userId ?? 'null'}'),
                  Text(
                    'Dernière sync: ${state.firestoreUser?.updatedAt ?? 'jamais'}',
                  ),
                  Text(
                    'Localisation active: ${state.isLocationTrackingActive}',
                  ),
                  if (state.firestoreUser != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Version app: ${state.firestoreUser!.appInfo.version}',
                    ),
                    Text(
                      'Plateforme: ${state.firestoreUser!.appInfo.platform}',
                    ),
                    Text('OS: ${state.firestoreUser!.deviceInfo.osVersion}'),
                    Text('Langue: ${state.firestoreUser!.deviceInfo.language}'),
                    Text('Pays: ${state.firestoreUser!.deviceInfo.country}'),
                    if (state.firestoreUser!.currentLocation != null) ...[
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const AuthSyncUserData());
                },
                child: const Text('Synchroniser'),
              ),
            ],
          ),
    );
  }
}

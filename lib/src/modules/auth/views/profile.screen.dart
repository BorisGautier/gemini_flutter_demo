import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';
import 'package:kartia/src/widgets/kartia_dialogs.widget.dart';
import 'package:kartia/src/widgets/kartia_snackbar.widget.dart';

/// Page de profil utilisateur
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _staggerAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Animations échelonnées pour les sections
  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _optionsSlideAnimation;
  late Animation<Offset> _dangerSlideAnimation;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Animations échelonnées
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _optionsSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerAnimationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _dangerSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
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
      if (mounted) _scaleAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _staggerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _staggerAnimationController.dispose();
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

  void _navigateToEditProfile() {
    context.pushNamed(AppRoutes.editProfile);
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
          // Navigation supprimée - AppNavigationManager s'en occupe
        },
        child: Container(
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state.user;

                    if (user == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return CustomScrollView(
                      slivers: [
                        _buildAppBar(l10n, user),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(fixPadding),
                            child: Column(
                              children: [
                                SlideTransition(
                                  position: _headerSlideAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: _buildProfileHeader(l10n, user),
                                  ),
                                ),
                                SizedBox(height: heightSpace.height! * 2),
                                SlideTransition(
                                  position: _optionsSlideAnimation,
                                  child: _buildProfileOptions(l10n, user),
                                ),
                                SizedBox(height: heightSpace.height! * 2),
                                SlideTransition(
                                  position: _dangerSlideAnimation,
                                  child: _buildDangerZone(l10n),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildAppBar(KartiaLocalizations l10n, user) {
    return SliverAppBar(
      expandedHeight: 120,
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
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(KartiaLocalizations l10n, user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow2,
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar avec badge et effets
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: AppColors.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.white,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withAlpha(10),
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                    child:
                        user.photoURL == null
                            ? Text(
                              user.initials,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                            : null,
                  ),
                ),
              ),

              // Badge de statut avec animation
              Positioned(
                bottom: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        user.isAnonymous
                            ? AppColors.warning
                            : user.emailVerified
                            ? AppColors.success
                            : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: (user.isAnonymous
                                ? AppColors.warning
                                : user.emailVerified
                                ? AppColors.success
                                : AppColors.error)
                            .withAlpha(30),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    user.isAnonymous
                        ? Icons.person_outline
                        : user.emailVerified
                        ? Icons.verified
                        : Icons.warning,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: heightSpace.height! * 1.5),

          // Nom d'affichage avec style
          Text(
            user.displayNameOrEmail,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),

          if (user.email != null) ...[
            SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.email!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGrey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          if (user.phoneNumber != null) ...[
            SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withAlpha(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 14, color: AppColors.primaryPurple),
                  SizedBox(width: 4),
                  Text(
                    user.phoneNumber!,
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Statut du compte avec design amélioré
          SizedBox(height: heightSpace.height!),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    user.isAnonymous
                        ? [
                          AppColors.warning.withAlpha(15),
                          AppColors.warning.withAlpha(10),
                        ]
                        : user.emailVerified
                        ? [
                          AppColors.success.withAlpha(15),
                          AppColors.success.withAlpha(10),
                        ]
                        : [
                          AppColors.error.withAlpha(15),
                          AppColors.error.withAlpha(10),
                        ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    user.isAnonymous
                        ? AppColors.warning
                        : user.emailVerified
                        ? AppColors.success
                        : AppColors.error,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isAnonymous
                      ? Icons.person_outline
                      : user.emailVerified
                      ? Icons.verified_outlined
                      : Icons.warning_outlined,
                  color:
                      user.isAnonymous
                          ? AppColors.warning
                          : user.emailVerified
                          ? AppColors.success
                          : AppColors.error,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  user.isAnonymous
                      ? l10n.guestAccount
                      : user.emailVerified
                      ? l10n.emailVerified
                      : l10n.emailNotVerified,
                  style: TextStyle(
                    color:
                        user.isAnonymous
                            ? AppColors.warning
                            : user.emailVerified
                            ? AppColors.success
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Bouton de vérification d'email
          if (!user.emailVerified &&
              user.email != null &&
              !user.isAnonymous) ...[
            SizedBox(height: heightSpace.height!),
            KartiaButton(
              text: l10n.verifyEmail,
              onPressed: _handleSendEmailVerification,
              type: KartiaButtonType.outline,
              size: KartiaButtonSize.small,
              borderColor: AppColors.warning,
              textColor: AppColors.warning,
              icon: Icons.mail_outline,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileOptions(KartiaLocalizations l10n, user) {
    return Container(
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
          _buildOptionTile(
            icon: Icons.edit_rounded,
            title: l10n.editProfile,
            subtitle: l10n.manageProfile,
            onTap: _navigateToEditProfile,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),

          if (!user.isAnonymous) ...[
            const Divider(height: 1),
            _buildOptionTile(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              subtitle: l10n.changePasswordDesc,
              onTap: () => _showComingSoon(l10n.changePassword),
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primary],
              ),
            ),
          ],

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.notificationsDesc,
            onTap: () => _showComingSoon(l10n.notifications),
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryYellow],
            ),
          ),

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacy,
            subtitle: l10n.privacyDesc,
            onTap: () => _showComingSoon(l10n.privacy),
            gradient: LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.secondary],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(KartiaLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withAlpha(30), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withAlpha(10),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de zone de danger
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withAlpha(10),
                  AppColors.error.withAlpha(5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  l10n.dangerZone,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          _buildOptionTile(
            icon: Icons.logout_rounded,
            title: l10n.signOut,
            subtitle: l10n.signOutDesc,
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: _handleSignOut,
            showArrow: false,
          ),

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.delete_forever_rounded,
            title: l10n.deleteAccount,
            subtitle: l10n.deleteAccountDesc,
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: _handleDeleteAccount,
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    LinearGradient? gradient,
    bool showArrow = true,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  color:
                      gradient == null
                          ? (iconColor ?? AppColors.primary).withAlpha(10)
                          : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.white,
                  size: 22,
                ),
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
                        color: titleColor ?? AppColors.black,
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

              if (showArrow)
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
}

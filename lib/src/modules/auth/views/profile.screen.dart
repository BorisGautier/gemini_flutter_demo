import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late Animation<double> _fadeAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _handleSignOut() {
    KartiaDialogs.showCustomDialog(
      context,
      title: 'Déconnexion',
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const AuthSignOutRequested());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Déconnexion'),
        ),
      ],
    );
  }

  void _handleDeleteAccount() {
    KartiaDialogs.showCustomDialog(
      context,
      title: 'Supprimer le compte',
      content: const Text(
        'Cette action est irréversible. Toutes vos données seront définitivement supprimées.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }

  void _handleSendEmailVerification() {
    context.read<AuthBloc>().add(const AuthSendEmailVerificationRequested());

    KartiaSnackbar.show(
      context,
      message: 'Un email de vérification a été envoyé à votre adresse.',
      type: SnackbarType.success,
    );
  }

  void _navigateToEditProfile() {
    context.pushNamed(AppRoutes.editProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError) {
            KartiaSnackbar.show(
              context,
              message: state.errorMessage!,
              type: SnackbarType.error,
            );
          } else if (state.isUnauthenticated) {
            context.pushNamedAndRemoveUntil(AppRoutes.login);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary.withAlpha(10), Colors.white],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state.user;

                  if (user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return CustomScrollView(
                    slivers: [
                      _buildAppBar(user),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(fixPadding),
                          child: Column(
                            children: [
                              _buildProfileHeader(user),
                              SizedBox(height: heightSpace.height! * 2),
                              _buildProfileOptions(user),
                              SizedBox(height: heightSpace.height! * 2),
                              _buildDangerZone(),
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
    );
  }

  Widget _buildAppBar(user) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profil',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.white),
          onPressed: _navigateToEditProfile,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withAlpha(10),
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child:
                    user.photoURL == null
                        ? Text(
                          user.initials,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                        : null,
              ),

              // Badge de vérification email
              if (!user.emailVerified && user.email != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: heightSpace.height!),

          // Nom d'affichage
          Text(
            user.displayNameOrEmail,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            textAlign: TextAlign.center,
          ),

          if (user.email != null) ...[
            SizedBox(height: 4),
            Text(
              user.email!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey),
              textAlign: TextAlign.center,
            ),
          ],

          if (user.phoneNumber != null) ...[
            SizedBox(height: 4),
            Text(
              user.phoneNumber!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mediumGrey),
              textAlign: TextAlign.center,
            ),
          ],

          // Statut du compte
          SizedBox(height: heightSpace.height!),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  user.isAnonymous
                      ? AppColors.warning.withAlpha(10)
                      : user.emailVerified
                      ? AppColors.success.withAlpha(10)
                      : AppColors.error.withAlpha(10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    user.isAnonymous
                        ? AppColors.warning
                        : user.emailVerified
                        ? AppColors.success
                        : AppColors.error,
              ),
            ),
            child: Text(
              user.isAnonymous
                  ? 'Compte invité'
                  : user.emailVerified
                  ? 'Email vérifié'
                  : 'Email non vérifié',
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
          ),

          // Bouton de vérification d'email
          if (!user.emailVerified &&
              user.email != null &&
              !user.isAnonymous) ...[
            SizedBox(height: heightSpace.height!),
            KartiaButton(
              text: 'Vérifier l\'email',
              onPressed: _handleSendEmailVerification,
              type: KartiaButtonType.outline,
              size: KartiaButtonSize.small,
              borderColor: AppColors.warning,
              textColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileOptions(user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow2, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.edit,
            title: 'Modifier le profil',
            subtitle: 'Changer vos informations personnelles',
            onTap: _navigateToEditProfile,
          ),

          if (!user.isAnonymous) ...[
            const Divider(height: 1),
            _buildOptionTile(
              icon: Icons.lock,
              title: 'Changer le mot de passe',
              subtitle: 'Modifier votre mot de passe',
              onTap: () {
                KartiaSnackbar.show(
                  context,
                  message: 'Cette fonctionnalité sera bientôt disponible.',
                  type: SnackbarType.info,
                );
              },
            ),
          ],

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer vos préférences de notification',
            onTap: () {
              KartiaSnackbar.show(
                context,
                message: 'Cette fonctionnalité sera bientôt disponible.',
                type: SnackbarType.info,
              );
            },
          ),

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.privacy_tip,
            title: 'Confidentialité',
            subtitle: 'Paramètres de confidentialité',
            onTap: () {
              KartiaSnackbar.show(
                context,
                message: 'Cette fonctionnalité sera bientôt disponible.',
                type: SnackbarType.info,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withAlpha(10),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Text(
                  'Zone de danger',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _buildOptionTile(
            icon: Icons.logout,
            title: 'Se déconnecter',
            subtitle: 'Déconnexion de votre compte',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: _handleSignOut,
          ),

          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.delete_forever,
            title: 'Supprimer le compte',
            subtitle: 'Suppression définitive de votre compte',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: _handleDeleteAccount,
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
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.mediumGrey, fontSize: 12),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.mediumGrey,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

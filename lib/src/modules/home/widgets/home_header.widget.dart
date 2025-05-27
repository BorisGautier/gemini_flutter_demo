// lib/src/widgets/home_header.widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/routes/app.routes.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/themes.util.dart';
import 'package:kartia/src/modules/app/bloc/app_bloc.dart';
import 'package:kartia/src/modules/auth/bloc/auth_bloc.dart';

/// Widget d'en-tête de l'écran d'accueil
class HomeHeader extends StatelessWidget {
  /// Animation pour l'en-tête
  final Animation<Offset> animation;

  const HomeHeader({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: animation, child: _buildHeader(context));
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

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
              _buildUserAvatar(context, user),
              const SizedBox(width: 16),
              _buildUserInfo(context, l10n, user),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(BuildContext context, user) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
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
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
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
    );
  }

  Widget _buildUserInfo(BuildContext context, KartiaLocalizations l10n, user) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.isAnonymous == true ? l10n.guest : l10n.hello,
            style: TextStyle(
              color: AppColors.onSurfaceSecondaryColor(context),
              fontSize: 14,
            ),
          ),
          Text(
            user?.displayNameOrEmail ?? l10n.user,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        HeaderActionButton(
          icon: Icons.brightness_6_rounded,
          onPressed: () => _toggleTheme(context),
          gradient: LinearGradient(
            colors: [AppColors.warning, AppColors.secondaryYellow],
          ),
        ),
        const SizedBox(width: 8),
        HeaderActionButton(
          icon: Icons.language_rounded,
          onPressed: () => _toggleLanguage(context),
          gradient: LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.primary],
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _toggleTheme(BuildContext context) {
    final currentTheme = context.read<AppBloc>().state.themeData;
    final isDark = currentTheme!.brightness == Brightness.dark;

    context.read<AppBloc>().add(
      ChangeTheme(isDark ? AppTheme.lightTheme : AppTheme.darkTheme),
    );
  }

  void _toggleLanguage(BuildContext context) {
    final currentLocale = context.read<AppBloc>().state.locale;

    if (currentLocale?.languageCode == 'fr') {
      context.read<AppBloc>().add(const ChangeLanguage(Locale('en', 'US')));
    } else {
      context.read<AppBloc>().add(const ChangeLanguage(Locale('fr', 'FR')));
    }
  }
}

/// Widget de bouton d'action dans l'en-tête
class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
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
}

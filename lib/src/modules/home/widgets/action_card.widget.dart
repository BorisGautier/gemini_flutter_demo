// lib/src/widgets/action_card.widget.dart

import 'package:flutter/material.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';

/// Widget de carte d'action rapide
class ActionCard extends StatelessWidget {
  /// Icône de l'action
  final IconData icon;

  /// Titre de l'action
  final String title;

  /// Sous-titre de l'action
  final String subtitle;

  /// Gradient de couleur
  final LinearGradient gradient;

  /// Callback lors du tap
  final VoidCallback onTap;

  /// Indique si l'action est disponible
  final bool isAvailable;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 16 : 20),
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
            _buildIcon(),
            const SizedBox(height: 12),
            _buildTitle(context),
            const SizedBox(height: 4),
            _buildSubtitle(context),
            if (!isAvailable) _buildComingSoonBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.white, size: 24),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getAdaptiveFontSize(
          context,
          baseFontSize: 14,
        ),
        color: AppColors.onSurfaceColor(context),
        fontFamily: "OpenSans-SemiBold",
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        color: AppColors.onSurfaceSecondaryColor(context),
        fontSize: ResponsiveUtils.getAdaptiveFontSize(
          context,
          baseFontSize: 11,
        ),
        height: 1.3,
        fontFamily: "OpenSans",
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildComingSoonBadge(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
            fontSize: 8,
            fontWeight: FontWeight.w600,
            fontFamily: "OpenSans-SemiBold",
          ),
        ),
      ),
    );
  }
}

/// Grille d'actions rapides
class QuickActionsGrid extends StatelessWidget {
  /// Liste des actions
  final List<ActionCardData> actions;

  /// Callback lors du tap sur une action
  final Function(String actionId) onActionTap;

  /// Animation pour la grille
  final Animation<Offset> animation;

  const QuickActionsGrid({
    super.key,
    required this.actions,
    required this.onActionTap,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          SizedBox(height: ResponsiveUtils.getAdaptiveSpacing(context, 16)),
          _buildGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);

    return Container(
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
    );
  }

  Widget _buildGrid(BuildContext context) {
    return ResponsiveGrid(
      children:
          actions
              .map(
                (action) => ActionCard(
                  icon: IconData(action.iconCode, fontFamily: 'MaterialIcons'),
                  title: action.title,
                  subtitle: action.subtitle,
                  gradient: LinearGradient(
                    colors:
                        action.gradientColors
                            .map((color) => Color(color))
                            .toList(),
                  ),
                  onTap: () => onActionTap(action.id),
                  isAvailable: action.isAvailable,
                ),
              )
              .toList(),
    );
  }
}

/// Données pour une carte d'action
class ActionCardData {
  final String id;
  final String title;
  final String subtitle;
  final int iconCode;
  final List<int> gradientColors;
  final bool isAvailable;

  const ActionCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCode,
    required this.gradientColors,
    this.isAvailable = false,
  });
}

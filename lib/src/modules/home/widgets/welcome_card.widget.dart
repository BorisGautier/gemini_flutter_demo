// lib/src/widgets/welcome_card.widget.dart

import 'package:flutter/material.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/widgets/kartia_button.widget.dart';

/// Widget de carte de bienvenue
class WelcomeCard extends StatelessWidget {
  /// Animation pour la carte
  final Animation<Offset> animation;

  /// Callback pour le bouton explorer
  final VoidCallback onExplorePressed;

  const WelcomeCard({
    super.key,
    required this.animation,
    required this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: _buildWelcomeCard(context),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final l10n = KartiaLocalizations.of(context);
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
          _buildWelcomeHeader(l10n),
          const SizedBox(height: 16),
          _buildWelcomeDescription(l10n),
          const SizedBox(height: 24),
          _buildExploreButton(l10n),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(KartiaLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.waving_hand, color: AppColors.white, size: 28),
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
    );
  }

  Widget _buildWelcomeDescription(KartiaLocalizations l10n) {
    return Text(
      l10n.discoverServices,
      style: TextStyle(
        color: AppColors.white.withAlpha(220),
        fontSize: 16,
        height: 1.4,
        fontFamily: "OpenSans",
      ),
    );
  }

  Widget _buildExploreButton(KartiaLocalizations l10n) {
    return KartiaButton(
      text: l10n.explore,
      onPressed: onExplorePressed,
      type: KartiaButtonType.secondary,
      backgroundColor: AppColors.white,
      textColor: AppColors.primary,
      size: KartiaButtonSize.medium,
      icon: Icons.explore_rounded,
    );
  }
}

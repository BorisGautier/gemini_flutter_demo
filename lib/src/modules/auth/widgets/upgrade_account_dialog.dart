import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/core/routes/app.routes.dart';

/// Dialog pour permettre à l'utilisateur de mettre à niveau son compte anonyme
class UpgradeAccountDialog extends StatelessWidget {
  const UpgradeAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(
        ResponsiveUtils.getHorizontalPadding(context),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.isMobile(context) ? double.infinity : 400,
          // ✅ Ajouter une hauteur maximale pour éviter le débordement
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
        // ✅ Remplacer Column par SingleChildScrollView pour permettre le scroll
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildContent(context),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXL),
          topRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // ✅ Réduire l'espacement pour économiser l'espace
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(
              12,
            ), // ✅ Réduire le padding de 16 à 12
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.account_circle,
              color: AppColors.white,
              size: 28, // ✅ Réduire la taille de l'icône de 32 à 28
            ),
          ),
          const SizedBox(height: 12), // ✅ Réduire l'espacement de 16 à 12
          Text(
            'Créer un Compte Complet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontFamily: "OpenSans-Bold",
              fontSize: ResponsiveUtils.getAdaptiveFontSize(
                context,
                baseFontSize: 18, // ✅ Réduire légèrement la taille de police
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12), // ✅ Réduire l'espacement de 16 à 12
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      child: Column(
        children: [
          Text(
            'Passez d\'un compte invité à un compte complet pour :',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceSecondaryColor(context),
              height: 1.3, // ✅ Réduire la hauteur de ligne de 1.4 à 1.3
              fontSize: ResponsiveUtils.getAdaptiveFontSize(
                context,
                baseFontSize: 13, // ✅ Réduire légèrement la taille
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16), // ✅ Réduire l'espacement de 20 à 16
          _buildFeatureList(context),
          const SizedBox(height: 16), // ✅ Réduire l'espacement de 20 à 16
          Container(
            padding: const EdgeInsets.all(
              12,
            ), // ✅ Réduire le padding de 16 à 12
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(10),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.info.withAlpha(30)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 18,
                ), // ✅ Réduire de 20 à 18
                const SizedBox(width: 10), // ✅ Réduire de 12 à 10
                Expanded(
                  child: Text(
                    'Vos données actuelles seront conservées lors de la migration.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.getAdaptiveFontSize(
                        context,
                        baseFontSize: 12, // ✅ Légèrement plus petit
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      {'icon': Icons.save, 'text': 'Sauvegarder vos données'},
      {'icon': Icons.sync, 'text': 'Synchronisation multi-appareils'},
      {'icon': Icons.security, 'text': 'Sécurité renforcée'},
      {'icon': Icons.notifications, 'text': 'Notifications personnalisées'},
    ];

    return Column(
      children:
          features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                  ), // ✅ Réduire de 4 à 3
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5), // ✅ Réduire de 6 à 5
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(15),
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // ✅ Réduire de 8 à 6
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: AppColors.success,
                          size: 14, // ✅ Réduire de 16 à 14
                        ),
                      ),
                      const SizedBox(width: 10), // ✅ Réduire de 12 à 10
                      Expanded(
                        child: Text(
                          feature['text'] as String,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceColor(context),
                            fontSize: ResponsiveUtils.getAdaptiveFontSize(
                              context,
                              baseFontSize: 13, // ✅ Légèrement plus petit
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  // Correction dans upgrade_account_dialog.dart

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveUtils.getAdaptivePadding(context).horizontal,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                // ✅ FIX: Naviguer directement vers la page d'upgrade avec email
                Navigator.of(context).pushNamed(
                  AppRoutes.upgradeAccount,
                  arguments: {'method': 'email'}, // ✅ Passer le type de méthode
                );
              },
              icon: const Icon(Icons.email, size: 18),
              label: const Text(
                'Créer avec Email',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                // ✅ FIX: Naviguer directement vers la page d'upgrade avec téléphone
                Navigator.of(context).pushNamed(
                  AppRoutes.upgradeAccount,
                  arguments: {'method': 'phone'}, // ✅ Passer le type de méthode
                );
              },
              icon: const Icon(Icons.phone, size: 18),
              label: const Text(
                'Créer avec Téléphone',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Plus tard',
              style: TextStyle(
                color: AppColors.onSurfaceSecondaryColor(context),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

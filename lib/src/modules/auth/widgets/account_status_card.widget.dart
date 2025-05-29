import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

class AccountStatusCard extends StatelessWidget {
  final UserModel? user;
  final FirestoreUserModel? firestoreUser;
  final VoidCallback? onVerifyEmail;
  final VoidCallback? onUpgradeAccount;

  const AccountStatusCard({
    super.key,
    this.user,
    this.firestoreUser,
    this.onVerifyEmail,
    this.onUpgradeAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.getAdaptivePadding(context).horizontal,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(color: _getStatusColor().withAlpha(30), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 16),
            _buildStatusDescription(context),
            if (_shouldShowAction()) ...[
              const SizedBox(height: 16),
              _buildActionButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withAlpha(15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getStatusTitle(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(),
              fontFamily: "OpenSans-Bold",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDescription(BuildContext context) {
    return Text(
      _getStatusDescription(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.onSurfaceSecondaryColor(context),
        height: 1.4,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _getActionCallback(),
        icon: Icon(_getActionIcon()),
        label: Text(_getActionText()),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getStatusColor(),
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (user?.isAnonymous == true) return AppColors.warning;
    if (user?.phoneNumber != null) return AppColors.primaryPurple;
    if (user?.emailVerified == true) return AppColors.success;
    return AppColors.error;
  }

  IconData _getStatusIcon() {
    if (user?.isAnonymous == true) return Icons.person_outline;
    if (user?.phoneNumber != null) return Icons.verified_user;
    if (user?.emailVerified == true) return Icons.verified;
    return Icons.warning;
  }

  String _getStatusTitle() {
    if (user?.isAnonymous == true) return 'Compte Invité';
    if (user?.phoneNumber != null) return 'Téléphone Vérifié';
    if (user?.emailVerified == true) return 'Email Vérifié';
    return 'Email Non Vérifié';
  }

  String _getStatusDescription() {
    if (user?.isAnonymous == true) {
      return 'Vous utilisez un compte invité. Créez un compte complet pour sauvegarder vos données et accéder à toutes les fonctionnalités.';
    }
    if (user?.phoneNumber != null) {
      return 'Votre numéro de téléphone a été vérifié avec succès. Vous avez accès à toutes les fonctionnalités.';
    }
    if (user?.emailVerified == true) {
      return 'Votre adresse email a été vérifiée avec succès. Vous avez accès à toutes les fonctionnalités.';
    }
    return 'Votre adresse email n\'est pas encore vérifiée. Vérifiez votre email pour accéder à toutes les fonctionnalités.';
  }

  bool _shouldShowAction() {
    return (user?.isAnonymous == true) ||
        (user?.email != null &&
            user?.emailVerified == false &&
            user?.phoneNumber == null);
  }

  VoidCallback? _getActionCallback() {
    if (user?.isAnonymous == true) return onUpgradeAccount;
    if (user?.email != null && user?.emailVerified == false) {
      return onVerifyEmail;
    }
    return null;
  }

  IconData _getActionIcon() {
    if (user?.isAnonymous == true) return Icons.account_circle;
    return Icons.email;
  }

  String _getActionText() {
    if (user?.isAnonymous == true) return 'Créer un Compte';
    return 'Vérifier l\'Email';
  }
}

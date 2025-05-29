import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

/// Widget d'avatar avec badge de statut et support d'images locales
class ProfileAvatar extends StatelessWidget {
  final UserModel? user;
  final FirestoreUserModel? firestoreUser;
  final double radius;
  final bool showBadge;
  final VoidCallback? onTap;
  final String? heroTag;
  final File? imageFile; // ✅ Support pour image locale

  const ProfileAvatar({
    super.key,
    this.user,
    this.firestoreUser,
    this.radius = 50,
    this.showBadge = true,
    this.onTap,
    this.heroTag,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final isResponsive = ResponsiveUtils.isMobile(context);
    final adaptiveRadius = isResponsive ? radius * 0.8 : radius;

    Widget avatar = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(adaptiveRadius + 5),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(30),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: adaptiveRadius + 3,
        backgroundColor: AppColors.surfaceColor(context),
        child: _buildInnerAvatar(
          adaptiveRadius,
        ), // ✅ Utiliser une méthode séparée
      ),
    );

    if (showBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(bottom: 0, right: 0, child: _buildStatusBadge(context)),
          // ✅ Badge pour indiquer qu'une nouvelle image est sélectionnée
          if (imageFile != null)
            Positioned(top: 0, right: 0, child: _buildNewImageBadge(context)),
        ],
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    return avatar;
  }

  /// ✅ FIX: Méthode séparée pour construire l'avatar interne
  Widget _buildInnerAvatar(double adaptiveRadius) {
    final imageProvider = _getImageProvider();

    // ✅ Si on a une image, créer CircleAvatar avec onBackgroundImageError
    if (imageProvider != null) {
      return CircleAvatar(
        radius: adaptiveRadius,
        backgroundColor: AppColors.primary.withAlpha(10),
        backgroundImage: imageProvider,
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Erreur de chargement d\'image: $exception');
        },
        // ✅ Pas d'enfant quand on a une image de fond
      );
    }

    // ✅ Si pas d'image, créer CircleAvatar avec les initiales seulement
    return CircleAvatar(
      radius: adaptiveRadius,
      backgroundColor: AppColors.primary.withAlpha(10),
      child: _buildInitials(),
    );
  }

  /// ✅ Support pour les images locales avec priorité
  ImageProvider? _getImageProvider() {
    // ✅ Priorité 1: Image locale sélectionnée
    if (imageFile != null) {
      return FileImage(imageFile!);
    }

    // ✅ Priorité 2: Image Firestore
    if (firestoreUser?.photoURL != null &&
        firestoreUser!.photoURL!.isNotEmpty) {
      return NetworkImage(firestoreUser!.photoURL!);
    }

    // ✅ Priorité 3: Image Firebase Auth
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return NetworkImage(user!.photoURL!);
    }

    // ✅ Aucune image disponible
    return null;
  }

  Widget _buildInitials() {
    // ✅ Amélioration: Meilleure gestion des initiales
    String initials = 'U';

    if (firestoreUser?.fullName.isNotEmpty == true) {
      initials = _getInitialsFromName(firestoreUser!.fullName);
    } else if (user?.displayName?.isNotEmpty == true) {
      initials = _getInitialsFromName(user!.displayName!);
    } else if (user?.email?.isNotEmpty == true) {
      initials = _getInitialsFromName(user!.email!.split('@')[0]);
    } else if (user != null) {
      initials = user!.initials;
    }

    return Text(
      initials,
      style: TextStyle(
        fontSize: radius * 0.6,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        fontFamily: "OpenSans-Bold",
      ),
    );
  }

  /// ✅ Méthode pour extraire les initiales d'un nom
  String _getInitialsFromName(String name) {
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildStatusBadge(BuildContext context) {
    IconData icon;
    Color color;

    if (user?.isAnonymous == true) {
      icon = Icons.person_outline;
      color = AppColors.warning;
    } else if (user?.phoneNumber != null) {
      icon = Icons.verified_user;
      color = AppColors.primaryPurple;
    } else if (user?.emailVerified == true) {
      icon = Icons.verified;
      color = AppColors.success;
    } else {
      icon = Icons.warning;
      color = AppColors.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(radius * 0.15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius * 0.4),
        border: Border.all(color: AppColors.surfaceColor(context), width: 3),
        boxShadow: [
          BoxShadow(color: color.withAlpha(30), blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: radius * 0.3),
    );
  }

  /// ✅ Badge pour indiquer qu'une nouvelle image est sélectionnée
  Widget _buildNewImageBadge(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(radius * 0.12),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(radius * 0.3),
        border: Border.all(color: AppColors.surfaceColor(context), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(40),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.check, color: AppColors.white, size: radius * 0.25),
    );
  }
}

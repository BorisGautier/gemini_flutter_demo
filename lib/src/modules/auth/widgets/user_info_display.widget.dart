import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';
import 'package:kartia/src/modules/auth/models/user.model.dart';

class UserInfoDisplay extends StatelessWidget {
  final UserModel? user;
  final FirestoreUserModel? firestoreUser;

  const UserInfoDisplay({super.key, this.user, this.firestoreUser});

  @override
  Widget build(BuildContext context) {
    final displayName =
        firestoreUser?.fullName ?? user?.displayNameOrEmail ?? 'Utilisateur';

    return Column(
      children: [
        Text(
          displayName,
          style:
              ResponsiveUtils.isMobile(context)
                  ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceColor(context),
                    fontFamily: "OpenSans-Bold",
                  )
                  : Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceColor(context),
                    fontFamily: "OpenSans-Bold",
                  ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        if (user?.email != null) ...[
          const SizedBox(height: 8),
          _buildInfoChip(
            context,
            text: user!.email!,
            icon: Icons.email,
            color: AppColors.info,
          ),
        ],

        if (user?.phoneNumber != null) ...[
          const SizedBox(height: 8),
          _buildInfoChip(
            context,
            text: user!.phoneNumber!,
            icon: Icons.phone,
            color: AppColors.primaryPurple,
          ),
        ],

        if (firestoreUser?.username != null) ...[
          const SizedBox(height: 8),
          _buildInfoChip(
            context,
            text: '@${firestoreUser!.username}',
            icon: Icons.alternate_email,
            color: AppColors.secondary,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

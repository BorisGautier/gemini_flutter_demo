import 'package:flutter/material.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/core/utils/responsive.util.dart';
import 'package:kartia/src/core/utils/sizes.util.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final LinearGradient? iconGradient;
  final Color? iconColor;
  final Color? titleColor;
  final bool showArrow;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconGradient,
    this.iconColor,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveUtils.getAdaptiveSpacing(context, AppSizes.spacingM),
          ),
          child: Row(
            children: [
              _buildIcon(),
              SizedBox(
                width: ResponsiveUtils.getAdaptiveSpacing(
                  context,
                  AppSizes.spacingM,
                ),
              ),
              Expanded(child: _buildContent(context)),
              if (trailing != null) trailing!,
              if (showArrow && trailing == null) _buildArrow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconGradient != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: iconGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primary).withAlpha(15),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppColors.onSurfaceColor(context),
            fontFamily: "OpenSans-SemiBold",
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceSecondaryColor(context),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      color: AppColors.onSurfaceSecondaryColor(context),
      size: 16,
    );
  }
}

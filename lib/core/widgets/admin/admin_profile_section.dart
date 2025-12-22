import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../presentation/admin/controllers/admin_auth_controller.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_responsive/app_responsive.dart';
import '../../utils/app_spacing/app_spacing.dart';
import '../../utils/app_styles/app_text_styles.dart';

class AdminProfileSection extends StatelessWidget {
  final bool isInDrawer;

  const AdminProfileSection({
    super.key,
    this.isInDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    final authController = Get.find<AdminAuthController>();

    return Container(
      padding: EdgeInsets.all(responsive.scaleSize(0.015)),
      decoration: BoxDecoration(
        color: isInDrawer
            ? Colors.white.withOpacity(0.1)
            : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: responsive.iconSize(20),
            backgroundColor: isInDrawer
                ? Colors.white.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.2),
            child: Icon(
              Iconsax.user,
              color: isInDrawer ? Colors.white : AppColors.primary,
              size: responsive.iconSize(20),
            ),
          ),
          SizedBox(width: responsive.scaleSize(0.01)),

          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin User', // TODO: Replace with actual admin name
                  style: AppTextStyles.bodyText(context).copyWith(
                    color: isInDrawer ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vertical(0.002),
                Text(
                  'Super Admin', // TODO: Replace with actual role
                  style: AppTextStyles.hintText(context).copyWith(
                    color: isInDrawer
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textLight,
                    fontSize: responsive.scaleSize(0.009),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.scaleSize(0.01)),

          // Logout Button
          InkWell(
            onTap: () {
              _showLogoutDialog(context, authController);
            },
            borderRadius: BorderRadius.circular(responsive.radius(8)),
            child: Container(
              padding: EdgeInsets.all(responsive.scaleSize(0.008)),
              decoration: BoxDecoration(
                color: isInDrawer
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.radius(8)),
              ),
              child: Icon(
                Iconsax.logout,
                color: isInDrawer ? Colors.white : AppColors.error,
                size: responsive.iconSize(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AdminAuthController authController) {
    final responsive = AppResponsive(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.logout,
              color: AppColors.error,
              size: responsive.iconSize(24),
            ),
            SizedBox(width: responsive.scaleSize(0.01)),
            Text(
              'Logout',
              style: AppTextStyles.heading(context),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyText(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyText(context).copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(8)),
              ),
            ),
            child: Text(
              'Logout',
              style: AppTextStyles.buttonText(context).copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

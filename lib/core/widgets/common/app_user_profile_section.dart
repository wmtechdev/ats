import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/repositories/auth_repository.dart';

class AppUserProfileSection extends StatelessWidget {
  final VoidCallback onLogout;

  const AppUserProfileSection({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppResponsive.isMobile(context);

    // Get current user
    final authRepo = Get.find<AuthRepository>();
    final currentUser = authRepo.getCurrentUser();

    // For now, we'll use placeholder data until profile is loaded
    String userName = AppTexts.admin;
    String userRole = AppTexts.admin;

    if (currentUser != null) {
      // Use user email as fallback
      userName = currentUser.email.split('@').first;
      userRole = currentUser.role == AppConstants.roleAdmin
          ? AppTexts.administrator
          : AppTexts.admin;
    }

    if (isMobile) {
      // Mobile: Profile section at bottom of drawer
      return Container(
        padding: AppSpacing.all(context, factor: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Info Row
            Row(
              children: [
                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyText(context).copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole,
                        style: AppTextStyles.hintText(context).copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: AppResponsive.screenWidth(context) * 0.025,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Logout Button
                IconButton(
                  icon: Icon(
                    Iconsax.logout,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.white,
                  ),
                  onPressed: onLogout,
                  tooltip: AppTexts.logout,
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Desktop: Profile section at top right
      return Row(
        children: [
          // Name and Role
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userName,
                style: AppTextStyles.bodyText(
                  context,
                ).copyWith(fontWeight: FontWeight.w600, color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userRole,
                style: AppTextStyles.hintText(context).copyWith(
                  fontSize: AppResponsive.screenWidth(context) * 0.01,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          AppSpacing.horizontal(context, 0.01),
          // Logout Button
          IconButton(
            icon: Icon(
              Iconsax.logout,
              size: AppResponsive.iconSize(context),
              color: AppColors.white,
            ),
            onPressed: onLogout,
            tooltip: AppTexts.logout,
          ),
        ],
      );
    }
  }
}

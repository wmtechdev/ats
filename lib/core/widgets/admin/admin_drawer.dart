import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_constants.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_responsive/app_responsive.dart';
import '../../utils/app_spacing/app_spacing.dart';
import '../../utils/app_styles/app_text_styles.dart';
import 'admin_navigation_item.dart';
import 'admin_profile_section.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    final currentRoute = Get.currentRoute;

    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            // Logo Section
            Container(
              padding: EdgeInsets.all(responsive.scaleSize(0.04)),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(responsive.scaleSize(0.02)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(responsive.radius(8)),
                    ),
                    child: Icon(
                      Iconsax.briefcase,
                      color: AppColors.primary,
                      size: responsive.iconSize(28),
                    ),
                  ),
                  SizedBox(width: responsive.scaleSize(0.03)),
                  Expanded(
                    child: Text(
                      'ATS Admin',
                      style: AppTextStyles.headline(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vertical(0.02),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scaleSize(0.02),
                ),
                child: Column(
                  children: [
                    AdminNavigationItem(
                      icon: Iconsax.category,
                      label: 'Dashboard',
                      route: AppConstants.routeAdminDashboard,
                      isActive:
                          currentRoute == AppConstants.routeAdminDashboard,
                      onTap: () {
                        Get.back(); // Close drawer
                        Get.offAllNamed(AppConstants.routeAdminDashboard);
                      },
                    ),
                    AdminNavigationItem(
                      icon: Iconsax.briefcase,
                      label: 'Jobs',
                      route: AppConstants.routeAdminJobs,
                      isActive: currentRoute.startsWith('/admin/jobs'),
                      onTap: () {
                        Get.back(); // Close drawer
                        Get.offAllNamed(AppConstants.routeAdminJobs);
                      },
                    ),
                    AdminNavigationItem(
                      icon: Iconsax.people,
                      label: 'Candidates',
                      route: AppConstants.routeAdminCandidates,
                      isActive: currentRoute.startsWith('/admin/candidates'),
                      onTap: () {
                        Get.back(); // Close drawer
                        Get.offAllNamed(AppConstants.routeAdminCandidates);
                      },
                    ),
                    AdminNavigationItem(
                      icon: Iconsax.document_text,
                      label: 'Documents',
                      route: AppConstants.routeAdminDocumentTypes,
                      isActive:
                          currentRoute == AppConstants.routeAdminDocumentTypes,
                      onTap: () {
                        Get.back(); // Close drawer
                        Get.offAllNamed(AppConstants.routeAdminDocumentTypes);
                      },
                    ),
                    AdminNavigationItem(
                      icon: Iconsax.user_octagon,
                      label: 'Manage Admins',
                      route: AppConstants.routeAdminManageAdmins,
                      isActive:
                          currentRoute == AppConstants.routeAdminManageAdmins,
                      onTap: () {
                        Get.back(); // Close drawer
                        Get.offAllNamed(AppConstants.routeAdminManageAdmins);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Profile Section
            Container(
              padding: EdgeInsets.all(responsive.scaleSize(0.03)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: const AdminProfileSection(isInDrawer: true),
            ),

            // Footer
            Padding(
              padding: EdgeInsets.only(
                bottom: responsive.scaleSize(0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.copyright,
                    color: Colors.white.withOpacity(0.5),
                    size: responsive.iconSize(14),
                  ),
                  SizedBox(width: responsive.scaleSize(0.01)),
                  Text(
                    '2025 ATS',
                    style: AppTextStyles.hintText(context).copyWith(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: responsive.scaleSize(0.012),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

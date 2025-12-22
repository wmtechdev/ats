import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_constants.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_responsive/app_responsive.dart';
import '../../utils/app_spacing/app_spacing.dart';
import '../../utils/app_styles/app_text_styles.dart';
import 'admin_navigation_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    final currentRoute = Get.currentRoute;

    return Container(
      width: responsive.scaleSize(0.18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: EdgeInsets.all(responsive.scaleSize(0.02)),
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
                  padding: EdgeInsets.all(responsive.scaleSize(0.01)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(responsive.radius(8)),
                  ),
                  child: Icon(
                    Iconsax.briefcase,
                    color: AppColors.primary,
                    size: responsive.iconSize(24),
                  ),
                ),
                SizedBox(width: responsive.scaleSize(0.01)),
                Expanded(
                  child: Text(
                    'ATS Admin',
                    style: AppTextStyles.heading(context).copyWith(
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
              child: Column(
                children: [
                  AdminNavigationItem(
                    icon: Iconsax.category,
                    label: 'Dashboard',
                    route: AppConstants.routeAdminDashboard,
                    isActive: currentRoute == AppConstants.routeAdminDashboard,
                  ),
                  AdminNavigationItem(
                    icon: Iconsax.briefcase,
                    label: 'Jobs',
                    route: AppConstants.routeAdminJobs,
                    isActive: currentRoute.startsWith('/admin/jobs'),
                  ),
                  AdminNavigationItem(
                    icon: Iconsax.people,
                    label: 'Candidates',
                    route: AppConstants.routeAdminCandidates,
                    isActive: currentRoute.startsWith('/admin/candidates'),
                  ),
                  AdminNavigationItem(
                    icon: Iconsax.document_text,
                    label: 'Documents',
                    route: AppConstants.routeAdminDocumentTypes,
                    isActive: currentRoute == AppConstants.routeAdminDocumentTypes,
                  ),
                  AdminNavigationItem(
                    icon: Iconsax.user_octagon,
                    label: 'Manage Admins',
                    route: AppConstants.routeAdminManageAdmins,
                    isActive: currentRoute == AppConstants.routeAdminManageAdmins,
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(responsive.scaleSize(0.015)),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.copyright,
                  color: Colors.white.withOpacity(0.5),
                  size: responsive.iconSize(14),
                ),
                SizedBox(width: responsive.scaleSize(0.005)),
                Text(
                  '2025 ATS',
                  style: AppTextStyles.hintText(context).copyWith(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: responsive.scaleSize(0.008),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

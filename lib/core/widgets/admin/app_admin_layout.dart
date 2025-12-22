import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/common/app_side_layout.dart';
import 'package:ats/core/widgets/common/app_navigation_item_model.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';

class AppAdminLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppAdminLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AdminAuthController>();

    final navigationItems = [
      AppNavigationItemModel(
        title: AppTexts.dashboard,
        icon: Iconsax.home,
        route: AppConstants.routeAdminDashboard,
      ),
      AppNavigationItemModel(
        title: AppTexts.jobs,
        icon: Iconsax.briefcase,
        route: AppConstants.routeAdminJobs,
      ),
      AppNavigationItemModel(
        title: AppTexts.candidates,
        icon: Iconsax.profile_circle,
        route: AppConstants.routeAdminCandidates,
      ),
      AppNavigationItemModel(
        title: AppTexts.documents,
        icon: Iconsax.document_text,
        route: AppConstants.routeAdminDocumentTypes,
      ),
      AppNavigationItemModel(
        title: AppTexts.manageAdmins,
        icon: Iconsax.user,
        route: AppConstants.routeAdminManageAdmins,
      ),
    ];

    return AppSideLayout(
      title: title,
      actions: actions,
      navigationItems: navigationItems,
      dashboardRoute: AppConstants.routeAdminDashboard,
      onLogout: () => authController.signOut(),
      child: child,
    );
  }
}


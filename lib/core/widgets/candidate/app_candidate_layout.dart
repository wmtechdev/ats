import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/common/app_side_layout.dart';
import 'package:ats/core/widgets/common/app_navigation_item_model.dart';
import 'package:ats/presentation/candidate/controllers/candidate_auth_controller.dart';

class AppCandidateLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppCandidateLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<CandidateAuthController>();

    final navigationItems = [
      AppNavigationItemModel(
        title: AppTexts.dashboard,
        icon: Iconsax.home,
        route: AppConstants.routeCandidateDashboard,
      ),
      AppNavigationItemModel(
        title: AppTexts.profile,
        icon: Iconsax.profile_circle,
        route: AppConstants.routeCandidateProfile,
      ),
      AppNavigationItemModel(
        title: AppTexts.jobs,
        icon: Iconsax.briefcase,
        route: AppConstants.routeCandidateJobs,
      ),
      AppNavigationItemModel(
        title: AppTexts.applications,
        icon: Iconsax.document,
        route: AppConstants.routeCandidateApplications,
      ),
      AppNavigationItemModel(
        title: AppTexts.documents,
        icon: Iconsax.folder,
        route: AppConstants.routeCandidateDocuments,
      ),
    ];

    return AppSideLayout(
      title: title,
      actions: actions,
      navigationItems: navigationItems,
      dashboardRoute: AppConstants.routeCandidateDashboard,
      onLogout: () => authController.signOut(),
      child: child,
    );
  }
}


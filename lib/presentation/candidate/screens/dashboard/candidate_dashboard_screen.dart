import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/candidate/controllers/auth_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateDashboardScreen extends StatelessWidget {
  const CandidateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(
        title: AppTexts.dashboard,
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.logout,
              size: AppResponsive.iconSize(context),
              color: AppColors.error,
            ),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: AppResponsive.isMobile(context) ? 2 : 4,
        padding: AppSpacing.padding(context),
        childAspectRatio: 1.2,
        children: [
          AppDashboardCard(
            title: AppTexts.profile,
            icon: Iconsax.profile_circle,
            onTap: () => Get.toNamed(AppConstants.routeCandidateProfile),
          ),
          AppDashboardCard(
            title: AppTexts.jobs,
            icon: Iconsax.briefcase,
            onTap: () => Get.toNamed(AppConstants.routeCandidateJobs),
          ),
          AppDashboardCard(
            title: AppTexts.applications,
            icon: Iconsax.document,
            onTap: () => Get.toNamed(AppConstants.routeCandidateApplications),
          ),
          AppDashboardCard(
            title: AppTexts.documents,
            icon: Iconsax.folder,
            onTap: () => Get.toNamed(AppConstants.routeCandidateDocuments),
          ),
        ],
      ),
    );
  }
}

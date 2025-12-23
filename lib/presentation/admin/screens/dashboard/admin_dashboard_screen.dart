import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_dashboard_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return AppAdminLayout(
      title: AppTexts.adminDashboard,
      child: Obx(
        () => GridView.count(
          crossAxisCount: AppResponsive.isMobile(context) ? 2 : 5,
          padding: AppSpacing.padding(context),
          childAspectRatio: AppResponsive.isMobile(context) ? 0.85 : 1.2,
          mainAxisSpacing: AppResponsive.screenWidth(context) * 0.03,
          crossAxisSpacing: AppResponsive.screenWidth(context) * 0.03,
          children: [
            // Total Applications - Primary Blue
            AppDashboardCard(
              title: AppTexts.totalApplications,
              value: controller.totalApplicationsCount.value.toString(),
              icon: Iconsax.document_text,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              iconColor: AppColors.white,
              textColor: AppColors.white,
              onTap: () => Get.toNamed(AppConstants.routeAdminCandidates),
            ),
            // Pending Applications - Warning Orange/Yellow
            AppDashboardCard(
              title: AppTexts.pendingApplications,
              value: controller.pendingApplicationsCount.value.toString(),
              icon: Iconsax.clock,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF9800),
                  const Color(0xFFFFC107),
                ],
              ),
              iconColor: AppColors.white,
              textColor: AppColors.white,
              onTap: () => Get.toNamed(AppConstants.routeAdminCandidates),
            ),
            // Approved Applications - Success Green
            AppDashboardCard(
              title: AppTexts.approvedApplications,
              value: controller.approvedApplicationsCount.value.toString(),
              icon: Iconsax.tick_circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF8BC34A),
                ],
              ),
              iconColor: AppColors.white,
              textColor: AppColors.white,
              onTap: () => Get.toNamed(AppConstants.routeAdminCandidates),
            ),
            // Rejected Applications - Error Red
            AppDashboardCard(
              title: AppTexts.rejectedApplications,
              value: controller.rejectedApplicationsCount.value.toString(),
              icon: Iconsax.close_circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF44336),
                  const Color(0xFFE91E63),
                ],
              ),
              iconColor: AppColors.white,
              textColor: AppColors.white,
              onTap: () => Get.toNamed(AppConstants.routeAdminCandidates),
            ),
            // Open Jobs - Secondary Blue
            AppDashboardCard(
              title: AppTexts.openJobs,
              value: controller.openJobsCount.value.toString(),
              icon: Iconsax.briefcase,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.7),
                ],
              ),
              iconColor: AppColors.white,
              textColor: AppColors.white,
              onTap: () => Get.toNamed(AppConstants.routeAdminJobs),
            ),
          ],
        ),
      ),
    );
  }
}

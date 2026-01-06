import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/candidate_dashboard_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class CandidateDashboardScreen extends StatelessWidget {
  const CandidateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CandidateDashboardController>();

    return AppCandidateLayout(
      title: AppTexts.dashboard,
      child: Obx(
        () => SingleChildScrollView(
          padding: AppSpacing.padding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // First Row: My Applications, Open Jobs
              Row(
                children: [
                  SizedBox(
                    width: AppResponsive.isMobile(context)
                        ? AppResponsive.screenWidth(context) * 0.42
                        : AppResponsive.screenWidth(context) * 0.18,
                    child: AppDashboardCard(
                      title: AppTexts.myApplications,
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
                      onTap: () =>
                          Get.toNamed(AppConstants.routeCandidateApplications),
                    ),
                  ),
                  SizedBox(width: AppResponsive.screenWidth(context) * 0.01),
                  SizedBox(
                    width: AppResponsive.isMobile(context)
                        ? AppResponsive.screenWidth(context) * 0.42
                        : AppResponsive.screenWidth(context) * 0.18,
                    child: AppDashboardCard(
                      title: AppTexts.openJobs,
                      value: controller.availableJobsCount.value.toString(),
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
                      onTap: () => Get.toNamed(AppConstants.routeCandidateJobs),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.screenWidth(context) * 0.02),
              // Second Row: Pending Documents, Approved Documents, Rejected Documents
              Row(
                children: [
                  SizedBox(
                    width: AppResponsive.isMobile(context)
                        ? AppResponsive.screenWidth(context) * 0.28
                        : AppResponsive.screenWidth(context) * 0.15,
                    child: AppDashboardCard(
                      title: AppTexts.pendingDocuments,
                      value: controller.pendingDocumentsCount.value.toString(),
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
                      onTap: () =>
                          Get.toNamed(AppConstants.routeCandidateDocuments),
                    ),
                  ),
                  SizedBox(width: AppResponsive.screenWidth(context) * 0.01),
                  SizedBox(
                    width: AppResponsive.isMobile(context)
                        ? AppResponsive.screenWidth(context) * 0.28
                        : AppResponsive.screenWidth(context) * 0.15,
                    child: AppDashboardCard(
                      title: AppTexts.approvedDocuments,
                      value: controller.approvedDocumentsCount.value.toString(),
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
                      onTap: () =>
                          Get.toNamed(AppConstants.routeCandidateDocuments),
                    ),
                  ),
                  SizedBox(width: AppResponsive.screenWidth(context) * 0.01),
                  SizedBox(
                    width: AppResponsive.isMobile(context)
                        ? AppResponsive.screenWidth(context) * 0.28
                        : AppResponsive.screenWidth(context) * 0.15,
                    child: AppDashboardCard(
                      title: AppTexts.rejectedDocuments,
                      value: controller.rejectedDocumentsCount.value.toString(),
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
                      onTap: () =>
                          Get.toNamed(AppConstants.routeCandidateDocuments),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

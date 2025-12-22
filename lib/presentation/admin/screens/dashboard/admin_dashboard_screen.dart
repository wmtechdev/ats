import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/admin/controllers/admin_dashboard_controller.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppAppBar(title: AppTexts.adminDashboard),
      body: GridView.count(
        crossAxisCount: AppResponsive.isMobile(context) ? 2 : 4,
        padding: AppSpacing.padding(context),
        childAspectRatio: 1.2,
        children: [
          AppDashboardCard(
            title: AppTexts.pendingApplications,
            value: controller.pendingApplicationsCount.value.toString(),
            icon: Iconsax.document_text,
            onTap: () => Get.toNamed(AppConstants.routeAdminCandidates),
          ),
          AppDashboardCard(
            title: AppTexts.openJobs,
            value: controller.openJobsCount.value.toString(),
            icon: Iconsax.briefcase,
            onTap: () => Get.toNamed(AppConstants.routeAdminJobs),
          ),
        ],
      ),
    );
  }
}

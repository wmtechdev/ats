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

    return AdminMainLayout(
      title: AppTexts.adminDashboard,
      child: GridView.count(
        crossAxisCount: AppResponsive.isMobile(context) ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        mainAxisSpacing: AppResponsive(context).scaleSize(0.02),
        crossAxisSpacing: AppResponsive(context).scaleSize(0.02),
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

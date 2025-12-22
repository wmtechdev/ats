import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AdminJobsListScreen extends StatelessWidget {
  const AdminJobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminJobsController>();

    return AdminMainLayout(
      title: AppTexts.jobs,
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.add,
            size: AppResponsive.iconSize(context),
            color: AppColors.primary,
          ),
          onPressed: () => Get.toNamed(AppConstants.routeAdminJobCreate),
        ),
      ],
      child: Obx(() => controller.jobs.isEmpty
          ? AppEmptyState(
              message: AppTexts.noJobsAvailable,
              icon: Iconsax.briefcase,
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.jobs.length,
              itemBuilder: (context, index) {
                final job = controller.jobs[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: AppResponsive(context).scaleSize(0.015),
                  ),
                  child: AppListCard(
                    title: job.title,
                    subtitle: job.hospitalName,
                    icon: Iconsax.briefcase,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Iconsax.edit,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.information,
                          ),
                          onPressed: () {
                            controller.selectJob(job);
                            Get.toNamed(AppConstants.routeAdminJobEdit);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Iconsax.trash,
                            size: AppResponsive.iconSize(context),
                            color: AppColors.error,
                          ),
                          onPressed: () => controller.deleteJob(job.jobId),
                        ),
                      ],
                    ),
                    onTap: null,
                  ),
                );
              },
            )),
    );
  }
}

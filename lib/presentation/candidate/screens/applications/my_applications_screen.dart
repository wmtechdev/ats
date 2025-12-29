import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/applications_controller.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applicationsController = Get.find<ApplicationsController>();
    final jobsController = Get.find<JobsController>();

    return AppCandidateLayout(
      title: AppTexts.myApplications,
      child: Obx(() => applicationsController.applications.isEmpty
          ? AppEmptyState(
              message: AppTexts.noApplicationsYet,
              icon: Iconsax.document,
            )
          : ListView.builder(
              padding: AppSpacing.padding(context),
              itemCount: applicationsController.applications.length,
              itemBuilder: (context, index) {
                final app = applicationsController.applications[index];
                final job = jobsController.jobs.firstWhereOrNull(
                  (j) => j.jobId == app.jobId,
                );
                final isDenied = app.status == AppConstants.applicationStatusDenied;

                return AppListCard(
                  title: job?.title ?? AppTexts.unknownJob,
                  subtitle: applicationsController.getStatusText(app.status),
                  icon: Iconsax.document,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppStatusChip(status: app.status),
                      // Show re-apply button only when application is denied
                      if (isDenied) ...[
                        AppSpacing.horizontal(context, 0.01),
                        AppActionButton(
                          text: AppTexts.reapply,
                          onPressed: () {
                            if (job != null) {
                              applicationsController.reapplyToJob(app.jobId);
                            }
                          },
                          backgroundColor: AppColors.warning,
                          foregroundColor: AppColors.black,
                        ),
                      ],
                    ],
                  ),
                  onTap: null,
                );
              },
            )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/presentation/candidate/controllers/applications_controller.dart';
import 'package:ats/presentation/candidate/controllers/jobs_controller.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
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
      child: Obx(
        () => applicationsController.applications.isEmpty
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
                  final isDenied =
                      app.status == AppConstants.applicationStatusDenied;
                  
                  // Calculate document completion progress
                  final totalRequired = app.requiredDocumentIds.length;
                  final uploadedCount = app.uploadedDocumentIds.length;
                  final hasRequiredDocs = totalRequired > 0;
                  final allDocsUploaded = totalRequired > 0 && uploadedCount >= totalRequired;

                  return AppListCard(
                    title: job?.title ?? AppTexts.unknownJob,
                    subtitle: applicationsController.getStatusText(app.status),
                    icon: Iconsax.document,
                    trailing: null,
                    contentBelowSubtitle: Wrap(
                      spacing: AppResponsive.screenWidth(context) * 0.01,
                      runSpacing: AppResponsive.screenHeight(context) * 0.005,
                      children: [
                        AppStatusChip(status: app.status),
                        // Show document completion progress
                        if (hasRequiredDocs)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppResponsive.screenWidth(context) * 0.015,
                              vertical: AppResponsive.screenHeight(context) * 0.008,
                            ),
                            decoration: BoxDecoration(
                              color: allDocsUploaded
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppResponsive.radius(context, factor: 5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  allDocsUploaded
                                      ? Iconsax.tick_circle
                                      : Iconsax.document_text,
                                  size: AppResponsive.iconSize(context) * 0.8,
                                  color: allDocsUploaded
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                SizedBox(width: AppResponsive.screenWidth(context) * 0.01),
                                Text(
                                  '$uploadedCount/$totalRequired documents',
                                  style: AppTextStyles.bodyText(context).copyWith(
                                    color: allDocsUploaded
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppTextStyles.bodyText(context).fontSize! * 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Show re-apply button only when application is denied
                        if (isDenied)
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
                    ),
                    onTap: null,
                  );
                },
              ),
      ),
    );
  }
}
